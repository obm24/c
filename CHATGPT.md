# ChatGPT Project Brief for TnT

Use this file as a paste-in context document when asking another AI model to help with this project. It explains the product, architecture, current implementation, design system, workflows, and coding expectations.

## 1. Product Summary

TnT is a Flutter fitness and sports-management application. It is currently a high-fidelity prototype with many production-style screens, mock data, shared app state, local asset-backed data sets, and role-specific flows for trainers and trainees.

The product combines:

- Trainer business management: clients, programmes, forms, products, posts, analytics, payments, payouts, public trainer profile, and availability/employment settings.
- Trainee experience: dashboard, workout schedule, diet programme, nutrition search, public trainee profile, body composition, circumferences, medical/injury profile, messaging, payments, and membership.
- Social/discovery experience: feed, stories, explore/search, public profiles, trainer discovery, posts, products/offers, reviews, and report/share flows.
- Messaging: conversation dashboard, unread badges, role labels, individual chat screen, message status indicators, simulated incoming replies, and mocked relationships.
- Assessment workflows: physical/postural assessment forms, fitness profile forms, corrective-strategy suggestions, body map, media upload placeholders, and analytics.

The app is named `TnT` in `pubspec.yaml` and describes itself as "World's finest and first complete fitness application."

## 2. Tech Stack

- Framework: Flutter with Dart, SDK `>=3.0.0 <4.0.0`.
- State management: mixed approach.
  - Global singleton `AppState extends ChangeNotifier` in `lib/core/app_state.dart`.
  - BLoC/Cubit style using `flutter_bloc` and `equatable` for messaging, phone validation, nutrition search, programmes, training builder, and some feature-local flows.
- Routing:
  - `go_router` for main app routes.
  - `Navigator.push` with custom no-transition routes for many secondary screens.
- UI libraries:
  - `responsive_framework`
  - `flutter_svg`
  - `fl_chart`
  - `shimmer`
  - `auto_size_text`
  - `multi_select_flutter`
  - `cupertino_icons`
  - `intl`
- Device/services packages:
  - `image_picker`
  - `camera`
  - `geolocator`
  - `url_launcher`
  - `permission_handler`
  - `connectivity_plus`
  - `torch_light`
  - `audioplayers`
  - `file_picker`
  - `firebase_messaging`
  - `flutter_local_notifications`
- Local data dependencies declared:
  - `isar`
  - `drift`
  - `build_runner`
  - These are not yet deeply wired into app persistence; much of the app still uses mock data and in-memory state.

## 3. Entry Point and Routing

Main entry point: `lib/main.dart`.

Startup sequence:

1. `WidgetsFlutterBinding.ensureInitialized()`.
2. `AppErrorWidgetBuilder.install()`.
3. Load exercise data from `assets/training-data/exercises.json` through `ExerciseRepository.loadFromAssetBundle`.
4. Run `TnTApp`, providing the `ExerciseRepository` through `RepositoryProvider.value`.

Main `GoRouter` routes:

- `/`: `LoginScreen`
- `/dashboard/:role`: `DashboardScreen(role: role)`
- `/programmes`: `ProgrammesScreen`
- `/programmes/builder`: `TrainingPlanBuilderScreen`, optionally with a `Programme` passed through `state.extra`

Many deeper screens use `Navigator.push(context, AppRoutes.noTransitionRoute(...))`, where `AppRoutes.noTransitionRoute` lives in `lib/core/core_utils.dart`.

## 4. Project Layout

Top-level Dart structure:

- `lib/main.dart`: app bootstrapping, theme, localization, responsive breakpoints, root router.
- `lib/core/`: shared app state, theme, constants, utilities, custom controls, validation, nutrition database, and standard warning banner.
- `lib/bloc/`: reusable BLoCs for messages, phone validation, nutrition search, programmes, and training builder.
- `lib/models/`: domain models for exercises, food nutrition, goals, messages, and programmes.
- `lib/repositories/`: currently includes `ExerciseRepository`.
- `lib/features/`: screen-level features and feature-local UI classes.
- `lib/l10n/`: generated localization classes. Currently only English is supported.
- `test/`: currently only has a dummy `widget_test.dart`.

Important feature files:

- `auth_screens.dart`: login, registration, forgot password, registration validation, trainer credential setup, employment-place registration.
- `dashboard_screen.dart`: authenticated app shell with bottom nav and drawer.
- `dashboard_trainer_screen.dart`: trainer management hub.
- `dashboard_trainee_screen.dart`: trainee workout/diet dashboard.
- `dashboard_feed_screen.dart`: social feed and stories.
- `dashboard_explore_screen.dart`: explore/search/discovery.
- `dashboard_messages_screen.dart`: conversations list.
- `chat_screen.dart`: individual chat.
- `trainer_programmes_screen.dart`: programme list, cards, menus.
- `training_plan_builder_screen.dart`: programme builder with exercise search/filter and workout-day editing.
- `nutrition_search_screen.dart`: local nutrition search UI.
- `forms_screens.dart`: forms management, physical/postural assessment, fitness profile form, analytics.
- `profile_screens.dart`: personal profile, password/security, body composition, circumferences, places of employment, injury profile.
- `settings_screen.dart`: account/settings, trainer availability/employment, payout settings.
- `payments_screen.dart`: payment methods, transactions, memberships, Egyptian bank integration.
- `membership_screen.dart`: trainer/trainee subscription plans, checkout, confirmation.
- `trainer_public_profile_screen.dart`: public trainer profile, products/offers, report/share/profile UI.
- `trainee_public_profile_screen.dart`: public trainee profile, body comp/circumference analytics, read-only stats, reviews.
- `trainer_clients_screen.dart`: trainer client list with filters, summaries, active/inactive/expiring states.
- `trainer_products_screen.dart`: trainer products inventory and catalogue.
- `trainer_analytics_screen.dart`: charts and analytics with `fl_chart`.
- `posts_screen.dart`: post management with photo/video/poll/article mock posts.

## 5. Core Files

### `lib/core/app_theme.dart`

The app uses a uniform dark theme:

- Background: `AppTheme.bg = Color(0xFF111315)`
- Surface: `AppTheme.surface = Color(0xFF1E2024)`
- Brand: white (`AppTheme.brand`)
- Primary text: white
- Secondary text: grey
- Divider: dark grey
- Error: `Colors.redAccent`
- Accent card colors:
  - blue, purple, yellow, pink, green, indigo, red

The font family is `Bai Jamjuree`.

### `lib/core/app_constants.dart`

Defines default UI sizing:

- Border radius: `11.0`
- Icon size: `20.0`
- App title: `45.0`
- Title: `24.0`
- Form title: `20.0`
- Subtitle: `14.0`
- Form heights and button heights

Also contains country/country-code data, flag helpers, `CountryFlagWidget`, and `CountryAdminInfo` for region/subdivision handling.

### `lib/core/app_state.dart`

Global singleton mutable state:

```dart
final appState = AppState();
```

It stores and notifies for:

- Units: weight, distance, measurement.
- Device paired flag.
- Holiday/unavailable mode and holiday date range.
- Trainer employment mode and places of employment.
- Profile identity: username, phone, country code, country, region, gender, DOB, first/last name.
- Medical status: current injuries, past injuries, medical conditions, current goals.
- Body composition and circumferences.
- Mock public trainer and trainee user maps.
- Training templates and diet templates.
- Payment/payout state: bank account, PayPal email, payout method.
- Membership plan state for trainers and trainees.

It also contains conversion/calculation helpers:

- BMI update
- BMR update
- Body composition updates
- Circumference updates
- Unit conversion for weight and measurements
- Profile save
- Medical list updates
- Places of employment CRUD
- Financial save
- Membership plan setters

### `lib/core/custom_controls.dart`

Shared controls and data:

- `AnimatedLoginButton`
- `DobDropdownWidget`
- `SolidConfirmButton`
- `OutlineActionButton`
- `DualToggleSwitch`
- `GenderToggleSwitch`
- `MedicalData`
- `TrainerCredentialDialog`
- `CustomCameraScreen`
- injury and medical condition models/enums
- `InjuryCard`
- `GroupedMultiSelectDialog`

Prefer these controls before inventing new form buttons/toggles/dialog patterns.

### `lib/core/core_utils.dart`

Shared utilities:

- `context.l10n` extension
- `AppRoutes.noTransitionRoute`
- `AppUtils.launchLink`
- `AppUtils.showToast`
- `NumberBoundsFormatter`
- `ImperialHeightFormatter`

### `lib/core/phone_validator.dart`

Country-specific phone validation. Phone validation is also wrapped by `PhoneValidationBloc`.

### `lib/core/standard_form_warning_banner.dart`

Reusable field warning/status banner. It supports a red warning state and a green valid state, with animated color/icon changes.

## 6. State Management Details

The app is not purely BLoC. It mixes:

- `AppState` singleton + `AnimatedBuilder(animation: appState, ...)` for profile/settings/body data.
- `BlocProvider`, `BlocBuilder`, `BlocConsumer` for feature-specific state.
- Local `StatefulWidget` state for many screen interactions.

Current BLoCs:

- `MessagesBloc`
  - Events: load conversations, open conversation, send message, incoming message, mark read, relationship changes, search, pin toggle.
  - States: initial/loading/loaded/error.
  - Uses seeded mock conversations and current-user relationship logic.
- `PhoneValidationBloc`
  - Tracks selected country, phone number, validity, and whether an error should show.
- `NutritionSearchBloc`
  - Loads local nutrition database and filters/searches foods.
- `ProgrammesBloc`
  - Tracks active tab and programme list.
  - Supports pin, remove, duplicate, create/modify requested, and upsert.
  - Starts from `_mockProgrammes`.
- `TrainingBuilderBloc`
  - Tracks programme editing state, day/exercise additions, exercise metric changes, and exercise search/filter state.

When adding state:

- Use existing BLoC patterns for isolated workflows.
- Use `appState` when updating already-global profile/settings/body/payment/membership data.
- Avoid creating a second source of truth for an existing `appState` field.

## 7. User Roles and Main Flows

### Login

`LoginScreen` has hardcoded demo credentials:

- Username/id `1`, password `1` logs in as `Trainer`.
- Username/id `2`, password `2` logs in as `Trainee`.

On success, navigation goes to `/dashboard/$role`.

### Registration

`RegistrationScreen` supports trainee and trainer registration. It validates:

- Username: 4-19 alphanumeric/underscore characters.
- First/last name: at least 2 letters.
- Email format.
- Password: 8+ chars with uppercase, lowercase, number, special character.
- Confirm password.
- Phone validity by selected country.
- Height and weight, with metric/imperial handling.
- DOB minimum age.
- Gender.
- Country and subdivision when needed.
- Trainer-only fields:
  - ID number.
  - ID image upload.
  - Trainer specialties.
  - Trainer credentials.
  - Places of employment unless online-only mode is selected.

Field warning banners are used for rule feedback.

### Dashboard Shell

`DashboardScreen` uses a bottom nav with:

1. Workout/management hub
2. Feed
3. Explore
4. Messages

The first tab changes by role:

- Trainer: `TrainerWorkoutPage`
- Trainee: `TraineeWorkoutPage`

The drawer includes profile, notifications, payments, and settings.

## 8. Trainer Experience

### Trainer Dashboard

`TrainerWorkoutPage` shows greeting, quick stats, and management cards:

- Clients
- Programmes
- Forms
- Products
- Posts
- Analytics

### Clients

`ClientsScreen` uses mock clients with:

- Active/inactive states.
- Days left.
- Goal.
- Session completion.
- Search and filters.
- Summary stats.

### Programmes

`ProgrammesScreen` works with `ProgrammesBloc`.

Programme model supports:

- Training or diet type.
- Name.
- Target goal and goals list.
- Description.
- Color.
- Cycle type: microcycle, mesocycle, macrocycle.
- Duration.
- Workout days.
- Pinned/active flags.

`TrainingPlanBuilderScreen` lets trainers edit programme headers, select colors, add workout days, search/filter exercises, add prescribed exercises, and configure metrics:

- Sets.
- Reps.
- Rest time.
- Notes.
- RPE.

Exercises come from `assets/training-data/exercises.json`.

### Forms

`FormsManagementScreen` has tabs:

- My Forms
- Assessment
- Analytics

Default forms:

- Fitness Assessment Profile.
- Physical & Postural Assessment.

Physical assessment includes:

- Biometrics.
- BMI and waist-to-hip ratio.
- Cardio/fitness evaluation.
- Body fat method/percentage.
- Postural checkpoints by view: anterior, lateral, posterior.
- Dynamic movement screens:
  - Overhead Squat Assessment.
  - Single-Leg Squat Assessment.
- Media upload placeholders.
- Trainer notes.
- Auto-populated NASM-style corrective strategy suggestions from `CorrectiveStrategyEngine`.

Submissions currently use `_mockSubmissions` in memory.

### Products

`ProductsScreen` manages a mock inventory with:

- Categories: Fashion, Supplements, Discounts.
- Product name, price, old price, icon, stock.
- Search.
- Inventory summary/stock badges.
- Add/edit style form components.

### Posts

`PostsScreen` supports mock post types:

- Photo
- Video
- Poll
- Article

It includes filtering, likes, poll voting, and action sheets.

### Analytics

`AnalyticsScreen` uses `fl_chart` for:

- Overview KPIs.
- Revenue lines.
- Goal distribution.
- Client/session analytics.
- Period selection.
- Export-report toast.

### Trainer Public Profile

`TrainerPublicProfileScreen` includes:

- Collapsible public profile header.
- Follow state.
- Bio and credentials.
- Specialties.
- Places/schedule/product style sections.
- Share/report flows.
- Report modal with category, subcategory, and confirmation.
- `ProductsAndOffersScreen`.

## 9. Trainee Experience

### Trainee Dashboard

`TraineeWorkoutPage` shows:

- Greeting.
- Today progress card.
- Training schedule card.
- Diet programme card.

`TrainingScheduleScreen` and `DietProgrammeScreen` are currently polished static/mock screens. The diet programme links to `NutritionSearchScreen`.

### Nutrition Search

`NutritionSearchScreen` uses `NutritionSearchBloc` and `NutritionDatabase`.

Nutrition data:

- Asset: `assets/food-data/generic-food.json`.
- Parsed into `FoodNutritionData`.
- Search returns foods and a nutrient table.
- Database extracts a curated set of macro, vitamin, mineral, amino acid, and other nutrient columns.

### Trainee Public Profile

`TraineePublicProfileScreen` includes:

- Public trainee profile data.
- Body composition descriptions and charts.
- Body circumference series with assets.
- Visibility toggles through `BodyPartVisibilityBloc`.
- Read-only stats screen.
- Feedback/reviews.
- Filtered reviews.

### Profile and Health Data

`profile_screens.dart` includes:

- `PasswordSecurityScreen`
- `ProfileInformationScreen`
- `ProfileCredentialCard`
- `BodyCompositionScreen`
- `CircumferencesScreen`
- `PlacesOfEmploymentScreen`
- Injury profile BLoC and `InjuryProfileScreen`

Body composition and circumferences update `appState`.

## 10. Messaging Experience

Messaging files:

- `lib/models/message_models.dart`
- `lib/bloc/messages_bloc.dart`
- `lib/features/dashboard_messages_screen.dart`
- `lib/features/chat_screen.dart`

Model concepts:

- `UserRole`: trainee/trainer.
- `MessageStatus`: sending, sent, delivered, read, failed.
- `MessageType`: text, image, file, voiceNote, system.
- `ChatUserModel`
- `MessageModel`
- `ConversationModel`
- `ParticipantRelationship`
- `RoleTheme`

Current behavior:

- Conversation dashboard has search, unread badges, relationship labels, "My Coach" chip, pinned conversations, shimmer loading, empty states.
- Individual chat has message bubbles, date dividers, message status icons, typing indicator, and simulated participant replies.
- Attachments, chat options, new message creation, and delete are currently "coming soon" or mocked.

## 11. Payments, Payouts, and Membership

### Payments

`PaymentsScreen` has three tabs:

- Payment Methods
- Transactions
- Memberships

It includes:

- Mock saved cards.
- Add/edit/remove/default card behavior.
- Live card preview.
- Transactions list and details modal.
- Membership overview.
- Trainer payout method selection:
  - Bank
  - PayPal
- Egyptian bank form with bank logos from assets.
- IBAN formatting and banking details BLoC.

### Membership

`MembershipScreen` has role-specific plans:

Trainer plans:

- `trainer_free`: Starter.
- `trainer_pro`: Pro.
- `trainer_elite`: Elite.

Trainee plans:

- `trainee_free`: Free.
- `trainee_plus`: Plus.
- `trainee_peak`: Peak.

Billing cycles:

- Monthly.
- Quarterly.
- Annual.

The membership flow includes:

- Plan cards.
- Feature matrix.
- Trial/trust/FAQ sections.
- Downgrade dialog.
- Checkout screen.
- OTP state where the current implementation accepts any code.
- Order summary.
- Confirmation screen.

Membership selections update `appState`.

## 12. Assets

Assets declared in `pubspec.yaml` include:

- Training data:
  - `assets/training-data/exercises.json`
- Food data:
  - `assets/food-data/generic-food.json`
- Body circumference images:
  - 9 PNGs under `assets/images/body_circumference/`
- Training schedule body-part images:
  - 22 PNGs under `assets/images/training_schedule/`
- Currency icons:
  - KSA Riyal and UAE Dirham SVGs
- Egyptian bank logos:
  - 36 SVGs under `assets/images/banks/`
- Country flags:
  - 271 SVGs under `assets/images/flags/`
- Fonts:
  - `Bai Jamjuree`
  - `OCR-A`

When adding assets, update `pubspec.yaml` and keep paths consistent.

## 13. Localization

Localization is generated under `lib/l10n/`.

Current supported locales:

- English only (`Locale('en')`)

Use:

```dart
context.l10n.someKey
```

from `LocalizedBuildContext` in `core_utils.dart`.

Important rule:

- Prefer adding strings to localization instead of hardcoding user-visible text.
- The current codebase still has many hardcoded English strings. When touching a feature substantially, consider moving new text into l10n rather than increasing hardcoded text.

## 14. Design and UX Conventions

The visual identity is:

- Dark, premium, fitness-focused.
- White brand color on very dark backgrounds.
- Surface cards with subtle borders.
- Compact typography using Bai Jamjuree.
- Frequent haptic feedback on taps/selections.
- Bouncing scroll physics.
- Animated press states on dashboard/cards/buttons.
- Rounded cards are common, often 12-24 radius depending on feature. Core default radius is 11.
- Accent colors are used by feature/category/status.
- Forms use outlined borders, brand focused borders, and red/green status feedback.

Preferred shared controls:

- `SolidConfirmButton`
- `OutlineActionButton`
- `DualToggleSwitch`
- `GenderToggleSwitch`
- `DobDropdownWidget`
- `GroupedMultiSelectDialog`
- `StandardFormWarningBanner`

When implementing UI:

- Match existing dark theme and spacing.
- Use `AppTheme` and `AppConstants`.
- Do not introduce a second visual language.
- Prefer existing controls and local patterns.
- Keep mobile-first layout; app is currently designed mostly for mobile screens.
- Avoid adding new dependencies unless the existing stack cannot reasonably solve the task.

## 15. Validation and Form Patterns

Common validation patterns:

- Controllers usually add listeners and call `setState`.
- Fields deny newline input with `FilteringTextInputFormatter.deny(RegExp(r'\n'))`.
- Numeric fields use custom bounds formatters where available.
- Phone fields use `PhoneValidationBloc` or `PhoneValidationService.validateDetailed`.
- Country selection uses flag paths plus country names.
- Subdivision fields depend on `CountryAdminInfo`.
- Required/invalid field feedback appears below fields using `StandardFormWarningBanner`.

Registration-specific rules:

- Username: `^[a-zA-Z0-9_]{4,19}$`
- Names: at least 2 letters.
- Password: uppercase, lowercase, digit, special char, 8+ length.
- Phone: country-specific service.
- Height/weight: metric and imperial conversion.
- Trainer credentials must be saved and complete.
- Trainer employment location is required unless online-only mode is selected.

## 16. Current Data Reality

This app is currently mostly prototype/in-memory:

- Login is hardcoded.
- Most screens use mock maps/lists.
- Messaging has seeded mock conversations.
- Programmes start from mock data.
- Products, posts, clients, analytics, transactions, reviews, public profiles, and forms are mocked.
- Nutrition and exercise search are asset-backed and closer to real local data.
- `isar` and `drift` are present as dependencies but not used as the main persistence layer yet.
- Firebase notification packages are present but not fully wired in the visible app flow.

When an AI model is asked to "connect backend" or "make it real", it should first identify which mock source owns the relevant data and then replace it with a repository/service layer instead of directly sprinkling API calls into widgets.

## 17. Important Implementation Notes

- `AppState` is a singleton and many screens listen with `AnimatedBuilder`.
- There are two `PlacesOfEmploymentScreen` classes in different feature files/namespaces. Be careful with imports and aliases.
- `dashboard_screen.dart` aliases settings and public profile files to avoid collisions.
- Some source files are very large. Keep edits targeted.
- Many feature files define private helper widgets inside the same file. Follow the local style unless extracting actually reduces complexity.
- Some terminal output may show mojibake for emojis or special characters, but the Flutter UI may still render the original source correctly.
- The codebase contains many "coming soon" placeholders. Do not assume a feature is wired just because the UI exists.
- `analysis_options.yaml` uses `flutter_lints`.
- `test/widget_test.dart` is currently only a dummy test.

## 18. Development Commands

Common commands:

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
flutter run
```

When changing generated database schemas in the future:

```bash
dart run build_runner build -d
```

Because this app uses asset bundles, run through Flutter rather than plain Dart for UI workflows.

## 19. Guidance for Future AI Assistants

When helping with this project:

- Read the relevant feature file before editing.
- Preserve the existing dark theme and shared controls.
- Use `AppTheme`, `AppConstants`, `context.l10n`, and `AppUtils` where appropriate.
- Prefer BLoC for isolated workflows and `appState` for existing global profile/settings/body/payment/membership data.
- Avoid broad refactors of huge files unless explicitly requested.
- Do not replace mock data with backend logic unless the task asks for persistence/integration.
- Do not add dependencies without checking `pubspec.yaml` first.
- Keep changes mobile-first and responsive.
- Add focused tests for logic-heavy changes where feasible.
- After editing, run `dart format` and `flutter analyze` if the environment allows it.
- Be careful with user-visible strings; prefer localization for new substantial UI copy.
- When adding an asset, update `pubspec.yaml`.
- When changing routes, update `main.dart` and any relevant navigation entry point.
- When modifying public profile, messaging, payments, or settings flows, check for role-specific behavior for both Trainer and Trainee.

## 20. Useful Mental Model

Think of TnT as a "trainer business OS plus trainee fitness companion":

- Trainer side: manage clients, products, content, programmes, assessments, analytics, availability, payouts, and subscriptions.
- Trainee side: follow workout/diet plans, search nutrition data, manage health metrics, message trainers, maintain profile, and manage subscriptions/payment methods.
- Shared social layer: feed, explore, public profiles, reviews, messaging, and reporting.

The current goal of most development tasks is to improve a polished prototype without breaking its existing screen structure, theme, or role-specific flows.
