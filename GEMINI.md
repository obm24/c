# Gemini CLI Guidelines for `TnT` Project

## Tech Stack
- **Framework:** Flutter (Dart)
- **State Management:** BLoC (`flutter_bloc`, `equatable`)
- **Routing:** `go_router`
- **Local Storage/Databases:** `isar`, `drift`
- **UI & Theming:** `responsive_framework`, `shimmer`, `fl_chart`, `auto_size_text`, `multi_select_flutter`, `flutter_svg`, `intl`, `cupertino_icons`
- **Hardware/Services:** `camera`, `geolocator`, `firebase_messaging`, `flutter_local_notifications`, `image_picker`, `audioplayers`, `file_picker`, `url_launcher`, `permission_handler`, `connectivity_plus`, `torch_light`

## Architecture & Conventions
- **Feature-Driven Architecture:** Code inside `lib/` is organized into `core/`, `features/`, and `l10n/`. New logic should reside within the appropriate feature directory or shared core.
- **State Management:** Exclusively use BLoC/Cubit (`flutter_bloc`) with `equatable` for predictable and comparable state.
- **Routing:** Handle all navigation using `go_router`.
- **Code Generation:** This project heavily utilizes code generation (`drift`, `isar`). Always remember to run `dart run build_runner build -d` when modifying database schemas or generated files.
- **Localization:** Use the provided localization setup (`l10n/`) instead of hardcoding strings in the UI.

## Development Workflow
- **Linting & Analysis:** The project relies on `flutter_lints`. Always ensure code modifications do not introduce new analyzer warnings. You can verify this by running `dart analyze`.
- **Testing:** Write widget and unit tests in the `test/` folder. Use `integration_test` for UI tests.
- **Responsive Design:** Utilize `responsive_framework` components and guidelines for adapting the UI across varying device sizes.

## Agent Specific Directives
- **Idiomatic Dart/Flutter:** Prioritize clean, typed, and null-safe Dart code. Avoid bypasses like forced unwrapping (`!`) unless absolutely necessary and proven safe.
- **Tool Usage:** Always rely on specific file operations (`replace`, `write_file`) for edits over shell scripting.
- **Dependency Management:** Review existing dependencies in `pubspec.yaml` before introducing new ones to avoid redundancy.
