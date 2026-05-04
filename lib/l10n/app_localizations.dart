import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'TnT'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'LOGIN'**
  String get login;

  /// No description provided for @logoutConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logoutConfirmation;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @registerAction.
  ///
  /// In en, this message translates to:
  /// **'CREATE ACCOUNT'**
  String get registerAction;

  /// No description provided for @id.
  ///
  /// In en, this message translates to:
  /// **'Username or E-mail'**
  String get id;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'SEND RESET LINK'**
  String get sendResetLink;

  /// No description provided for @idOrEmail.
  ///
  /// In en, this message translates to:
  /// **'Username or E-mail'**
  String get idOrEmail;

  /// No description provided for @trainee.
  ///
  /// In en, this message translates to:
  /// **'Trainee'**
  String get trainee;

  /// No description provided for @trainer.
  ///
  /// In en, this message translates to:
  /// **'Trainer'**
  String get trainer;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @imperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get imperial;

  /// No description provided for @accountInfo.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInfo;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @invalidUsernameError.
  ///
  /// In en, this message translates to:
  /// **'Must be 4–19 alphanumeric characters.'**
  String get invalidUsernameError;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'E-mail Address'**
  String get emailAddress;

  /// No description provided for @invalidEmailError.
  ///
  /// In en, this message translates to:
  /// **'Must be a valid e-mail address.'**
  String get invalidEmailError;

  /// No description provided for @invalidPasswordError.
  ///
  /// In en, this message translates to:
  /// **'Must contain 8 characters (1 uppercase, 1 lowercase, a number, and a special character).'**
  String get invalidPasswordError;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @passwordMismatchError.
  ///
  /// In en, this message translates to:
  /// **'Must match the password above.'**
  String get passwordMismatchError;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @invalidNameError.
  ///
  /// In en, this message translates to:
  /// **'Must contain at least 2 letters.'**
  String get invalidNameError;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @invalidPhoneError.
  ///
  /// In en, this message translates to:
  /// **'Must be a valid phone number.'**
  String get invalidPhoneError;

  /// No description provided for @invalidMobileCountryWarning.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid mobile number matching your country\'s required format and network prefix.'**
  String get invalidMobileCountryWarning;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @ageError.
  ///
  /// In en, this message translates to:
  /// **'Must be 16 years old or older.'**
  String get ageError;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get yearsOld;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @genderSelectionError.
  ///
  /// In en, this message translates to:
  /// **'Please select a gender.'**
  String get genderSelectionError;

  /// No description provided for @nationality.
  ///
  /// In en, this message translates to:
  /// **'Nationality'**
  String get nationality;

  /// No description provided for @nationalitySelectionError.
  ///
  /// In en, this message translates to:
  /// **'Please select a nationality.'**
  String get nationalitySelectionError;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @physicalTrainingExperience.
  ///
  /// In en, this message translates to:
  /// **'Training Experience'**
  String get physicalTrainingExperience;

  /// No description provided for @trainingExperienceRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select your training experience.'**
  String get trainingExperienceRequired;

  /// No description provided for @metricHeightError.
  ///
  /// In en, this message translates to:
  /// **'Must be between 55–272 cm.'**
  String get metricHeightError;

  /// No description provided for @imperialHeightError.
  ///
  /// In en, this message translates to:
  /// **'Must be between 1\' 9\" and 8\' 11\".'**
  String get imperialHeightError;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @invalidMeasurementWarning.
  ///
  /// In en, this message translates to:
  /// **'Please enter a physically valid measurement.'**
  String get invalidMeasurementWarning;

  /// No description provided for @realisticHeightWarning.
  ///
  /// In en, this message translates to:
  /// **'Please enter a realistic height in {unit}.'**
  String realisticHeightWarning(String unit);

  /// No description provided for @realisticWeightWarning.
  ///
  /// In en, this message translates to:
  /// **'Please enter a realistic weight in {unit}.'**
  String realisticWeightWarning(String unit);

  /// No description provided for @metricWeightError.
  ///
  /// In en, this message translates to:
  /// **'Must be between 30–635 kg.'**
  String get metricWeightError;

  /// No description provided for @imperialWeightError.
  ///
  /// In en, this message translates to:
  /// **'Must be between 66–1,400 lbs.'**
  String get imperialWeightError;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cancelRegistrationTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel registration?'**
  String get cancelRegistrationTitle;

  /// No description provided for @cancelRegistrationMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to cancel? All progress will be lost.'**
  String get cancelRegistrationMessage;

  /// No description provided for @keepEditing.
  ///
  /// In en, this message translates to:
  /// **'Keep Editing'**
  String get keepEditing;

  /// No description provided for @discardProgress.
  ///
  /// In en, this message translates to:
  /// **'Discard Progress'**
  String get discardProgress;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'SAVE CHANGES'**
  String get saveChanges;

  /// No description provided for @saveData.
  ///
  /// In en, this message translates to:
  /// **'SAVE DATA'**
  String get saveData;

  /// No description provided for @saveMeasurements.
  ///
  /// In en, this message translates to:
  /// **'SAVE MEASUREMENTS'**
  String get saveMeasurements;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get logout;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @dashboardWelcomeCoach.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Coach!'**
  String get dashboardWelcomeCoach;

  /// No description provided for @dashboardWelcomeTrainee.
  ///
  /// In en, this message translates to:
  /// **'Welcome back, Trainee!'**
  String get dashboardWelcomeTrainee;

  /// No description provided for @trainingSchedule.
  ///
  /// In en, this message translates to:
  /// **'Training Schedule'**
  String get trainingSchedule;

  /// No description provided for @viewWeeklyPlan.
  ///
  /// In en, this message translates to:
  /// **'View your weekly plan'**
  String get viewWeeklyPlan;

  /// No description provided for @dietProgramme.
  ///
  /// In en, this message translates to:
  /// **'Diet Programme'**
  String get dietProgramme;

  /// No description provided for @yourNutritionPlan.
  ///
  /// In en, this message translates to:
  /// **'Your nutrition plan'**
  String get yourNutritionPlan;

  /// No description provided for @messageTrainers.
  ///
  /// In en, this message translates to:
  /// **'Message Trainer(s)'**
  String get messageTrainers;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @programmes.
  ///
  /// In en, this message translates to:
  /// **'Programmes'**
  String get programmes;

  /// No description provided for @templates.
  ///
  /// In en, this message translates to:
  /// **'Templates'**
  String get templates;

  /// No description provided for @forms.
  ///
  /// In en, this message translates to:
  /// **'Forms'**
  String get forms;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @posts.
  ///
  /// In en, this message translates to:
  /// **'Posts'**
  String get posts;

  /// No description provided for @content.
  ///
  /// In en, this message translates to:
  /// **'Content'**
  String get content;

  /// No description provided for @analytics.
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analytics;

  /// No description provided for @inviteTrainee.
  ///
  /// In en, this message translates to:
  /// **'Invite Trainee'**
  String get inviteTrainee;

  /// No description provided for @addTrainee.
  ///
  /// In en, this message translates to:
  /// **'Add Trainee'**
  String get addTrainee;

  /// No description provided for @managePayouts.
  ///
  /// In en, this message translates to:
  /// **'Manage Payouts'**
  String get managePayouts;

  /// No description provided for @managePayoutsDesc.
  ///
  /// In en, this message translates to:
  /// **'Select and configure your preferred platform to send and receive payments.'**
  String get managePayoutsDesc;

  /// No description provided for @managePayoutsTrainerDesc.
  ///
  /// In en, this message translates to:
  /// **'Link your local bank to withdraw earnings securely.'**
  String get managePayoutsTrainerDesc;

  /// No description provided for @managePaymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Manage Payment Methods'**
  String get managePaymentMethods;

  /// No description provided for @managePaymentMethodsDesc.
  ///
  /// In en, this message translates to:
  /// **'Add a card to pay for memberships and extras securely.'**
  String get managePaymentMethodsDesc;

  /// No description provided for @bankTransfer.
  ///
  /// In en, this message translates to:
  /// **'Bank Transfer'**
  String get bankTransfer;

  /// No description provided for @paypal.
  ///
  /// In en, this message translates to:
  /// **'PayPal'**
  String get paypal;

  /// No description provided for @bankName.
  ///
  /// In en, this message translates to:
  /// **'Bank Name'**
  String get bankName;

  /// No description provided for @ibanLabel.
  ///
  /// In en, this message translates to:
  /// **'IBAN'**
  String get ibanLabel;

  /// No description provided for @accountNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Account Number'**
  String get accountNumberLabel;

  /// No description provided for @swiftCodeLabel.
  ///
  /// In en, this message translates to:
  /// **'SWIFT Code'**
  String get swiftCodeLabel;

  /// No description provided for @paypalEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'PayPal E-mail Address'**
  String get paypalEmailLabel;

  /// No description provided for @financialsSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Financial details saved successfully!'**
  String get financialsSavedSuccess;

  /// No description provided for @bodyComposition.
  ///
  /// In en, this message translates to:
  /// **'Body Composition'**
  String get bodyComposition;

  /// No description provided for @circumferences.
  ///
  /// In en, this message translates to:
  /// **'Circumferences'**
  String get circumferences;

  /// No description provided for @medicalStatus.
  ///
  /// In en, this message translates to:
  /// **'Medical Status'**
  String get medicalStatus;

  /// No description provided for @currentInjuries.
  ///
  /// In en, this message translates to:
  /// **'Current Injuries'**
  String get currentInjuries;

  /// No description provided for @pastInjuries.
  ///
  /// In en, this message translates to:
  /// **'Past Injuries'**
  String get pastInjuries;

  /// No description provided for @medicalConditions.
  ///
  /// In en, this message translates to:
  /// **'Medical Conditions'**
  String get medicalConditions;

  /// No description provided for @accountCreatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccess;

  /// No description provided for @resetPasswordInstructions.
  ///
  /// In en, this message translates to:
  /// **'Enter your registered username or e-mail. We will send you instructions to reset your password.'**
  String get resetPasswordInstructions;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent!'**
  String get resetLinkSent;

  /// No description provided for @profileSavedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Profile saved successfully!'**
  String get profileSavedSuccess;

  /// No description provided for @profileImageUpdated.
  ///
  /// In en, this message translates to:
  /// **'Profile picture updated!'**
  String get profileImageUpdated;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'CLOSE'**
  String get close;

  /// No description provided for @descriptionNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Description not available.'**
  String get descriptionNotAvailable;

  /// No description provided for @changeEmail.
  ///
  /// In en, this message translates to:
  /// **'Change E-mail'**
  String get changeEmail;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @advertisement.
  ///
  /// In en, this message translates to:
  /// **'Advertisement'**
  String get advertisement;

  /// No description provided for @bodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Body Weight'**
  String get bodyWeight;

  /// No description provided for @bodyMassIndex.
  ///
  /// In en, this message translates to:
  /// **'Body Mass Index (BMI)'**
  String get bodyMassIndex;

  /// No description provided for @totalBodyWater.
  ///
  /// In en, this message translates to:
  /// **'Total Body Water (TBW)'**
  String get totalBodyWater;

  /// No description provided for @intracellularWater.
  ///
  /// In en, this message translates to:
  /// **'Intracellular Water (ICW)'**
  String get intracellularWater;

  /// No description provided for @extracellularWater.
  ///
  /// In en, this message translates to:
  /// **'Extracellular Water (ECW)'**
  String get extracellularWater;

  /// No description provided for @skeletalMuscleMass.
  ///
  /// In en, this message translates to:
  /// **'Skeletal Muscle Mass (SMM)'**
  String get skeletalMuscleMass;

  /// No description provided for @softLeanMass.
  ///
  /// In en, this message translates to:
  /// **'Soft Lean Mass (SLM)'**
  String get softLeanMass;

  /// No description provided for @fatFreeMass.
  ///
  /// In en, this message translates to:
  /// **'Fat Free Mass (FFM)'**
  String get fatFreeMass;

  /// No description provided for @fatMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Fat Measurements'**
  String get fatMeasurements;

  /// No description provided for @bodyFatMass.
  ///
  /// In en, this message translates to:
  /// **'Body Fat Mass (BFM)'**
  String get bodyFatMass;

  /// No description provided for @bodyFatPercentage.
  ///
  /// In en, this message translates to:
  /// **'Body Fat Percentage (PBF)'**
  String get bodyFatPercentage;

  /// No description provided for @subcutaneousFatMass.
  ///
  /// In en, this message translates to:
  /// **'Subcutaneous Fat Mass'**
  String get subcutaneousFatMass;

  /// No description provided for @segmentalLeanMass.
  ///
  /// In en, this message translates to:
  /// **'Segmental Lean Mass'**
  String get segmentalLeanMass;

  /// No description provided for @rightArm.
  ///
  /// In en, this message translates to:
  /// **'Right Arm'**
  String get rightArm;

  /// No description provided for @leftArm.
  ///
  /// In en, this message translates to:
  /// **'Left Arm'**
  String get leftArm;

  /// No description provided for @trunk.
  ///
  /// In en, this message translates to:
  /// **'Trunk'**
  String get trunk;

  /// No description provided for @rightLeg.
  ///
  /// In en, this message translates to:
  /// **'Right Leg'**
  String get rightLeg;

  /// No description provided for @leftLeg.
  ///
  /// In en, this message translates to:
  /// **'Left Leg'**
  String get leftLeg;

  /// No description provided for @bodyCompositionSaved.
  ///
  /// In en, this message translates to:
  /// **'Body Composition Saved!'**
  String get bodyCompositionSaved;

  /// No description provided for @upperBody.
  ///
  /// In en, this message translates to:
  /// **'Upper Body'**
  String get upperBody;

  /// No description provided for @neck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get neck;

  /// No description provided for @shoulder.
  ///
  /// In en, this message translates to:
  /// **'Shoulder'**
  String get shoulder;

  /// No description provided for @shoulders.
  ///
  /// In en, this message translates to:
  /// **'Shoulders'**
  String get shoulders;

  /// No description provided for @chest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get chest;

  /// No description provided for @arm.
  ///
  /// In en, this message translates to:
  /// **'Arm'**
  String get arm;

  /// No description provided for @arms.
  ///
  /// In en, this message translates to:
  /// **'Arms'**
  String get arms;

  /// No description provided for @forearm.
  ///
  /// In en, this message translates to:
  /// **'Forearm'**
  String get forearm;

  /// No description provided for @forearms.
  ///
  /// In en, this message translates to:
  /// **'Forearms'**
  String get forearms;

  /// No description provided for @waist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get waist;

  /// No description provided for @hips.
  ///
  /// In en, this message translates to:
  /// **'Hips'**
  String get hips;

  /// No description provided for @lowerBody.
  ///
  /// In en, this message translates to:
  /// **'Lower Body'**
  String get lowerBody;

  /// No description provided for @thigh.
  ///
  /// In en, this message translates to:
  /// **'Thigh'**
  String get thigh;

  /// No description provided for @thighs.
  ///
  /// In en, this message translates to:
  /// **'Thighs'**
  String get thighs;

  /// No description provided for @calf.
  ///
  /// In en, this message translates to:
  /// **'Calf'**
  String get calf;

  /// No description provided for @calves.
  ///
  /// In en, this message translates to:
  /// **'Calves'**
  String get calves;

  /// No description provided for @measurementsSaved.
  ///
  /// In en, this message translates to:
  /// **'Measurements Saved!'**
  String get measurementsSaved;

  /// No description provided for @allSeriesHidden.
  ///
  /// In en, this message translates to:
  /// **'All series hidden.'**
  String get allSeriesHidden;

  /// No description provided for @tapBodyPartToShowSeries.
  ///
  /// In en, this message translates to:
  /// **'Tap a body part button to show one.'**
  String get tapBodyPartToShowSeries;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @disableConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to turn off'**
  String get disableConfirmation;

  /// No description provided for @disableAction.
  ///
  /// In en, this message translates to:
  /// **'DISABLE'**
  String get disableAction;

  /// No description provided for @pairedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Successfully paired with device!'**
  String get pairedSuccessfully;

  /// No description provided for @scanningDevices.
  ///
  /// In en, this message translates to:
  /// **'Scanning for nearby devices…'**
  String get scanningDevices;

  /// No description provided for @ensureBluetoothEnabled.
  ///
  /// In en, this message translates to:
  /// **'Please ensure Bluetooth is enabled.'**
  String get ensureBluetoothEnabled;

  /// No description provided for @unitPreferences.
  ///
  /// In en, this message translates to:
  /// **'Unit Preferences'**
  String get unitPreferences;

  /// No description provided for @weightUnits.
  ///
  /// In en, this message translates to:
  /// **'Weight Units'**
  String get weightUnits;

  /// No description provided for @weightUnitsDesc.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred unit for tracking body weight and lifting milestones.'**
  String get weightUnitsDesc;

  /// No description provided for @lengthAndDistance.
  ///
  /// In en, this message translates to:
  /// **'Length & Distance'**
  String get lengthAndDistance;

  /// No description provided for @lengthAndDistanceDesc.
  ///
  /// In en, this message translates to:
  /// **'Select the unit for measuring running, walking, and other distance-based cardio.'**
  String get lengthAndDistanceDesc;

  /// No description provided for @bodyMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Body Measurements'**
  String get bodyMeasurements;

  /// No description provided for @bodyMeasurementsDesc.
  ///
  /// In en, this message translates to:
  /// **'Set the unit for logging body proportions like waist, chest, and arm circumferences.'**
  String get bodyMeasurementsDesc;

  /// No description provided for @integrations.
  ///
  /// In en, this message translates to:
  /// **'Integrations'**
  String get integrations;

  /// No description provided for @syncHealthData.
  ///
  /// In en, this message translates to:
  /// **'Sync Health Data'**
  String get syncHealthData;

  /// No description provided for @syncHealthDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Ensure your trainer has accurate data to optimise your fitness journey.'**
  String get syncHealthDataDesc;

  /// No description provided for @paired.
  ///
  /// In en, this message translates to:
  /// **'PAIRED'**
  String get paired;

  /// No description provided for @pair.
  ///
  /// In en, this message translates to:
  /// **'PAIR'**
  String get pair;

  /// No description provided for @trainerAvailability.
  ///
  /// In en, this message translates to:
  /// **'Trainer Availability'**
  String get trainerAvailability;

  /// No description provided for @holidayMode.
  ///
  /// In en, this message translates to:
  /// **'Holiday Mode'**
  String get holidayMode;

  /// No description provided for @holidayModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Block out calendar dates to prevent new bookings.'**
  String get holidayModeDesc;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @unavailableMode.
  ///
  /// In en, this message translates to:
  /// **'Unavailable Mode'**
  String get unavailableMode;

  /// No description provided for @unavailableModeDesc.
  ///
  /// In en, this message translates to:
  /// **'Prevent all incoming requests to avoid overwhelm.'**
  String get unavailableModeDesc;

  /// No description provided for @pageComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Page Coming Soon'**
  String get pageComingSoon;

  /// No description provided for @ageLabel.
  ///
  /// In en, this message translates to:
  /// **'Age:'**
  String get ageLabel;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayLabel;

  /// No description provided for @targetMuscleLabel.
  ///
  /// In en, this message translates to:
  /// **'Target Muscle'**
  String get targetMuscleLabel;

  /// No description provided for @exerciseLabel.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exerciseLabel;

  /// No description provided for @setsLabel.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get setsLabel;

  /// No description provided for @repsLabel.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get repsLabel;

  /// No description provided for @mealLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal'**
  String get mealLabel;

  /// No description provided for @timeLabel.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get timeLabel;

  /// No description provided for @foodItemsLabel.
  ///
  /// In en, this message translates to:
  /// **'Food Items'**
  String get foodItemsLabel;

  /// No description provided for @caloriesLabel.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get caloriesLabel;

  /// No description provided for @proteinLabel.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get proteinLabel;

  /// No description provided for @externalLinkWarning.
  ///
  /// In en, this message translates to:
  /// **'External Link Warning'**
  String get externalLinkWarning;

  /// No description provided for @externalLinkDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'This link was sent in a chat and is not affiliated with TnT. Proceed at your own risk:'**
  String get externalLinkDisclaimer;

  /// No description provided for @proceed.
  ///
  /// In en, this message translates to:
  /// **'PROCEED'**
  String get proceed;

  /// No description provided for @incorrectCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect credentials.'**
  String get incorrectCredentials;

  /// No description provided for @incorrectUsername.
  ///
  /// In en, this message translates to:
  /// **'Incorrect username.'**
  String get incorrectUsername;

  /// No description provided for @incorrectEmail.
  ///
  /// In en, this message translates to:
  /// **'Incorrect e-mail.'**
  String get incorrectEmail;

  /// No description provided for @incorrectPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect password.'**
  String get incorrectPassword;

  /// No description provided for @monday.
  ///
  /// In en, this message translates to:
  /// **'Monday'**
  String get monday;

  /// No description provided for @tuesday.
  ///
  /// In en, this message translates to:
  /// **'Tuesday'**
  String get tuesday;

  /// No description provided for @wednesday.
  ///
  /// In en, this message translates to:
  /// **'Wednesday'**
  String get wednesday;

  /// No description provided for @thursday.
  ///
  /// In en, this message translates to:
  /// **'Thursday'**
  String get thursday;

  /// No description provided for @rest.
  ///
  /// In en, this message translates to:
  /// **'Rest'**
  String get rest;

  /// No description provided for @legs.
  ///
  /// In en, this message translates to:
  /// **'Legs'**
  String get legs;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @breakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get breakfast;

  /// No description provided for @snack1.
  ///
  /// In en, this message translates to:
  /// **'Snack 1'**
  String get snack1;

  /// No description provided for @lunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get lunch;

  /// No description provided for @snack2.
  ///
  /// In en, this message translates to:
  /// **'Snack 2'**
  String get snack2;

  /// No description provided for @dinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get dinner;

  /// No description provided for @shareProfile.
  ///
  /// In en, this message translates to:
  /// **'Share Profile'**
  String get shareProfile;

  /// No description provided for @copyUrl.
  ///
  /// In en, this message translates to:
  /// **'Copy URL'**
  String get copyUrl;

  /// No description provided for @urlCopied.
  ///
  /// In en, this message translates to:
  /// **'URL copied to clipboard.'**
  String get urlCopied;

  /// No description provided for @showQrCode.
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get showQrCode;

  /// No description provided for @scanToView.
  ///
  /// In en, this message translates to:
  /// **'Scan to View Profile'**
  String get scanToView;

  /// No description provided for @primaryGoal.
  ///
  /// In en, this message translates to:
  /// **'Primary Goal'**
  String get primaryGoal;

  /// No description provided for @healthAndMetrics.
  ///
  /// In en, this message translates to:
  /// **'Health & Metrics'**
  String get healthAndMetrics;

  /// No description provided for @preferredDiet.
  ///
  /// In en, this message translates to:
  /// **'Preferred Diet'**
  String get preferredDiet;

  /// No description provided for @addYourCard.
  ///
  /// In en, this message translates to:
  /// **'Add your card'**
  String get addYourCard;

  /// No description provided for @fillCardFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in the fields below or use your camera phone.'**
  String get fillCardFields;

  /// No description provided for @cardNumber.
  ///
  /// In en, this message translates to:
  /// **'Your card number'**
  String get cardNumber;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry date'**
  String get expiryDate;

  /// No description provided for @cvv2.
  ///
  /// In en, this message translates to:
  /// **'CVV2'**
  String get cvv2;

  /// No description provided for @scanCard.
  ///
  /// In en, this message translates to:
  /// **'Scan card info by camera'**
  String get scanCard;

  /// No description provided for @addFaceId.
  ///
  /// In en, this message translates to:
  /// **'Add Face ID'**
  String get addFaceId;

  /// No description provided for @viewTransactions.
  ///
  /// In en, this message translates to:
  /// **'View Transactions'**
  String get viewTransactions;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @searchTransactions.
  ///
  /// In en, this message translates to:
  /// **'Search for transaction(s)…'**
  String get searchTransactions;

  /// No description provided for @professionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Professional Information'**
  String get professionalInfo;

  /// No description provided for @identificationNumber.
  ///
  /// In en, this message translates to:
  /// **'Identification Number (ID)'**
  String get identificationNumber;

  /// No description provided for @invalidIdNumberError.
  ///
  /// In en, this message translates to:
  /// **'Must be 7–18 alphanumeric characters.'**
  String get invalidIdNumberError;

  /// No description provided for @uploadId.
  ///
  /// In en, this message translates to:
  /// **'Upload ID'**
  String get uploadId;

  /// No description provided for @uploadIdDocument.
  ///
  /// In en, this message translates to:
  /// **'Upload ID Document'**
  String get uploadIdDocument;

  /// No description provided for @idDocumentRequiredWarning.
  ///
  /// In en, this message translates to:
  /// **'A valid ID document is required to proceed with trainer verification.'**
  String get idDocumentRequiredWarning;

  /// No description provided for @idUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'ID Uploaded Successfully'**
  String get idUploadedSuccessfully;

  /// No description provided for @idScanInstructions.
  ///
  /// In en, this message translates to:
  /// **'Provide a clear scan of the front and back of your ID.'**
  String get idScanInstructions;

  /// No description provided for @uploadFromDevice.
  ///
  /// In en, this message translates to:
  /// **'Upload from device'**
  String get uploadFromDevice;

  /// No description provided for @scanViaCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan via camera'**
  String get scanViaCamera;

  /// No description provided for @professionalSpecialities.
  ///
  /// In en, this message translates to:
  /// **'Professional Specialities'**
  String get professionalSpecialities;

  /// No description provided for @addSpecialities.
  ///
  /// In en, this message translates to:
  /// **'Add Specialities'**
  String get addSpecialities;

  /// No description provided for @specialityRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one speciality is required.'**
  String get specialityRequired;

  /// No description provided for @specialities.
  ///
  /// In en, this message translates to:
  /// **'Specialities'**
  String get specialities;

  /// No description provided for @credentials.
  ///
  /// In en, this message translates to:
  /// **'Credentials'**
  String get credentials;

  /// No description provided for @credentialExplanation.
  ///
  /// In en, this message translates to:
  /// **'Select your certifying organisation and the certificate issued. A valid Certificate ID is mandatory for verification.'**
  String get credentialExplanation;

  /// No description provided for @addCredential.
  ///
  /// In en, this message translates to:
  /// **'Add Credential'**
  String get addCredential;

  /// No description provided for @credentialRequired.
  ///
  /// In en, this message translates to:
  /// **'At least one credential is required.'**
  String get credentialRequired;

  /// No description provided for @saveAllCredentials.
  ///
  /// In en, this message translates to:
  /// **'Save all credentials before submitting.'**
  String get saveAllCredentials;

  /// No description provided for @certificateId.
  ///
  /// In en, this message translates to:
  /// **'Certificate ID'**
  String get certificateId;

  /// No description provided for @certificateIdRequired.
  ///
  /// In en, this message translates to:
  /// **'Certificate ID is required (minimum 3 characters using letters, numbers, hyphens, or slashes).'**
  String get certificateIdRequired;

  /// No description provided for @selectOrganisation.
  ///
  /// In en, this message translates to:
  /// **'Select Organisation'**
  String get selectOrganisation;

  /// No description provided for @selectCertificate.
  ///
  /// In en, this message translates to:
  /// **'Select Certificate'**
  String get selectCertificate;

  /// No description provided for @allCertificatesInUse.
  ///
  /// In en, this message translates to:
  /// **'All certificates for this organisation are already in use.'**
  String get allCertificatesInUse;

  /// No description provided for @credentialLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You have reached the maximum of {count} certificates for {organization}.'**
  String credentialLimitReached(String organization, String count);

  /// No description provided for @organisation.
  ///
  /// In en, this message translates to:
  /// **'Organisation'**
  String get organisation;

  /// No description provided for @organisationRequired.
  ///
  /// In en, this message translates to:
  /// **'Organisation is required.'**
  String get organisationRequired;

  /// No description provided for @certificateRequired.
  ///
  /// In en, this message translates to:
  /// **'Certificate is required.'**
  String get certificateRequired;

  /// No description provided for @verifiedCredential.
  ///
  /// In en, this message translates to:
  /// **'Verified Credential'**
  String get verifiedCredential;

  /// No description provided for @placesOfEmployment.
  ///
  /// In en, this message translates to:
  /// **'Places of Employment'**
  String get placesOfEmployment;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Add at least one physical location.'**
  String get locationRequired;

  /// No description provided for @addLocation.
  ///
  /// In en, this message translates to:
  /// **'Add Location'**
  String get addLocation;

  /// No description provided for @editLocation.
  ///
  /// In en, this message translates to:
  /// **'Edit Location'**
  String get editLocation;

  /// No description provided for @locationType.
  ///
  /// In en, this message translates to:
  /// **'Location Type'**
  String get locationType;

  /// No description provided for @facilityName.
  ///
  /// In en, this message translates to:
  /// **'Facility Name'**
  String get facilityName;

  /// No description provided for @streetAddress.
  ///
  /// In en, this message translates to:
  /// **'Street Address'**
  String get streetAddress;

  /// No description provided for @removeLocation.
  ///
  /// In en, this message translates to:
  /// **'Remove Location'**
  String get removeLocation;

  /// No description provided for @hybridTraining.
  ///
  /// In en, this message translates to:
  /// **'Hybrid Personal Training'**
  String get hybridTraining;

  /// No description provided for @hybridTrainingDesc.
  ///
  /// In en, this message translates to:
  /// **'You train clients both in physical locations and online, offering maximum flexibility and reach.'**
  String get hybridTrainingDesc;

  /// No description provided for @onlineOnlyTraining.
  ///
  /// In en, this message translates to:
  /// **'Only Online Personal Training'**
  String get onlineOnlyTraining;

  /// No description provided for @onlineOnlyTrainingDesc.
  ///
  /// In en, this message translates to:
  /// **'You operate exclusively through online coaching and do not train clients in physical locations.'**
  String get onlineOnlyTrainingDesc;

  /// No description provided for @inPersonOnlyTraining.
  ///
  /// In en, this message translates to:
  /// **'Only In-Person Personal Training'**
  String get inPersonOnlyTraining;

  /// No description provided for @inPersonOnlyTrainingDesc.
  ///
  /// In en, this message translates to:
  /// **'You exclusively train clients face-to-face at physical venues such as gyms, studios, or outdoor spaces.'**
  String get inPersonOnlyTrainingDesc;

  /// No description provided for @countryOfEmployment.
  ///
  /// In en, this message translates to:
  /// **'Country of Employment'**
  String get countryOfEmployment;

  /// No description provided for @countryOfResidence.
  ///
  /// In en, this message translates to:
  /// **'Country of Residence'**
  String get countryOfResidence;

  /// No description provided for @selectCountryEmployment.
  ///
  /// In en, this message translates to:
  /// **'Please select your country of employment.'**
  String get selectCountryEmployment;

  /// No description provided for @selectCountryResidence.
  ///
  /// In en, this message translates to:
  /// **'Please select your country of residence.'**
  String get selectCountryResidence;

  /// No description provided for @workout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get workout;

  /// No description provided for @explore.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get explore;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @searchTrainersTrainees.
  ///
  /// In en, this message translates to:
  /// **'Search for trainers or trainees…'**
  String get searchTrainersTrainees;

  /// No description provided for @noResultsFound.
  ///
  /// In en, this message translates to:
  /// **'No results found.'**
  String get noResultsFound;

  /// No description provided for @mockUserNoProfile.
  ///
  /// In en, this message translates to:
  /// **'This mock user has no public profile set up yet.'**
  String get mockUserNoProfile;

  /// No description provided for @notificationsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Notifications coming soon.'**
  String get notificationsComingSoon;

  /// No description provided for @bodyStats.
  ///
  /// In en, this message translates to:
  /// **'Body Stats'**
  String get bodyStats;

  /// No description provided for @trackYourProgress.
  ///
  /// In en, this message translates to:
  /// **'Track your progress'**
  String get trackYourProgress;

  /// No description provided for @bodyStatsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Body stats screen coming soon.'**
  String get bodyStatsComingSoon;

  /// No description provided for @searchExplore.
  ///
  /// In en, this message translates to:
  /// **'Search workouts, trainers, tips…'**
  String get searchExplore;

  /// No description provided for @nothingFound.
  ///
  /// In en, this message translates to:
  /// **'Nothing found.'**
  String get nothingFound;

  /// No description provided for @detailComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Detail coming soon.'**
  String get detailComingSoon;

  /// No description provided for @commentsComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Comments coming soon.'**
  String get commentsComingSoon;

  /// No description provided for @shareComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Share coming soon.'**
  String get shareComingSoon;

  /// No description provided for @readArticle.
  ///
  /// In en, this message translates to:
  /// **'Read Article'**
  String get readArticle;

  /// No description provided for @aboutApp.
  ///
  /// In en, this message translates to:
  /// **'About TnT'**
  String get aboutApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version 1.0.0+1'**
  String get version;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'TnT is a comprehensive fitness management platform connecting trainers and trainees.'**
  String get aboutDescription;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 TnT. All rights reserved.'**
  String get copyright;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountWarning.
  ///
  /// In en, this message translates to:
  /// **'This action is permanent and cannot be undone. All your data will be deleted.'**
  String get deleteAccountWarning;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @selectCurrency.
  ///
  /// In en, this message translates to:
  /// **'Select Currency'**
  String get selectCurrency;

  /// No description provided for @measurementUnits.
  ///
  /// In en, this message translates to:
  /// **'Measurement Units'**
  String get measurementUnits;

  /// No description provided for @metricKg.
  ///
  /// In en, this message translates to:
  /// **'Metric (kg)'**
  String get metricKg;

  /// No description provided for @imperialLbs.
  ///
  /// In en, this message translates to:
  /// **'Imperial (lbs)'**
  String get imperialLbs;

  /// No description provided for @metricKm.
  ///
  /// In en, this message translates to:
  /// **'Metric (km)'**
  String get metricKm;

  /// No description provided for @imperialMi.
  ///
  /// In en, this message translates to:
  /// **'Imperial (mi)'**
  String get imperialMi;

  /// No description provided for @metricCm.
  ///
  /// In en, this message translates to:
  /// **'Metric (cm)'**
  String get metricCm;

  /// No description provided for @imperialIn.
  ///
  /// In en, this message translates to:
  /// **'Imperial (in)'**
  String get imperialIn;

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @distanceTrackingHint.
  ///
  /// In en, this message translates to:
  /// **'Used for running and cardio tracking.'**
  String get distanceTrackingHint;

  /// No description provided for @bodyMeasurementsHint.
  ///
  /// In en, this message translates to:
  /// **'Used for height and circumferences.'**
  String get bodyMeasurementsHint;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

  /// No description provided for @addCard.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCard;

  /// No description provided for @editCard.
  ///
  /// In en, this message translates to:
  /// **'EDIT'**
  String get editCard;

  /// No description provided for @removeCard.
  ///
  /// In en, this message translates to:
  /// **'REMOVE'**
  String get removeCard;

  /// No description provided for @removeCardTitle.
  ///
  /// In en, this message translates to:
  /// **'Remove Card?'**
  String get removeCardTitle;

  /// No description provided for @cardRemoved.
  ///
  /// In en, this message translates to:
  /// **'Card removed.'**
  String get cardRemoved;

  /// No description provided for @expires.
  ///
  /// In en, this message translates to:
  /// **'EXPIRES'**
  String get expires;

  /// No description provided for @saveCard.
  ///
  /// In en, this message translates to:
  /// **'Save Card'**
  String get saveCard;

  /// No description provided for @exportLabel.
  ///
  /// In en, this message translates to:
  /// **'EXPORT'**
  String get exportLabel;

  /// No description provided for @clientReviews.
  ///
  /// In en, this message translates to:
  /// **'Client Reviews'**
  String get clientReviews;

  /// No description provided for @introVideo.
  ///
  /// In en, this message translates to:
  /// **'Intro Video'**
  String get introVideo;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get stats;

  /// No description provided for @viewBodyComposition.
  ///
  /// In en, this message translates to:
  /// **'View Body Composition'**
  String get viewBodyComposition;

  /// No description provided for @viewCircumferences.
  ///
  /// In en, this message translates to:
  /// **'View Circumferences'**
  String get viewCircumferences;

  /// No description provided for @currentGoals.
  ///
  /// In en, this message translates to:
  /// **'Current Goals'**
  String get currentGoals;

  /// No description provided for @dietaryPreferences.
  ///
  /// In en, this message translates to:
  /// **'Dietary Preferences'**
  String get dietaryPreferences;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @currently.
  ///
  /// In en, this message translates to:
  /// **'Currently'**
  String get currently;

  /// No description provided for @reportSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Report submitted.'**
  String get reportSubmitted;

  /// No description provided for @successStories.
  ///
  /// In en, this message translates to:
  /// **'Success Stories'**
  String get successStories;

  /// No description provided for @wherTrainerWorks.
  ///
  /// In en, this message translates to:
  /// **'Where this trainer works in real life'**
  String get wherTrainerWorks;

  /// No description provided for @noLocationsListed.
  ///
  /// In en, this message translates to:
  /// **'No locations listed yet.'**
  String get noLocationsListed;

  /// No description provided for @chooseYourJourney.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Journey'**
  String get chooseYourJourney;

  /// No description provided for @mostPopular.
  ///
  /// In en, this message translates to:
  /// **'MOST POPULAR'**
  String get mostPopular;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Subscribe Now'**
  String get subscribeNow;

  /// No description provided for @redirectingToCheckout.
  ///
  /// In en, this message translates to:
  /// **'Redirecting to checkout…'**
  String get redirectingToCheckout;

  /// No description provided for @exclusivePostsExtras.
  ///
  /// In en, this message translates to:
  /// **'Exclusive Posts & Extras'**
  String get exclusivePostsExtras;

  /// No description provided for @membersOnly.
  ///
  /// In en, this message translates to:
  /// **'Members Only'**
  String get membersOnly;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View more'**
  String get viewMore;

  /// No description provided for @reel.
  ///
  /// In en, this message translates to:
  /// **'REEL'**
  String get reel;

  /// No description provided for @article.
  ///
  /// In en, this message translates to:
  /// **'ARTICLE'**
  String get article;

  /// No description provided for @searchClients.
  ///
  /// In en, this message translates to:
  /// **'Search clients…'**
  String get searchClients;

  /// No description provided for @noInactiveClients.
  ///
  /// In en, this message translates to:
  /// **'No inactive clients.'**
  String get noInactiveClients;

  /// No description provided for @clientDetailComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Client detail screen coming soon.'**
  String get clientDetailComingSoon;

  /// No description provided for @newProgramme.
  ///
  /// In en, this message translates to:
  /// **'New Programme'**
  String get newProgramme;

  /// No description provided for @programmeBuilderComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Programme builder coming soon.'**
  String get programmeBuilderComingSoon;

  /// No description provided for @trainingProgrammes.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get trainingProgrammes;

  /// No description provided for @dietProgrammes.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get dietProgrammes;

  /// No description provided for @trainingProgramme.
  ///
  /// In en, this message translates to:
  /// **'Training\nProgramme'**
  String get trainingProgramme;

  /// No description provided for @pinProgramme.
  ///
  /// In en, this message translates to:
  /// **'Pin to Top'**
  String get pinProgramme;

  /// No description provided for @unpinProgramme.
  ///
  /// In en, this message translates to:
  /// **'Unpin'**
  String get unpinProgramme;

  /// No description provided for @modifyProgramme.
  ///
  /// In en, this message translates to:
  /// **'Modify'**
  String get modifyProgramme;

  /// No description provided for @removeProgramme.
  ///
  /// In en, this message translates to:
  /// **'Remove Programme'**
  String get removeProgramme;

  /// No description provided for @removeProgrammeWarning.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{name}\"? This action cannot be undone.'**
  String removeProgrammeWarning(String name);

  /// No description provided for @programmeDeleted.
  ///
  /// In en, this message translates to:
  /// **'Programme removed.'**
  String get programmeDeleted;

  /// No description provided for @programmePinned.
  ///
  /// In en, this message translates to:
  /// **'Programme pinned to top.'**
  String get programmePinned;

  /// No description provided for @programmeUnpinned.
  ///
  /// In en, this message translates to:
  /// **'Programme unpinned.'**
  String get programmeUnpinned;

  /// No description provided for @noProgrammesTraining.
  ///
  /// In en, this message translates to:
  /// **'No training programmes yet.\nTap the button below to create your first one.'**
  String get noProgrammesTraining;

  /// No description provided for @noProgrammesDiet.
  ///
  /// In en, this message translates to:
  /// **'No diet programmes yet.\nTap the button below to create your first one.'**
  String get noProgrammesDiet;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'sessions'**
  String get sessions;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @assignToClient.
  ///
  /// In en, this message translates to:
  /// **'Assign to Client'**
  String get assignToClient;

  /// No description provided for @assignComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Assign to client — coming soon.'**
  String get assignComingSoon;

  /// No description provided for @formsManager.
  ///
  /// In en, this message translates to:
  /// **'Forms Manager'**
  String get formsManager;

  /// No description provided for @deleteForm.
  ///
  /// In en, this message translates to:
  /// **'Delete Form'**
  String get deleteForm;

  /// No description provided for @deleteFormWarning.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? All {count} responses will be permanently lost.'**
  String deleteFormWarning(String name, String count);

  /// No description provided for @deletePermanently.
  ///
  /// In en, this message translates to:
  /// **'Delete Permanently'**
  String get deletePermanently;

  /// No description provided for @formDeleted.
  ///
  /// In en, this message translates to:
  /// **'Form deleted.'**
  String get formDeleted;

  /// No description provided for @formEditorComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Form editor coming soon.'**
  String get formEditorComingSoon;

  /// No description provided for @shareLinkCopied.
  ///
  /// In en, this message translates to:
  /// **'Share link copied!'**
  String get shareLinkCopied;

  /// No description provided for @responsesComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Responses view coming soon.'**
  String get responsesComingSoon;

  /// No description provided for @createForm.
  ///
  /// In en, this message translates to:
  /// **'Create Form'**
  String get createForm;

  /// No description provided for @formBuilderComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Form builder coming soon.'**
  String get formBuilderComingSoon;

  /// No description provided for @noFormsYet.
  ///
  /// In en, this message translates to:
  /// **'No forms here yet.\nCreate one to start collecting responses.'**
  String get noFormsYet;

  /// No description provided for @productsAndOffers.
  ///
  /// In en, this message translates to:
  /// **'Products & Offers'**
  String get productsAndOffers;

  /// No description provided for @productCreationComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Product creation coming soon.'**
  String get productCreationComingSoon;

  /// No description provided for @viewAllCount.
  ///
  /// In en, this message translates to:
  /// **'View all ({count})'**
  String viewAllCount(String count);

  /// No description provided for @noProductsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No products in this category.'**
  String get noProductsInCategory;

  /// No description provided for @stock.
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// No description provided for @editPost.
  ///
  /// In en, this message translates to:
  /// **'Edit Post'**
  String get editPost;

  /// No description provided for @postEditorComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Post editor coming soon.'**
  String get postEditorComingSoon;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @deletePost.
  ///
  /// In en, this message translates to:
  /// **'Delete Post'**
  String get deletePost;

  /// No description provided for @postDeleted.
  ///
  /// In en, this message translates to:
  /// **'Post deleted.'**
  String get postDeleted;

  /// No description provided for @noPostsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No posts in this category yet.'**
  String get noPostsInCategory;

  /// No description provided for @postComposerComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Post composer coming soon.'**
  String get postComposerComingSoon;

  /// No description provided for @estTotalValue.
  ///
  /// In en, this message translates to:
  /// **'Est. total value'**
  String get estTotalValue;

  /// No description provided for @vsLastPeriod.
  ///
  /// In en, this message translates to:
  /// **'vs last period'**
  String get vsLastPeriod;

  /// No description provided for @revenueTrend.
  ///
  /// In en, this message translates to:
  /// **'Revenue Trend'**
  String get revenueTrend;

  /// No description provided for @goalDistribution.
  ///
  /// In en, this message translates to:
  /// **'Goal Distribution'**
  String get goalDistribution;

  /// No description provided for @clientProgress.
  ///
  /// In en, this message translates to:
  /// **'Client Progress'**
  String get clientProgress;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'Recent Transactions'**
  String get recentTransactions;

  /// No description provided for @passwordAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Password & Security'**
  String get passwordAndSecurity;

  /// No description provided for @accountIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Account Identifier'**
  String get accountIdentifier;

  /// No description provided for @changeEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Change E-mail Address'**
  String get changeEmailAddress;

  /// No description provided for @newEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'New E-mail Address'**
  String get newEmailAddress;

  /// No description provided for @sendVerificationLink.
  ///
  /// In en, this message translates to:
  /// **'Send Verification Link'**
  String get sendVerificationLink;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @passwordUpdatedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully!'**
  String get passwordUpdatedSuccess;

  /// No description provided for @profileInformation.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInformation;

  /// No description provided for @goals.
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goals;

  /// No description provided for @professionalSetup.
  ///
  /// In en, this message translates to:
  /// **'Professional Setup'**
  String get professionalSetup;

  /// No description provided for @manageCredentials.
  ///
  /// In en, this message translates to:
  /// **'Manage Credentials'**
  String get manageCredentials;

  /// No description provided for @noCredentialsAdded.
  ///
  /// In en, this message translates to:
  /// **'No credentials added yet.'**
  String get noCredentialsAdded;

  /// No description provided for @saveMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Save Measurement'**
  String get saveMeasurement;

  /// No description provided for @selectCertificates.
  ///
  /// In en, this message translates to:
  /// **'Select Certificate(s)'**
  String get selectCertificates;

  /// No description provided for @imageConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Does the image look clear and readable?'**
  String get imageConfirmation;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @showingResults.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} Results'**
  String showingResults(String count);

  /// No description provided for @statusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated to {status}.'**
  String statusUpdated(String status);

  /// No description provided for @activeCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Active'**
  String activeCount(String count);

  /// No description provided for @plansCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Plans'**
  String plansCount(String count);

  /// No description provided for @savedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Saved'**
  String savedCount(String count);

  /// No description provided for @pendingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Pending'**
  String pendingCount(String count);

  /// No description provided for @itemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Items'**
  String itemsCount(String count);

  /// No description provided for @postsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} Posts'**
  String postsCount(String count);

  /// No description provided for @growthPercent.
  ///
  /// In en, this message translates to:
  /// **'+{percent}% Growth'**
  String growthPercent(String percent);

  /// No description provided for @descRotatorCuffTear.
  ///
  /// In en, this message translates to:
  /// **'A strain or tear in the muscles/tendons stabilising the shoulder. Can be acute (from a fall) or degenerative (fraying over time).'**
  String get descRotatorCuffTear;

  /// No description provided for @descACJointSprain.
  ///
  /// In en, this message translates to:
  /// **'Often called a \"separated shoulder,\" this is a stretch or tear of the ligaments connecting the collarbone to the shoulder blade.'**
  String get descACJointSprain;

  /// No description provided for @descShoulderOsteo.
  ///
  /// In en, this message translates to:
  /// **'The gradual wearing away of the protective cartilage in the shoulder joint, leading to bone-on-bone friction and stiffness.'**
  String get descShoulderOsteo;

  /// No description provided for @descShoulderDislocation.
  ///
  /// In en, this message translates to:
  /// **'The upper arm bone pops entirely out of the shoulder socket.'**
  String get descShoulderDislocation;

  /// No description provided for @descShoulderImpingement.
  ///
  /// In en, this message translates to:
  /// **'Pinching of the rotator cuff tendons against the shoulder blade, often leading to degenerative wear if left untreated.'**
  String get descShoulderImpingement;

  /// No description provided for @descUCLSprain.
  ///
  /// In en, this message translates to:
  /// **'A tear of the ligament on the inside of the elbow, highly common in throwing athletes like baseball pitchers.'**
  String get descUCLSprain;

  /// No description provided for @descEpicondylopathy.
  ///
  /// In en, this message translates to:
  /// **'While often called tendinitis, these are usually degenerative conditions (tendinosis) involving micro-tearing and breakdown of the tendons on the outside or inside of the elbow due to overuse.'**
  String get descEpicondylopathy;

  /// No description provided for @descOlecranonBursitis.
  ///
  /// In en, this message translates to:
  /// **'Swelling of the small fluid-filled sac at the bony tip of the elbow.'**
  String get descOlecranonBursitis;

  /// No description provided for @descWristSprain.
  ///
  /// In en, this message translates to:
  /// **'Stretching or tearing of the ligaments connecting the wrist bones, usually from falling onto an outstretched hand.'**
  String get descWristSprain;

  /// No description provided for @descSkiersThumb.
  ///
  /// In en, this message translates to:
  /// **'A sprain or tear of the ligament at the base of the thumb, making it difficult to pinch or grasp objects.'**
  String get descSkiersThumb;

  /// No description provided for @descThumbArthritis.
  ///
  /// In en, this message translates to:
  /// **'Wear-and-tear of the cartilage at the base of the thumb (the CMC joint), causing severe pain when gripping or turning keys.'**
  String get descThumbArthritis;

  /// No description provided for @descCarpalTunnel.
  ///
  /// In en, this message translates to:
  /// **'Compression of the median nerve in the wrist, often worsening over time, causing numbness and tingling.'**
  String get descCarpalTunnel;

  /// No description provided for @descScaphoidFracture.
  ///
  /// In en, this message translates to:
  /// **'A slow-healing break in one of the small carpal bones near the base of the thumb.'**
  String get descScaphoidFracture;

  /// No description provided for @descHipOsteo.
  ///
  /// In en, this message translates to:
  /// **'The progressive breakdown of cartilage in the hip\'s ball-and-socket joint, causing stiffness, a reduced range of motion, and groin pain.'**
  String get descHipOsteo;

  /// No description provided for @descGroinStrain.
  ///
  /// In en, this message translates to:
  /// **'A tear in the adductor muscles of the inner thigh, common in sports requiring sudden, explosive lateral movements.'**
  String get descGroinStrain;

  /// No description provided for @descHipLabralTear.
  ///
  /// In en, this message translates to:
  /// **'Damage to the ring of cartilage lining the hip socket. This can be an acute injury or a degenerative issue from repetitive motion.'**
  String get descHipLabralTear;

  /// No description provided for @descHipPointer.
  ///
  /// In en, this message translates to:
  /// **'A deep, painful bruise on the bony ridge of the pelvis caused by a direct impact.'**
  String get descHipPointer;

  /// No description provided for @descCollateralLigament.
  ///
  /// In en, this message translates to:
  /// **'Stretches or tears of the ligaments on the inner (MCL) or outer (LCL) sides of the knee, usually caused by sideways forces.'**
  String get descCollateralLigament;

  /// No description provided for @descCruciateLigament.
  ///
  /// In en, this message translates to:
  /// **'Internal knee sprains. An ACL tear is a Grade 3 sprain of the anterior ligament, famous for happening during sudden pivots and causing the knee to buckle.'**
  String get descCruciateLigament;

  /// No description provided for @descKneeOsteo.
  ///
  /// In en, this message translates to:
  /// **'The deterioration of the knee\'s shock-absorbing cartilage, eventually leading to painful bone-on-bone contact.'**
  String get descKneeOsteo;

  /// No description provided for @descMeniscusTear.
  ///
  /// In en, this message translates to:
  /// **'While younger people get acute meniscus tears from twisting, older adults often experience degenerative tears where the cartilage simply frays and weakens over time.'**
  String get descMeniscusTear;

  /// No description provided for @descPatellarTendinopathy.
  ///
  /// In en, this message translates to:
  /// **'Degeneration or inflammation of the tendon connecting the kneecap to the shinbone from repetitive stress.'**
  String get descPatellarTendinopathy;

  /// No description provided for @descCalfStrain.
  ///
  /// In en, this message translates to:
  /// **'A tear in the muscles at the back of the lower leg, ranging from a micro-tear to a complete rupture.'**
  String get descCalfStrain;

  /// No description provided for @descAchillesTendinosis.
  ///
  /// In en, this message translates to:
  /// **'The chronic breakdown of the collagen in the Achilles tendon from repetitive overuse, distinct from acute tendinitis (inflammation) or a sudden rupture.'**
  String get descAchillesTendinosis;

  /// No description provided for @descShinSplints.
  ///
  /// In en, this message translates to:
  /// **'Pain along the shinbone caused by cumulative stress and inflammation of the surrounding tissues.'**
  String get descShinSplints;

  /// No description provided for @descAnkleSprain.
  ///
  /// In en, this message translates to:
  /// **'The classic \"rolled ankle,\" stretching or tearing the ligaments on the outside of the ankle.'**
  String get descAnkleSprain;

  /// No description provided for @descHighAnkleSprain.
  ///
  /// In en, this message translates to:
  /// **'A more severe sprain involving the ligaments that connect the two lower leg bones (tibia and fibula) just above the ankle.'**
  String get descHighAnkleSprain;

  /// No description provided for @descTurfToe.
  ///
  /// In en, this message translates to:
  /// **'A sprain of the main joint of the big toe, usually occurring when the toe is forcibly bent upwards.'**
  String get descTurfToe;

  /// No description provided for @descPlantarFasciitis.
  ///
  /// In en, this message translates to:
  /// **'Often driven by degenerative changes rather than purely inflammation, this affects the thick band of tissue on the bottom of the foot, causing stabbing heel pain.'**
  String get descPlantarFasciitis;

  /// No description provided for @descMidfootArthritis.
  ///
  /// In en, this message translates to:
  /// **'Wear-and-tear of the cartilage in the middle of the foot, causing a deep, aching pain when walking or standing.'**
  String get descMidfootArthritis;

  /// No description provided for @descAlzheimers.
  ///
  /// In en, this message translates to:
  /// **'A progressive neurological disorder that causes brain cells to degenerate and die, leading to memory loss, confusion, and cognitive decline.'**
  String get descAlzheimers;

  /// No description provided for @descAnemia.
  ///
  /// In en, this message translates to:
  /// **'A condition where you lack enough healthy red blood cells to carry adequate oxygen to your body\'s tissues, often causing persistent fatigue and weakness.'**
  String get descAnemia;

  /// No description provided for @descAngina.
  ///
  /// In en, this message translates to:
  /// **'Chest pain or discomfort caused by temporarily reduced blood flow and oxygen to the heart muscle.'**
  String get descAngina;

  /// No description provided for @descAnxietyDisorders.
  ///
  /// In en, this message translates to:
  /// **'A group of mental health conditions characterised by persistent, excessive worry or fear that interferes with daily life and activities.'**
  String get descAnxietyDisorders;

  /// No description provided for @descAsthma.
  ///
  /// In en, this message translates to:
  /// **'A chronic respiratory condition where the airways become inflamed, narrow, and swell, making it difficult to breathe and causing wheezing.'**
  String get descAsthma;

  /// No description provided for @descCeliacDisease.
  ///
  /// In en, this message translates to:
  /// **'An autoimmune disorder where ingesting gluten leads to damage in the small intestine, preventing the absorption of nutrients.'**
  String get descCeliacDisease;

  /// No description provided for @descChronicKidneyDisease.
  ///
  /// In en, this message translates to:
  /// **'A gradual loss of kidney function over time, preventing the kidneys from properly filtering waste and excess fluids from the blood.'**
  String get descChronicKidneyDisease;

  /// No description provided for @descCOPD.
  ///
  /// In en, this message translates to:
  /// **'A chronic inflammatory lung disease that causes obstructed airflow from the lungs; it includes conditions like emphysema and chronic bronchitis.'**
  String get descCOPD;

  /// No description provided for @descCoronaryArteryDisease.
  ///
  /// In en, this message translates to:
  /// **'The most common type of heart disease, caused by the build-up of cholesterol plaque in the arteries that supply blood to the heart.'**
  String get descCoronaryArteryDisease;

  /// No description provided for @descDVT.
  ///
  /// In en, this message translates to:
  /// **'A serious condition where a blood clot forms in a deep vein, most commonly in the calf or thigh.'**
  String get descDVT;

  /// No description provided for @descDepression.
  ///
  /// In en, this message translates to:
  /// **'A common but serious mood disorder that causes a persistent feeling of sadness, hopelessness, and a loss of interest in daily activities.'**
  String get descDepression;

  /// No description provided for @descDiabetesMellitus.
  ///
  /// In en, this message translates to:
  /// **'A group of metabolic diseases that cause high blood sugar. In Type 1, the body produces no insulin. In the much more common Type 2, the body does not use insulin properly.'**
  String get descDiabetesMellitus;

  /// No description provided for @descEndometriosis.
  ///
  /// In en, this message translates to:
  /// **'A painful condition where tissue similar to the lining of the uterus grows outside of it, commonly affecting the ovaries and pelvis.'**
  String get descEndometriosis;

  /// No description provided for @descGERD.
  ///
  /// In en, this message translates to:
  /// **'A chronic digestive disease where stomach acid or bile frequently flows back into the oesophagus, causing severe heartburn.'**
  String get descGERD;

  /// No description provided for @descGout.
  ///
  /// In en, this message translates to:
  /// **'A very painful and complex form of arthritis caused by an excess of uric acid in the blood, which forms sharp crystals in a joint (often the big toe).'**
  String get descGout;

  /// No description provided for @descHernia.
  ///
  /// In en, this message translates to:
  /// **'Occurs when an internal organ pushes through a weak spot in the surrounding muscle or tissue wall.'**
  String get descHernia;

  /// No description provided for @descHypertension.
  ///
  /// In en, this message translates to:
  /// **'A highly common cardiovascular condition where the force of the blood against the artery walls is consistently too high, significantly increasing the risk of heart disease and stroke.'**
  String get descHypertension;

  /// No description provided for @descHyperthyroidism.
  ///
  /// In en, this message translates to:
  /// **'An overactive thyroid condition where the gland produces too much thyroid hormone, significantly speeding up the body\'s metabolism and often causing unintentional weight loss, anxiety, and a rapid heartbeat.'**
  String get descHyperthyroidism;

  /// No description provided for @descHypothyroidism.
  ///
  /// In en, this message translates to:
  /// **'An underactive thyroid condition where the gland does not produce enough thyroid hormone, slowing down the metabolism and commonly leading to fatigue, weight gain, and sensitivity to cold.'**
  String get descHypothyroidism;

  /// No description provided for @descKidneyStones.
  ///
  /// In en, this message translates to:
  /// **'Hard deposits of minerals and acid salts that stick together in concentrated urine, causing excruciating pain when passing through the urinary tract.'**
  String get descKidneyStones;

  /// No description provided for @descMigraine.
  ///
  /// In en, this message translates to:
  /// **'A neurological condition characterised by intense, debilitating, throbbing headaches, often accompanied by nausea and extreme sensitivity to light and sound.'**
  String get descMigraine;

  /// No description provided for @descObesity.
  ///
  /// In en, this message translates to:
  /// **'A complex, chronic disease involving an excessive amount of body fat that significantly increases the risk of other health problems, such as heart disease, sleep apnoea, and type 2 diabetes.'**
  String get descObesity;

  /// No description provided for @descOsteoarthritis.
  ///
  /// In en, this message translates to:
  /// **'The most common form of arthritis, characterised by the progressive wear-and-tear of the protective cartilage on the ends of your bones.'**
  String get descOsteoarthritis;

  /// No description provided for @descOsteoporosis.
  ///
  /// In en, this message translates to:
  /// **'A condition that causes bones to become weak and brittle over time, making them highly susceptible to fractures from even mild stress or falls.'**
  String get descOsteoporosis;

  /// No description provided for @descPAD.
  ///
  /// In en, this message translates to:
  /// **'A circulatory problem where narrowed arteries reduce blood flow to your limbs, often causing leg pain when walking.'**
  String get descPAD;

  /// No description provided for @descPeripheralNeuropathy.
  ///
  /// In en, this message translates to:
  /// **'A result of damage to the peripheral nerves (frequently caused by diabetes) that causes weakness, numbness, and burning pain, usually starting in the hands or feet.'**
  String get descPeripheralNeuropathy;

  /// No description provided for @descRaynaudsDisease.
  ///
  /// In en, this message translates to:
  /// **'A disorder of the blood vessels where cold temperatures or stress cause the vessels to temporarily narrow, turning fingers or toes white or blue and making them feel numb.'**
  String get descRaynaudsDisease;

  /// No description provided for @descRheumatoidArthritis.
  ///
  /// In en, this message translates to:
  /// **'A chronic autoimmune and inflammatory disease where the body\'s immune system mistakenly attacks its own joint linings, causing painful swelling.'**
  String get descRheumatoidArthritis;

  /// No description provided for @descShingles.
  ///
  /// In en, this message translates to:
  /// **'A viral infection caused by the reactivation of the chickenpox virus, leading to a painful, blistering rash.'**
  String get descShingles;

  /// No description provided for @descSleepApnea.
  ///
  /// In en, this message translates to:
  /// **'A potentially serious sleep disorder where a person\'s breathing repeatedly stops and starts during the night, leading to poor sleep quality and daytime fatigue.'**
  String get descSleepApnea;

  /// No description provided for @descStroke.
  ///
  /// In en, this message translates to:
  /// **'A medical emergency that occurs when the blood supply to part of your brain is interrupted or reduced, preventing brain tissue from getting necessary oxygen and nutrients.'**
  String get descStroke;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @availability.
  ///
  /// In en, this message translates to:
  /// **'Availability'**
  String get availability;

  /// No description provided for @unavailableModeSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Unavailable Mode'**
  String get unavailableModeSettingsTitle;

  /// No description provided for @unavailableModeSettingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prevent new subscriptions & messages'**
  String get unavailableModeSettingsSubtitle;

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @masterNotificationToggle.
  ///
  /// In en, this message translates to:
  /// **'Master notification toggle'**
  String get masterNotificationToggle;

  /// No description provided for @emailNotifications.
  ///
  /// In en, this message translates to:
  /// **'E-mail Notifications'**
  String get emailNotifications;

  /// No description provided for @emailNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive updates via e-mail'**
  String get emailNotificationsDesc;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive push notifications'**
  String get pushNotificationsDesc;

  /// No description provided for @smsNotifications.
  ///
  /// In en, this message translates to:
  /// **'SMS Notifications'**
  String get smsNotifications;

  /// No description provided for @smsNotificationsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive text messages'**
  String get smsNotificationsDesc;

  /// No description provided for @preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @measurementUnitsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weight, distance, height'**
  String get measurementUnitsSubtitle;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @helpCentre.
  ///
  /// In en, this message translates to:
  /// **'Help Centre'**
  String get helpCentre;

  /// No description provided for @helpCentreDesc.
  ///
  /// In en, this message translates to:
  /// **'FAQs and support articles'**
  String get helpCentreDesc;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @contactUsDesc.
  ///
  /// In en, this message translates to:
  /// **'Get in touch with support'**
  String get contactUsDesc;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'App version and information'**
  String get aboutSubtitle;

  /// No description provided for @languageChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Language changed to {language}.'**
  String languageChangedTo(String language);

  /// No description provided for @currencyChangedTo.
  ///
  /// In en, this message translates to:
  /// **'Currency changed to {currency}.'**
  String currencyChangedTo(String currency);

  /// No description provided for @weightLiftingHint.
  ///
  /// In en, this message translates to:
  /// **'Used for body weight and lifting metrics.'**
  String get weightLiftingHint;

  /// No description provided for @updatePersonalDetails.
  ///
  /// In en, this message translates to:
  /// **'Update your personal details'**
  String get updatePersonalDetails;

  /// No description provided for @manageYourCredentials.
  ///
  /// In en, this message translates to:
  /// **'Manage your credentials'**
  String get manageYourCredentials;

  /// No description provided for @profileInfoTitle.
  ///
  /// In en, this message translates to:
  /// **'Profile Information'**
  String get profileInfoTitle;

  /// No description provided for @verificationLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Verification link sent!'**
  String get verificationLinkSent;

  /// No description provided for @updateMetric.
  ///
  /// In en, this message translates to:
  /// **'Update {label}'**
  String updateMetric(String label);

  /// No description provided for @pleaseSelectField.
  ///
  /// In en, this message translates to:
  /// **'Please select your {field}.'**
  String pleaseSelectField(String field);

  /// No description provided for @loadingItems.
  ///
  /// In en, this message translates to:
  /// **'Loading all items in {title}…'**
  String loadingItems(String title);

  /// No description provided for @cardNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Card Number'**
  String get cardNumberLabel;

  /// No description provided for @expiryLabel.
  ///
  /// In en, this message translates to:
  /// **'Expiry'**
  String get expiryLabel;

  /// No description provided for @expiryHint.
  ///
  /// In en, this message translates to:
  /// **'MM/YY'**
  String get expiryHint;

  /// No description provided for @cvvLabel.
  ///
  /// In en, this message translates to:
  /// **'CVV'**
  String get cvvLabel;

  /// No description provided for @programmeSummaryComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Programme summary coming soon.'**
  String get programmeSummaryComingSoon;

  /// No description provided for @productDetailComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Product detail coming soon.'**
  String get productDetailComingSoon;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon.'**
  String get comingSoon;

  /// No description provided for @saveLocation.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveLocation;

  /// No description provided for @holiday.
  ///
  /// In en, this message translates to:
  /// **'Holiday'**
  String get holiday;

  /// No description provided for @removeCardPrompt.
  ///
  /// In en, this message translates to:
  /// **'Remove Card?'**
  String get removeCardPrompt;

  /// No description provided for @cardRemovedMsg.
  ///
  /// In en, this message translates to:
  /// **'Card removed.'**
  String get cardRemovedMsg;

  /// No description provided for @expiresTitle.
  ///
  /// In en, this message translates to:
  /// **'EXPIRES'**
  String get expiresTitle;

  /// No description provided for @payoutBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Payout Bank Account'**
  String get payoutBankAccount;

  /// No description provided for @paymentMethodsTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethodsTitle;

  /// No description provided for @addCardButton.
  ///
  /// In en, this message translates to:
  /// **'Add Card'**
  String get addCardButton;

  /// No description provided for @membershipStarterTier.
  ///
  /// In en, this message translates to:
  /// **'Starter Tier'**
  String get membershipStarterTier;

  /// No description provided for @membershipProTrainee.
  ///
  /// In en, this message translates to:
  /// **'Pro Trainee'**
  String get membershipProTrainee;

  /// No description provided for @membershipEliteCoaching.
  ///
  /// In en, this message translates to:
  /// **'Elite Coaching'**
  String get membershipEliteCoaching;

  /// No description provided for @showingResultsCount.
  ///
  /// In en, this message translates to:
  /// **'Showing {count} Results'**
  String showingResultsCount(int count);

  /// No description provided for @exportAction.
  ///
  /// In en, this message translates to:
  /// **'EXPORT'**
  String get exportAction;

  /// No description provided for @filterParam.
  ///
  /// In en, this message translates to:
  /// **'Filter: {value}'**
  String filterParam(String value);

  /// No description provided for @sortParam.
  ///
  /// In en, this message translates to:
  /// **'Sort: {value}'**
  String sortParam(String value);

  /// No description provided for @noReviewsMatch.
  ///
  /// In en, this message translates to:
  /// **'No reviews match these filters.'**
  String get noReviewsMatch;

  /// No description provided for @reportProfile.
  ///
  /// In en, this message translates to:
  /// **'Report Profile'**
  String get reportProfile;

  /// No description provided for @selectReason.
  ///
  /// In en, this message translates to:
  /// **'Select a reason'**
  String get selectReason;

  /// No description provided for @beMoreSpecificTitle.
  ///
  /// In en, this message translates to:
  /// **'Be more specific (optional)'**
  String get beMoreSpecificTitle;

  /// No description provided for @submitReport.
  ///
  /// In en, this message translates to:
  /// **'Submit Report'**
  String get submitReport;

  /// No description provided for @autoPlayingIntro.
  ///
  /// In en, this message translates to:
  /// **'Auto-Playing Intro...'**
  String get autoPlayingIntro;

  /// No description provided for @whereTrainerWorks.
  ///
  /// In en, this message translates to:
  /// **'Where this trainer works in real life'**
  String get whereTrainerWorks;

  /// No description provided for @mapDetectionInstructions.
  ///
  /// In en, this message translates to:
  /// **'Zoom into your location exactly or search your place by name up there, then click Add'**
  String get mapDetectionInstructions;

  /// No description provided for @openInMaps.
  ///
  /// In en, this message translates to:
  /// **'Open in Maps'**
  String get openInMaps;

  /// No description provided for @noActiveMemberships.
  ///
  /// In en, this message translates to:
  /// **'No Active Memberships'**
  String get noActiveMemberships;

  /// No description provided for @noActiveMembershipsDesc.
  ///
  /// In en, this message translates to:
  /// **'You are not currently subscribed to any membership plan. Browse available trainers and subscribe to a plan to unlock exclusive content, personalised coaching, and more.'**
  String get noActiveMembershipsDesc;

  /// No description provided for @browsePlans.
  ///
  /// In en, this message translates to:
  /// **'Browse Plans'**
  String get browsePlans;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Something Went Wrong'**
  String get errorOccurred;

  /// No description provided for @error404Title.
  ///
  /// In en, this message translates to:
  /// **'Page Not Found'**
  String get error404Title;

  /// No description provided for @error404Desc.
  ///
  /// In en, this message translates to:
  /// **'The page you are looking for does not exist or has been moved. Please check the URL or navigate back to the home screen.'**
  String get error404Desc;

  /// No description provided for @errorGenericDesc.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. This may be caused by a network issue, a temporary server outage, or an application fault. Please try again shortly.'**
  String get errorGenericDesc;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go Back'**
  String get goBack;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @unfollowed.
  ///
  /// In en, this message translates to:
  /// **'Unfollowed'**
  String get unfollowed;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @diet.
  ///
  /// In en, this message translates to:
  /// **'Diet'**
  String get diet;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @duplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get duplicate;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'Meals'**
  String get meals;

  /// No description provided for @nameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required.'**
  String get nameRequired;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @dietType.
  ///
  /// In en, this message translates to:
  /// **'Diet Type'**
  String get dietType;

  /// No description provided for @trainingPlanBuilder.
  ///
  /// In en, this message translates to:
  /// **'Training Plan Builder'**
  String get trainingPlanBuilder;

  /// No description provided for @programmeName.
  ///
  /// In en, this message translates to:
  /// **'Programme Name'**
  String get programmeName;

  /// No description provided for @targetGoal.
  ///
  /// In en, this message translates to:
  /// **'Target Goal'**
  String get targetGoal;

  /// No description provided for @programmeColor.
  ///
  /// In en, this message translates to:
  /// **'Programme Color'**
  String get programmeColor;

  /// No description provided for @cycleType.
  ///
  /// In en, this message translates to:
  /// **'Cycle Type'**
  String get cycleType;

  /// No description provided for @microcycle.
  ///
  /// In en, this message translates to:
  /// **'Microcycle'**
  String get microcycle;

  /// No description provided for @mesocycle.
  ///
  /// In en, this message translates to:
  /// **'Mesocycle'**
  String get mesocycle;

  /// No description provided for @macrocycle.
  ///
  /// In en, this message translates to:
  /// **'Macrocycle'**
  String get macrocycle;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @workoutDays.
  ///
  /// In en, this message translates to:
  /// **'Workout Days'**
  String get workoutDays;

  /// No description provided for @addDay.
  ///
  /// In en, this message translates to:
  /// **'Add Day'**
  String get addDay;

  /// No description provided for @noWorkoutDaysYet.
  ///
  /// In en, this message translates to:
  /// **'No workout days yet. Add a day to start building this plan.'**
  String get noWorkoutDaysYet;

  /// No description provided for @addExercise.
  ///
  /// In en, this message translates to:
  /// **'Add Exercise'**
  String get addExercise;

  /// No description provided for @noExercisesInDay.
  ///
  /// In en, this message translates to:
  /// **'No exercises in this day yet.'**
  String get noExercisesInDay;

  /// No description provided for @restTime.
  ///
  /// In en, this message translates to:
  /// **'Rest Time'**
  String get restTime;

  /// No description provided for @rpe.
  ///
  /// In en, this message translates to:
  /// **'RPE'**
  String get rpe;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @searchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get searchExercises;

  /// No description provided for @trainingType.
  ///
  /// In en, this message translates to:
  /// **'Training Type'**
  String get trainingType;

  /// No description provided for @targetBodyPart.
  ///
  /// In en, this message translates to:
  /// **'Target Body Part'**
  String get targetBodyPart;

  /// No description provided for @noExercisesFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises match these filters.'**
  String get noExercisesFound;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @untitledProgramme.
  ///
  /// In en, this message translates to:
  /// **'Untitled Programme'**
  String get untitledProgramme;

  /// No description provided for @noGoalSet.
  ///
  /// In en, this message translates to:
  /// **'No goal set'**
  String get noGoalSet;

  /// No description provided for @daysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @exercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String exercisesCount(int count);

  /// No description provided for @catStrength.
  ///
  /// In en, this message translates to:
  /// **'Strength & Muscle Building'**
  String get catStrength;

  /// No description provided for @goalBodybuildingTitle.
  ///
  /// In en, this message translates to:
  /// **'Bodybuilding'**
  String get goalBodybuildingTitle;

  /// No description provided for @goalBodybuildingDesc.
  ///
  /// In en, this message translates to:
  /// **'A highly structured training style centred on progressive resistance to maximise muscle growth (hypertrophy) and refine physical proportions. It utilises a combination of compound movements and isolation exercises to target specific muscle groups, aiming for aesthetic symmetry, low body fat, and muscular definition.'**
  String get goalBodybuildingDesc;

  /// No description provided for @goalPowerliftingTitle.
  ///
  /// In en, this message translates to:
  /// **'Powerlifting'**
  String get goalPowerliftingTitle;

  /// No description provided for @goalPowerliftingDesc.
  ///
  /// In en, this message translates to:
  /// **'A strength sport focusing entirely on maximising the amount of weight a person can lift for a single repetition (1-Rep Max) in three specific barbell exercises: the squat, the bench press, and the deadlift. Training prioritises low repetitions, heavy loads, and central nervous system adaptation over muscle size.'**
  String get goalPowerliftingDesc;

  /// No description provided for @goalOlympicTitle.
  ///
  /// In en, this message translates to:
  /// **'Olympic Weightlifting'**
  String get goalOlympicTitle;

  /// No description provided for @goalOlympicDesc.
  ///
  /// In en, this message translates to:
  /// **'A dynamic and highly technical discipline centred on explosive power, speed, and mobility. Athletes train to master two fast-paced overhead barbell lifts: the snatch and the clean-and-jerk. It requires significant joint flexibility, core stability, and precise technique to drop under a heavy bar quickly.'**
  String get goalOlympicDesc;

  /// No description provided for @goalStrongmanTitle.
  ///
  /// In en, this message translates to:
  /// **'Strongman'**
  String get goalStrongmanTitle;

  /// No description provided for @goalStrongmanDesc.
  ///
  /// In en, this message translates to:
  /// **'A varied, functional strength discipline that tests an athlete\'s raw power and endurance using heavy, awkward, and non-traditional implements. Common exercises include lifting Atlas stones, pulling sledges, carrying heavy yokes, and pressing logs, translating gym strength into real-world lifting capabilities.'**
  String get goalStrongmanDesc;

  /// No description provided for @catAthletic.
  ///
  /// In en, this message translates to:
  /// **'Athletic & Functional Training'**
  String get catAthletic;

  /// No description provided for @goalSportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Sports Performance'**
  String get goalSportsTitle;

  /// No description provided for @goalSportsDesc.
  ///
  /// In en, this message translates to:
  /// **'Conditioning programs meticulously tailored to the specific physical demands of a competitive sport. This training emphasises explosive power, multidirectional agility, reaction time, and injury prevention, ensuring an athlete peaks physically for their specific season or event.'**
  String get goalSportsDesc;

  /// No description provided for @goalFunctionalTitle.
  ///
  /// In en, this message translates to:
  /// **'Functional Fitness'**
  String get goalFunctionalTitle;

  /// No description provided for @goalFunctionalDesc.
  ///
  /// In en, this message translates to:
  /// **'A constantly varied, high-intensity training methodology designed to prepare the body for any physical contingency. It blends elements of aerobic conditioning, gymnastics, and weightlifting to improve overall work capacity, stamina, and everyday physical readiness.'**
  String get goalFunctionalDesc;

  /// No description provided for @goalCallisthenicsTitle.
  ///
  /// In en, this message translates to:
  /// **'Callisthenics'**
  String get goalCallisthenicsTitle;

  /// No description provided for @goalCallisthenicsDesc.
  ///
  /// In en, this message translates to:
  /// **'A form of strength training that utilises the practitioner\'s own body weight and gravity as resistance. It emphasises mastering movement through space, starting with basics like push-ups and pull-ups, and progressing to advanced isometric holds requiring immense core control, such as planches and front levers.'**
  String get goalCallisthenicsDesc;

  /// No description provided for @goalCombatTitle.
  ///
  /// In en, this message translates to:
  /// **'Combat Sports Conditioning'**
  String get goalCombatTitle;

  /// No description provided for @goalCombatDesc.
  ///
  /// In en, this message translates to:
  /// **'Specialised physical preparation for martial arts, boxing, and wrestling. It focuses on building the stamina needed for continuous high-intensity rounds, enhancing rotational core power for striking, and developing the grip and neck strength required for grappling.'**
  String get goalCombatDesc;

  /// No description provided for @catRecovery.
  ///
  /// In en, this message translates to:
  /// **'Recovery & Movement Health'**
  String get catRecovery;

  /// No description provided for @goalCorrectiveTitle.
  ///
  /// In en, this message translates to:
  /// **'Corrective Exercises'**
  String get goalCorrectiveTitle;

  /// No description provided for @goalCorrectiveDesc.
  ///
  /// In en, this message translates to:
  /// **'A systematic approach to identifying and addressing physical imbalances, poor posture, and movement compensations. By selectively stretching tight muscles and strengthening weak ones, this discipline helps alleviate chronic pain and retrains the body to move efficiently.'**
  String get goalCorrectiveDesc;

  /// No description provided for @goalRehabilitationTitle.
  ///
  /// In en, this message translates to:
  /// **'Rehabilitation'**
  String get goalRehabilitationTitle;

  /// No description provided for @goalRehabilitationDesc.
  ///
  /// In en, this message translates to:
  /// **'Highly structured, progressive exercise protocols are prescribed to help individuals recover safely from injuries, surgeries, or physical trauma. The primary goal is to safely restore the lost range of motion, rebuild atrophied muscles, and return the user to their baseline physical function.'**
  String get goalRehabilitationDesc;

  /// No description provided for @goalMobilityTitle.
  ///
  /// In en, this message translates to:
  /// **'Mobility Training'**
  String get goalMobilityTitle;

  /// No description provided for @goalMobilityDesc.
  ///
  /// In en, this message translates to:
  /// **'A practice focused on actively controlling the body through its full range of motion. Unlike passive stretching, mobility work requires strength and stability at the end ranges of a joint\'s movement, which keeps joints healthy, prevents injury, and improves overall movement quality.'**
  String get goalMobilityDesc;

  /// No description provided for @catCardio.
  ///
  /// In en, this message translates to:
  /// **'Cardiovascular & Endurance'**
  String get catCardio;

  /// No description provided for @goalHiitTitle.
  ///
  /// In en, this message translates to:
  /// **'HIIT (High-Intensity Interval Training)'**
  String get goalHiitTitle;

  /// No description provided for @goalHiitDesc.
  ///
  /// In en, this message translates to:
  /// **'A time-efficient cardiovascular methodology alternating between short bursts of near-maximum effort and periods of active recovery or rest. It forces the heart rate to spike quickly, improving cardiovascular capacity, metabolic rate, and caloric burn long after the workout ends.'**
  String get goalHiitDesc;

  /// No description provided for @goalEnduranceTitle.
  ///
  /// In en, this message translates to:
  /// **'Endurance Training'**
  String get goalEnduranceTitle;

  /// No description provided for @goalEnduranceDesc.
  ///
  /// In en, this message translates to:
  /// **'Steady-state, aerobic exercise designed to be sustained over long periods. Activities like marathon running, long-distance cycling, or swimming train the heart to pump blood more efficiently and increase the muscles\' ability to utilise oxygen, building deep, long-lasting stamina.'**
  String get goalEnduranceDesc;

  /// No description provided for @catMindbody.
  ///
  /// In en, this message translates to:
  /// **'Mind-Body & Core'**
  String get catMindbody;

  /// No description provided for @goalYogaTitle.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get goalYogaTitle;

  /// No description provided for @goalYogaDesc.
  ///
  /// In en, this message translates to:
  /// **'A comprehensive practice that links physical postures with controlled breathing and mental focus. It improves flexibility, balance, and core strength while actively engaging the parasympathetic nervous system to reduce stress and enhance the mind-body connection.'**
  String get goalYogaDesc;

  /// No description provided for @goalPilatesTitle.
  ///
  /// In en, this message translates to:
  /// **'Pilates'**
  String get goalPilatesTitle;

  /// No description provided for @goalPilatesDesc.
  ///
  /// In en, this message translates to:
  /// **'A precision-based training method primarily focused on the deep abdominal core, pelvic floor, and spinal stabilising muscles. Whether performed on a mat or specialised equipment, it emphasises controlled, low-impact movements to improve posture, body alignment, and deep muscular endurance.'**
  String get goalPilatesDesc;

  /// No description provided for @catSpecialised.
  ///
  /// In en, this message translates to:
  /// **'Specialised Programs'**
  String get catSpecialised;

  /// No description provided for @goalPrenatalTitle.
  ///
  /// In en, this message translates to:
  /// **'Pre & Postnatal Fitness'**
  String get goalPrenatalTitle;

  /// No description provided for @goalPrenatalDesc.
  ///
  /// In en, this message translates to:
  /// **'Carefully modified exercise routines designed to safely navigate the biomechanical changes of pregnancy. It focuses on maintaining strength, reducing back pain, and safely rebuilding core stability and pelvic floor function during postpartum recovery.'**
  String get goalPrenatalDesc;

  /// No description provided for @goalSeniorTitle.
  ///
  /// In en, this message translates to:
  /// **'Senior Fitness'**
  String get goalSeniorTitle;

  /// No description provided for @goalSeniorDesc.
  ///
  /// In en, this message translates to:
  /// **'Exercise programming specifically tailored for ageing populations. It prioritises resistance training to combat age-related muscle loss, weight-bearing exercises to maintain bone density, and balance drills to prevent falls and sustain independent living.'**
  String get goalSeniorDesc;

  /// No description provided for @goalYouthTitle.
  ///
  /// In en, this message translates to:
  /// **'Youth Fitness'**
  String get goalYouthTitle;

  /// No description provided for @goalYouthDesc.
  ///
  /// In en, this message translates to:
  /// **'Age-appropriate developmental programming for children and teenagers. It focuses on teaching fundamental movement patterns, developing neuromuscular coordination, and fostering a healthy, lifelong relationship with physical activity without applying excessive loads to growing bones.'**
  String get goalYouthDesc;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
