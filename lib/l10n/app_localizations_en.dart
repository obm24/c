// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'TnT';

  @override
  String get login => 'LOGIN';

  @override
  String get logoutConfirmation => 'Are you sure you want to log out?';

  @override
  String get register => 'Register';

  @override
  String get registerAction => 'CREATE ACCOUNT';

  @override
  String get id => 'Username or E-mail';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get sendResetLink => 'SEND RESET LINK';

  @override
  String get idOrEmail => 'Username or E-mail';

  @override
  String get trainee => 'Trainee';

  @override
  String get trainer => 'Trainer';

  @override
  String get metric => 'Metric';

  @override
  String get imperial => 'Imperial';

  @override
  String get accountInfo => 'Account Information';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get username => 'Username';

  @override
  String get invalidUsernameError => 'Must be 4–19 alphanumeric characters.';

  @override
  String get emailAddress => 'E-mail Address';

  @override
  String get invalidEmailError => 'Must be a valid e-mail address.';

  @override
  String get invalidPasswordError =>
      'Must contain 8 characters (1 uppercase, 1 lowercase, a number, and a special character).';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get passwordMismatchError => 'Must match the password above.';

  @override
  String get firstName => 'First Name';

  @override
  String get lastName => 'Last Name';

  @override
  String get invalidNameError => 'Must contain at least 2 letters.';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get invalidPhoneError => 'Must be a valid phone number.';

  @override
  String get invalidMobileCountryWarning =>
      'Please enter a valid mobile number matching your country\'s required format and network prefix.';

  @override
  String get phoneDialCodeRequiredWarning =>
      'Select a dial code, then enter your mobile number.';

  @override
  String get phoneUnknownCountry => 'This country';

  @override
  String phoneDigitsExact(String count) {
    return '$count digits';
  }

  @override
  String phoneDigitsRange(String min, String max) {
    return '$min-$max digits';
  }

  @override
  String get phoneDigitsRequired => 'the required digits';

  @override
  String phoneAfterCallingCode(String callingCode) {
    return ' after $callingCode';
  }

  @override
  String phonePrefixRequirement(String prefixes) {
    return ' and start with $prefixes';
  }

  @override
  String phoneCurrentDigits(String actual, String target) {
    return 'Current digits: $actual/$target';
  }

  @override
  String phoneMobileValidationWarning(
    String country,
    String digitPart,
    String after,
    String prefixPart,
    String currentDigits,
  ) {
    return '$country mobile numbers must contain $digitPart$after$prefixPart.\n$currentDigits';
  }

  @override
  String get listOr => 'or';

  @override
  String get dateOfBirth => 'Date of Birth';

  @override
  String get ageError => 'You must be at least 16 years old to register.';

  @override
  String get dateOfBirthRequired => 'Please select your date of birth.';

  @override
  String get minimumAgeRegistrationWarning =>
      'You must be at least 16 years old to register.';

  @override
  String get yearsOld => 'years';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get genderSelectionError => 'Please select a gender.';

  @override
  String get nationality => 'Nationality';

  @override
  String get nationalitySelectionError => 'Please select a nationality.';

  @override
  String get height => 'Height';

  @override
  String get physicalTrainingExperience => 'Training Experience';

  @override
  String get trainingExperienceRequired =>
      'Please select your training experience.';

  @override
  String get trainingExperienceSelected => 'Training experience selected.';

  @override
  String get trainingExperienceHelpTooltip =>
      'Explain training experience levels.';

  @override
  String get trainingExperienceDialogTitle => 'Training Experience';

  @override
  String get trainingExperienceDialogIntro =>
      'Select the option that best reflects your own consistent, structured physical training as a trainee. Count time spent following planned strength, conditioning, sport, mobility, or fitness routines. Do not count professional coaching experience, casual activity without structure, or long breaks as active training time.';

  @override
  String get experienceLevelZeroYears => '0 Years';

  @override
  String get experienceLevelOneToTwoYears => '1\u20132 Years';

  @override
  String get experienceLevelThreeToFiveYears => '3\u20135 Years';

  @override
  String get experienceLevelSixToNineYears => '6\u20139 Years';

  @override
  String get experienceLevelTenPlusYears => '10+ Years';

  @override
  String get experienceLevelZeroYearsDescription =>
      'Choose this if you have not yet trained consistently with a planned routine, or if your activity has mostly been occasional, informal, or shorter than a few continuous months.';

  @override
  String get experienceLevelOneToTwoYearsDescription =>
      'Choose this if you have built a basic routine and understand common exercises, but you are still developing consistency, technique, recovery habits, and confidence with progression.';

  @override
  String get experienceLevelThreeToFiveYearsDescription =>
      'Choose this if you have trained consistently across multiple phases or goals, can follow structured programmes, and understand basic progression, exercise selection, and form standards.';

  @override
  String get experienceLevelSixToNineYearsDescription =>
      'Choose this if training has been a stable part of your lifestyle for several years, with strong body awareness, exposure to different training methods, and the ability to manage intensity and recovery.';

  @override
  String get experienceLevelTenPlusYearsDescription =>
      'Choose this if you have a long-term training history across many seasons, programmes, or life phases, and your experience gives you a clear understanding of your capabilities, limitations, and preferences.';

  @override
  String get selectMeasurementUnitsBeforeHeight =>
      'Select measurement units before entering your height.';

  @override
  String get selectMeasurementUnitsBeforeWeight =>
      'Select measurement units before entering your weight.';

  @override
  String heightBoundaryWarning(String min, String max, String unit) {
    final suffix = unit.trim().isEmpty ? '' : ' $unit';
    return 'Height must be between $min and $max$suffix.';
  }

  @override
  String weightBoundaryWarning(String min, String max, String unit) {
    final suffix = unit.trim().isEmpty ? '' : ' $unit';
    return 'Weight must be between $min and $max$suffix.';
  }

  @override
  String get fieldLooksGood => 'Looks good.';

  @override
  String get selectionLooksGood => 'Selection complete.';

  @override
  String get registrationRoleRequired =>
      'Please select whether you are registering as a trainee or trainer.';

  @override
  String get selectCountry => 'Please select your country.';

  @override
  String get measurementUnitsRequired =>
      'Please select metric or imperial units.';

  @override
  String get dateOfBirthSelected => 'Date of birth selected.';

  @override
  String get genderSelected => 'Gender selected.';

  @override
  String get measurementUnitsSelected => 'Measurement units selected.';

  @override
  String get traineeProfile => 'Trainee Profile';

  @override
  String get traineeProfileRegistrationIntro =>
      'Help trainers understand your goals, training background, and nutrition preferences.';

  @override
  String get trainingGoals => 'Training Goals';

  @override
  String get chooseTrainingGoals => 'Choose your training goals';

  @override
  String get trainingGoalRequired =>
      'Please select at least one training goal.';

  @override
  String get choosePreferredDiets => 'Choose preferred diets';

  @override
  String get preferredDietRequired =>
      'Please select at least one preferred diet.';

  @override
  String get metricHeightError => 'Must be between 55–272 cm.';

  @override
  String get imperialHeightError => 'Must be between 1\' 9\" and 8\' 11\".';

  @override
  String get weight => 'Weight';

  @override
  String get invalidMeasurementWarning =>
      'Please enter a physically valid measurement.';

  @override
  String realisticHeightWarning(String unit) {
    return 'Please enter a realistic height in $unit.';
  }

  @override
  String realisticWeightWarning(String unit) {
    return 'Please enter a realistic weight in $unit.';
  }

  @override
  String get metricWeightError => 'Must be between 30–635 kg.';

  @override
  String get imperialWeightError => 'Must be between 66–1,400 lbs.';

  @override
  String get confirm => 'Confirm';

  @override
  String get cancel => 'Cancel';

  @override
  String get cancelRegistrationTitle => 'Cancel registration?';

  @override
  String get cancelRegistrationMessage =>
      'Are you sure you want to cancel? All progress will be lost.';

  @override
  String get keepEditing => 'Keep Editing';

  @override
  String get discardProgress => 'Discard Progress';

  @override
  String get saveChanges => 'SAVE CHANGES';

  @override
  String get saveData => 'SAVE DATA';

  @override
  String get saveMeasurements => 'SAVE MEASUREMENTS';

  @override
  String get save => 'Save';

  @override
  String get done => 'Done';

  @override
  String get edit => 'Edit';

  @override
  String get remove => 'Remove';

  @override
  String get delete => 'Delete';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get payments => 'Payments';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Log Out';

  @override
  String get menu => 'Menu';

  @override
  String get dashboardWelcomeCoach => 'Welcome back, Coach!';

  @override
  String get dashboardWelcomeTrainee => 'Welcome back, Trainee!';

  @override
  String get trainingSchedule => 'Training Schedule';

  @override
  String get viewWeeklyPlan => 'View your weekly plan';

  @override
  String get dietProgramme => 'Diet Programme';

  @override
  String get yourNutritionPlan => 'Your nutrition plan';

  @override
  String get messageTrainers => 'Message Trainer(s)';

  @override
  String get clients => 'Clients';

  @override
  String get programmes => 'Programmes';

  @override
  String get templates => 'Templates';

  @override
  String get forms => 'Forms';

  @override
  String get products => 'Products';

  @override
  String get posts => 'Posts';

  @override
  String get content => 'Content';

  @override
  String get analytics => 'Analytics';

  @override
  String get inviteTrainee => 'Invite Trainee';

  @override
  String get addTrainee => 'Add Trainee';

  @override
  String get managePayouts => 'Manage Payouts';

  @override
  String get managePayoutsDesc =>
      'Select and configure your preferred platform to send and receive payments.';

  @override
  String get managePayoutsTrainerDesc =>
      'Link your local bank to withdraw earnings securely.';

  @override
  String get managePaymentMethods => 'Manage Payment Methods';

  @override
  String get managePaymentMethodsDesc =>
      'Add a card to pay for memberships and extras securely.';

  @override
  String get bankTransfer => 'Bank Transfer';

  @override
  String get paypal => 'PayPal';

  @override
  String get bankName => 'Bank Name';

  @override
  String get ibanLabel => 'IBAN';

  @override
  String get accountNumberLabel => 'Account Number';

  @override
  String get swiftCodeLabel => 'SWIFT Code';

  @override
  String get paypalEmailLabel => 'PayPal E-mail Address';

  @override
  String get financialsSavedSuccess => 'Financial details saved successfully!';

  @override
  String get bodyComposition => 'Body Composition';

  @override
  String get circumferences => 'Circumferences';

  @override
  String get medicalStatus => 'Medical Status';

  @override
  String get currentInjuries => 'Current Injuries';

  @override
  String get pastInjuries => 'Past Injuries';

  @override
  String get medicalConditions => 'Medical Conditions';

  @override
  String get dietaryApproach => 'Dietary Approach';

  @override
  String get healthAndMedical => 'Health & Medical';

  @override
  String get noneReported => 'None reported';

  @override
  String get flexibleNoRestrictions => 'Flexible / No Restrictions';

  @override
  String get accountCreatedSuccess => 'Account created successfully!';

  @override
  String get resetPasswordInstructions =>
      'Enter your registered username or e-mail. We will send you instructions to reset your password.';

  @override
  String get resetLinkSent => 'Reset link sent!';

  @override
  String get profileSavedSuccess => 'Profile saved successfully!';

  @override
  String get profileImageUpdated => 'Profile picture updated!';

  @override
  String get close => 'CLOSE';

  @override
  String get descriptionNotAvailable => 'Description not available.';

  @override
  String get changeEmail => 'Change E-mail';

  @override
  String get changePassword => 'Change Password';

  @override
  String get advertisement => 'Advertisement';

  @override
  String get bodyWeight => 'Body Weight';

  @override
  String get bodyMassIndex => 'Body Mass Index (BMI)';

  @override
  String get totalBodyWater => 'Total Body Water (TBW)';

  @override
  String get intracellularWater => 'Intracellular Water (ICW)';

  @override
  String get extracellularWater => 'Extracellular Water (ECW)';

  @override
  String get skeletalMuscleMass => 'Skeletal Muscle Mass (SMM)';

  @override
  String get softLeanMass => 'Soft Lean Mass (SLM)';

  @override
  String get fatFreeMass => 'Fat Free Mass (FFM)';

  @override
  String get fatMeasurements => 'Fat Measurements';

  @override
  String get bodyFatMass => 'Body Fat Mass (BFM)';

  @override
  String get bodyFatPercentage => 'Body Fat Percentage (PBF)';

  @override
  String get subcutaneousFatMass => 'Subcutaneous Fat Mass';

  @override
  String get segmentalLeanMass => 'Segmental Lean Mass';

  @override
  String get rightArm => 'Right Arm';

  @override
  String get leftArm => 'Left Arm';

  @override
  String get trunk => 'Trunk';

  @override
  String get rightLeg => 'Right Leg';

  @override
  String get leftLeg => 'Left Leg';

  @override
  String get bodyCompositionSaved => 'Body Composition Saved!';

  @override
  String get upperBody => 'Upper Body';

  @override
  String get neck => 'Neck';

  @override
  String get shoulder => 'Shoulder';

  @override
  String get shoulders => 'Shoulders';

  @override
  String get chest => 'Chest';

  @override
  String get arm => 'Arm';

  @override
  String get arms => 'Arms';

  @override
  String get forearm => 'Forearm';

  @override
  String get forearms => 'Forearms';

  @override
  String get waist => 'Waist';

  @override
  String get hips => 'Hips';

  @override
  String get lowerBody => 'Lower Body';

  @override
  String get thigh => 'Thigh';

  @override
  String get thighs => 'Thighs';

  @override
  String get calf => 'Calf';

  @override
  String get calves => 'Calves';

  @override
  String get measurementsSaved => 'Measurements Saved!';

  @override
  String get allSeriesHidden => 'All series hidden.';

  @override
  String get tapBodyPartToShowSeries => 'Tap a body part button to show one.';

  @override
  String get disable => 'Disable';

  @override
  String get disableConfirmation => 'Are you sure you want to turn off';

  @override
  String get disableAction => 'DISABLE';

  @override
  String get pairedSuccessfully => 'Successfully paired with device!';

  @override
  String get scanningDevices => 'Scanning for nearby devices…';

  @override
  String get ensureBluetoothEnabled => 'Please ensure Bluetooth is enabled.';

  @override
  String get unitPreferences => 'Unit Preferences';

  @override
  String get weightUnits => 'Weight Units';

  @override
  String get weightUnitsDesc =>
      'Choose your preferred unit for tracking body weight and lifting milestones.';

  @override
  String get lengthAndDistance => 'Length & Distance';

  @override
  String get lengthAndDistanceDesc =>
      'Select the unit for measuring running, walking, and other distance-based cardio.';

  @override
  String get bodyMeasurements => 'Body Measurements';

  @override
  String get bodyMeasurementsDesc =>
      'Set the unit for logging body proportions like waist, chest, and arm circumferences.';

  @override
  String get integrations => 'Integrations';

  @override
  String get syncHealthData => 'Sync Health Data';

  @override
  String get syncHealthDataDesc =>
      'Ensure your trainer has accurate data to optimise your fitness journey.';

  @override
  String get paired => 'PAIRED';

  @override
  String get pair => 'PAIR';

  @override
  String get trainerAvailability => 'Trainer Availability';

  @override
  String get holidayMode => 'Holiday Mode';

  @override
  String get holidayModeDesc =>
      'Block out calendar dates to prevent new bookings.';

  @override
  String get current => 'Current';

  @override
  String get unavailableMode => 'Unavailable Mode';

  @override
  String get unavailableModeDesc =>
      'Prevent all incoming requests to avoid overwhelm.';

  @override
  String get pageComingSoon => 'Page Coming Soon';

  @override
  String get ageLabel => 'Age:';

  @override
  String get dayLabel => 'Day';

  @override
  String get targetMuscleLabel => 'Target Muscle';

  @override
  String get exerciseLabel => 'Exercise';

  @override
  String get setsLabel => 'Sets';

  @override
  String get repsLabel => 'Reps';

  @override
  String get mealLabel => 'Meal';

  @override
  String get timeLabel => 'Time';

  @override
  String get foodItemsLabel => 'Food Items';

  @override
  String get caloriesLabel => 'Calories (kcal)';

  @override
  String get proteinLabel => 'Protein (g)';

  @override
  String get externalLinkWarning => 'External Link Warning';

  @override
  String get externalLinkDisclaimer =>
      'This link was sent in a chat and is not affiliated with TnT. Proceed at your own risk:';

  @override
  String get proceed => 'PROCEED';

  @override
  String get incorrectCredentials => 'Incorrect credentials.';

  @override
  String get incorrectUsername => 'Incorrect username.';

  @override
  String get incorrectEmail => 'Incorrect e-mail.';

  @override
  String get incorrectPassword => 'Incorrect password.';

  @override
  String get monday => 'Monday';

  @override
  String get tuesday => 'Tuesday';

  @override
  String get wednesday => 'Wednesday';

  @override
  String get thursday => 'Thursday';

  @override
  String get rest => 'Rest';

  @override
  String get legs => 'Legs';

  @override
  String get back => 'Back';

  @override
  String get breakfast => 'Breakfast';

  @override
  String get snack1 => 'Snack 1';

  @override
  String get lunch => 'Lunch';

  @override
  String get snack2 => 'Snack 2';

  @override
  String get dinner => 'Dinner';

  @override
  String get shareProfile => 'Share Profile';

  @override
  String get copyUrl => 'Copy URL';

  @override
  String get urlCopied => 'URL copied to clipboard.';

  @override
  String get showQrCode => 'Show QR Code';

  @override
  String get scanToView => 'Scan to View Profile';

  @override
  String get primaryGoal => 'Primary Goal';

  @override
  String get healthAndMetrics => 'Health & Metrics';

  @override
  String get preferredDiet => 'Preferred Diet';

  @override
  String get addYourCard => 'Add your card';

  @override
  String get fillCardFields =>
      'Fill in the fields below or use your camera phone.';

  @override
  String get cardNumber => 'Your card number';

  @override
  String get expiryDate => 'Expiry date';

  @override
  String get cvv2 => 'CVV2';

  @override
  String get scanCard => 'Scan card info by camera';

  @override
  String get addFaceId => 'Add Face ID';

  @override
  String get viewTransactions => 'View Transactions';

  @override
  String get transactions => 'Transactions';

  @override
  String get searchTransactions => 'Search for transaction(s)…';

  @override
  String get professionalInfo => 'Professional Information';

  @override
  String get identificationNumber => 'Identification Number (ID)';

  @override
  String get invalidIdNumberError => 'Must be 7–18 alphanumeric characters.';

  @override
  String get uploadId => 'Upload ID';

  @override
  String get uploadIdDocument => 'Upload ID Document';

  @override
  String get idDocumentRequiredWarning =>
      'A valid ID document is required to proceed with trainer verification.';

  @override
  String get idUploadedSuccessfully => 'ID Uploaded Successfully';

  @override
  String get idScanInstructions =>
      'Provide a clear scan of the front and back of your ID.';

  @override
  String get uploadFromDevice => 'Upload from device';

  @override
  String get scanViaCamera => 'Scan via camera';

  @override
  String get professionalSpecialities => 'Professional Specialities';

  @override
  String get addSpecialities => 'Add Specialities';

  @override
  String get specialityRequired => 'At least one speciality is required.';

  @override
  String get specialities => 'Specialities';

  @override
  String get credentials => 'Credentials';

  @override
  String get credentialExplanation =>
      'Select your certifying organisation and the certificate issued. A valid Certificate ID is mandatory for verification.';

  @override
  String get addCredential => 'Add Credential';

  @override
  String get addAnotherCertificateFromOrganisation =>
      'Add another certificate from this organisation';

  @override
  String get credentialRequired => 'At least one credential is required.';

  @override
  String get saveAllCredentials => 'Save all credentials before submitting.';

  @override
  String get removeCredentialConfirmation =>
      'Are you sure you want to remove this credential?';

  @override
  String get certificate => 'Certificate';

  @override
  String get certificateId => 'Certificate ID';

  @override
  String get certificateIdRequired =>
      'Certificate ID is required (minimum 3 characters using letters, numbers, hyphens, or slashes).';

  @override
  String get selectOrganisation => 'Select Organisation';

  @override
  String get selectCertificate => 'Select Certificate';

  @override
  String get allCertificatesInUse =>
      'All certificates for this organisation are already in use.';

  @override
  String credentialLimitReached(String organization, String count) {
    return 'You have reached the maximum of $count certificates for $organization.';
  }

  @override
  String get organisation => 'Organisation';

  @override
  String get organisationRequired => 'Organisation is required.';

  @override
  String get certificateRequired => 'Certificate is required.';

  @override
  String get verifiedCredential => 'Verified Credential';

  @override
  String get placesOfEmployment => 'Places of Employment';

  @override
  String get locationRequired => 'Add at least one physical location.';

  @override
  String get addLocation => 'Add Location';

  @override
  String get editLocation => 'Edit Location';

  @override
  String get locationType => 'Location Type';

  @override
  String get facilityName => 'Facility Name';

  @override
  String get streetAddress => 'Street Address';

  @override
  String get removeLocation => 'Remove Location';

  @override
  String get hybridTraining => 'Hybrid Personal Training';

  @override
  String get hybridTrainingDesc =>
      'You train clients both in physical locations and online, offering maximum flexibility and reach.';

  @override
  String get onlineOnlyTraining => 'Only Online Personal Training';

  @override
  String get onlineOnlyTrainingDesc =>
      'You operate exclusively through online coaching and do not train clients in physical locations.';

  @override
  String get inPersonOnlyTraining => 'Only In-Person Personal Training';

  @override
  String get inPersonOnlyTrainingDesc =>
      'You exclusively train clients face-to-face at physical venues such as gyms, studios, or outdoor spaces.';

  @override
  String get countryOfEmployment => 'Country of Employment';

  @override
  String get countryOfResidence => 'Country of Residence';

  @override
  String get selectCountryEmployment =>
      'Please select your country of employment.';

  @override
  String get selectCountryResidence =>
      'Please select your country of residence.';

  @override
  String get workout => 'Workout';

  @override
  String get explore => 'Explore';

  @override
  String get feed => 'Feed';

  @override
  String get searchTrainersTrainees => 'Search for trainers or trainees…';

  @override
  String get noResultsFound => 'No results found.';

  @override
  String get mockUserNoProfile =>
      'This mock user has no public profile set up yet.';

  @override
  String get notificationsComingSoon => 'Notifications coming soon.';

  @override
  String get bodyStats => 'Body Stats';

  @override
  String get trackYourProgress => 'Track your progress';

  @override
  String get bodyStatsComingSoon => 'Body stats screen coming soon.';

  @override
  String get searchExplore => 'Search workouts, trainers, tips…';

  @override
  String get nothingFound => 'Nothing found.';

  @override
  String get detailComingSoon => 'Detail coming soon.';

  @override
  String get commentsComingSoon => 'Comments coming soon.';

  @override
  String get shareComingSoon => 'Share coming soon.';

  @override
  String get readArticle => 'Read Article';

  @override
  String get aboutApp => 'About TnT';

  @override
  String get version => 'Version 1.0.0+1';

  @override
  String get aboutDescription =>
      'TnT is a comprehensive fitness management platform connecting trainers and trainees.';

  @override
  String get copyright => '© 2026 TnT. All rights reserved.';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String get deleteAccountWarning =>
      'This action is permanent and cannot be undone. All your data will be deleted.';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get selectCurrency => 'Select Currency';

  @override
  String get measurementUnits => 'Measurement Units';

  @override
  String get metricKg => 'Metric (kg)';

  @override
  String get imperialLbs => 'Imperial (lbs)';

  @override
  String get metricKm => 'Metric (km)';

  @override
  String get imperialMi => 'Imperial (mi)';

  @override
  String get metricCm => 'Metric (cm)';

  @override
  String get imperialIn => 'Imperial (in)';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get distanceTrackingHint => 'Used for running and cardio tracking.';

  @override
  String get bodyMeasurementsHint => 'Used for height and circumferences.';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get addCard => 'Add Card';

  @override
  String get editCard => 'EDIT';

  @override
  String get removeCard => 'REMOVE';

  @override
  String get removeCardTitle => 'Remove Card?';

  @override
  String get cardRemoved => 'Card removed.';

  @override
  String get expires => 'EXPIRES';

  @override
  String get saveCard => 'Save Card';

  @override
  String get exportLabel => 'EXPORT';

  @override
  String get clientReviews => 'Client Reviews';

  @override
  String get introVideo => 'Intro Video';

  @override
  String get stats => 'Stats';

  @override
  String get viewBodyComposition => 'View Body Composition';

  @override
  String get viewCircumferences => 'View Circumferences';

  @override
  String get currentGoals => 'Current Goals';

  @override
  String get dietaryPreferences => 'Dietary Preferences';

  @override
  String get message => 'Message';

  @override
  String get none => 'None';

  @override
  String get currently => 'Currently';

  @override
  String get reportSubmitted => 'Report submitted.';

  @override
  String get successStories => 'Success Stories';

  @override
  String get wherTrainerWorks => 'Where this trainer works in real life';

  @override
  String get noLocationsListed => 'No locations listed yet.';

  @override
  String get chooseYourJourney => 'Choose Your Journey';

  @override
  String get mostPopular => 'MOST POPULAR';

  @override
  String get subscribeNow => 'Subscribe Now';

  @override
  String get redirectingToCheckout => 'Redirecting to checkout…';

  @override
  String get exclusivePostsExtras => 'Exclusive Posts & Extras';

  @override
  String get membersOnly => 'Members Only';

  @override
  String get viewMore => 'View more';

  @override
  String get reel => 'REEL';

  @override
  String get article => 'ARTICLE';

  @override
  String get searchClients => 'Search clients…';

  @override
  String get noInactiveClients => 'No inactive clients.';

  @override
  String get clientDetailComingSoon => 'Client detail screen coming soon.';

  @override
  String get newProgramme => 'New Programme';

  @override
  String get programmeBuilderComingSoon => 'Programme builder coming soon.';

  @override
  String get trainingProgrammes => 'Training';

  @override
  String get dietProgrammes => 'Diet';

  @override
  String get trainingProgramme => 'Training\nProgramme';

  @override
  String get pinProgramme => 'Pin to Top';

  @override
  String get unpinProgramme => 'Unpin';

  @override
  String get modifyProgramme => 'Modify';

  @override
  String get removeProgramme => 'Remove Programme';

  @override
  String removeProgrammeWarning(String name) {
    return 'Remove \"$name\"? This action cannot be undone.';
  }

  @override
  String get programmeDeleted => 'Programme removed.';

  @override
  String get programmePinned => 'Programme pinned to top.';

  @override
  String get programmeUnpinned => 'Programme unpinned.';

  @override
  String get noProgrammesTraining =>
      'No training programmes yet.\nTap the button below to create your first one.';

  @override
  String get noProgrammesDiet =>
      'No diet programmes yet.\nTap the button below to create your first one.';

  @override
  String get sessions => 'sessions';

  @override
  String get inactive => 'Inactive';

  @override
  String get create => 'Create';

  @override
  String get assignToClient => 'Assign to Client';

  @override
  String get assignComingSoon => 'Assign to client — coming soon.';

  @override
  String get formsManager => 'Forms Manager';

  @override
  String get deleteForm => 'Delete Form';

  @override
  String deleteFormWarning(String name, String count) {
    return 'Delete \"$name\"? All $count responses will be permanently lost.';
  }

  @override
  String get deletePermanently => 'Delete Permanently';

  @override
  String get formDeleted => 'Form deleted.';

  @override
  String get formEditorComingSoon => 'Form editor coming soon.';

  @override
  String get shareLinkCopied => 'Share link copied!';

  @override
  String get responsesComingSoon => 'Responses view coming soon.';

  @override
  String get createForm => 'Create Form';

  @override
  String get formBuilderComingSoon => 'Form builder coming soon.';

  @override
  String get noFormsYet =>
      'No forms here yet.\nCreate one to start collecting responses.';

  @override
  String get productsAndOffers => 'Products & Offers';

  @override
  String get productCreationComingSoon => 'Product creation coming soon.';

  @override
  String viewAllCount(String count) {
    return 'View all ($count)';
  }

  @override
  String get noProductsInCategory => 'No products in this category.';

  @override
  String get stock => 'Stock';

  @override
  String get editPost => 'Edit Post';

  @override
  String get postEditorComingSoon => 'Post editor coming soon.';

  @override
  String get share => 'Share';

  @override
  String get deletePost => 'Delete Post';

  @override
  String get postDeleted => 'Post deleted.';

  @override
  String get noPostsInCategory => 'No posts in this category yet.';

  @override
  String get postComposerComingSoon => 'Post composer coming soon.';

  @override
  String get estTotalValue => 'Est. total value';

  @override
  String get vsLastPeriod => 'vs last period';

  @override
  String get revenueTrend => 'Revenue Trend';

  @override
  String get goalDistribution => 'Goal Distribution';

  @override
  String get clientProgress => 'Client Progress';

  @override
  String get progress => 'Progress';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get passwordAndSecurity => 'Password & Security';

  @override
  String get accountIdentifier => 'Account Identifier';

  @override
  String get changeEmailAddress => 'Change E-mail Address';

  @override
  String get newEmailAddress => 'New E-mail Address';

  @override
  String get sendVerificationLink => 'Send Verification Link';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get passwordUpdatedSuccess => 'Password updated successfully!';

  @override
  String get profileInformation => 'Profile Information';

  @override
  String get goals => 'Goals';

  @override
  String get professionalSetup => 'Professional Setup';

  @override
  String get manageCredentials => 'Manage Credentials';

  @override
  String get noCredentialsAdded => 'No credentials added yet.';

  @override
  String get saveMeasurement => 'Save Measurement';

  @override
  String get selectCertificates => 'Select Certificate(s)';

  @override
  String get imageConfirmation => 'Does the image look clear and readable?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String showingResults(String count) {
    return 'Showing $count Results';
  }

  @override
  String statusUpdated(String status) {
    return 'Status updated to $status.';
  }

  @override
  String activeCount(String count) {
    return '$count Active';
  }

  @override
  String plansCount(String count) {
    return '$count Plans';
  }

  @override
  String savedCount(String count) {
    return '$count Saved';
  }

  @override
  String pendingCount(String count) {
    return '$count Pending';
  }

  @override
  String itemsCount(String count) {
    return '$count Items';
  }

  @override
  String postsCount(String count) {
    return '$count Posts';
  }

  @override
  String growthPercent(String percent) {
    return '+$percent% Growth';
  }

  @override
  String get descRotatorCuffTear =>
      'A strain or tear in the muscles/tendons stabilising the shoulder. Can be acute (from a fall) or degenerative (fraying over time).';

  @override
  String get descACJointSprain =>
      'Often called a \"separated shoulder,\" this is a stretch or tear of the ligaments connecting the collarbone to the shoulder blade.';

  @override
  String get descShoulderOsteo =>
      'The gradual wearing away of the protective cartilage in the shoulder joint, leading to bone-on-bone friction and stiffness.';

  @override
  String get descShoulderDislocation =>
      'The upper arm bone pops entirely out of the shoulder socket.';

  @override
  String get descShoulderImpingement =>
      'Pinching of the rotator cuff tendons against the shoulder blade, often leading to degenerative wear if left untreated.';

  @override
  String get descUCLSprain =>
      'A tear of the ligament on the inside of the elbow, highly common in throwing athletes like baseball pitchers.';

  @override
  String get descEpicondylopathy =>
      'While often called tendinitis, these are usually degenerative conditions (tendinosis) involving micro-tearing and breakdown of the tendons on the outside or inside of the elbow due to overuse.';

  @override
  String get descOlecranonBursitis =>
      'Swelling of the small fluid-filled sac at the bony tip of the elbow.';

  @override
  String get descWristSprain =>
      'Stretching or tearing of the ligaments connecting the wrist bones, usually from falling onto an outstretched hand.';

  @override
  String get descSkiersThumb =>
      'A sprain or tear of the ligament at the base of the thumb, making it difficult to pinch or grasp objects.';

  @override
  String get descThumbArthritis =>
      'Wear-and-tear of the cartilage at the base of the thumb (the CMC joint), causing severe pain when gripping or turning keys.';

  @override
  String get descCarpalTunnel =>
      'Compression of the median nerve in the wrist, often worsening over time, causing numbness and tingling.';

  @override
  String get descScaphoidFracture =>
      'A slow-healing break in one of the small carpal bones near the base of the thumb.';

  @override
  String get descHipOsteo =>
      'The progressive breakdown of cartilage in the hip\'s ball-and-socket joint, causing stiffness, a reduced range of motion, and groin pain.';

  @override
  String get descGroinStrain =>
      'A tear in the adductor muscles of the inner thigh, common in sports requiring sudden, explosive lateral movements.';

  @override
  String get descHipLabralTear =>
      'Damage to the ring of cartilage lining the hip socket. This can be an acute injury or a degenerative issue from repetitive motion.';

  @override
  String get descHipPointer =>
      'A deep, painful bruise on the bony ridge of the pelvis caused by a direct impact.';

  @override
  String get descCollateralLigament =>
      'Stretches or tears of the ligaments on the inner (MCL) or outer (LCL) sides of the knee, usually caused by sideways forces.';

  @override
  String get descCruciateLigament =>
      'Internal knee sprains. An ACL tear is a Grade 3 sprain of the anterior ligament, famous for happening during sudden pivots and causing the knee to buckle.';

  @override
  String get descKneeOsteo =>
      'The deterioration of the knee\'s shock-absorbing cartilage, eventually leading to painful bone-on-bone contact.';

  @override
  String get descMeniscusTear =>
      'While younger people get acute meniscus tears from twisting, older adults often experience degenerative tears where the cartilage simply frays and weakens over time.';

  @override
  String get descPatellarTendinopathy =>
      'Degeneration or inflammation of the tendon connecting the kneecap to the shinbone from repetitive stress.';

  @override
  String get descCalfStrain =>
      'A tear in the muscles at the back of the lower leg, ranging from a micro-tear to a complete rupture.';

  @override
  String get descAchillesTendinosis =>
      'The chronic breakdown of the collagen in the Achilles tendon from repetitive overuse, distinct from acute tendinitis (inflammation) or a sudden rupture.';

  @override
  String get descShinSplints =>
      'Pain along the shinbone caused by cumulative stress and inflammation of the surrounding tissues.';

  @override
  String get descAnkleSprain =>
      'The classic \"rolled ankle,\" stretching or tearing the ligaments on the outside of the ankle.';

  @override
  String get descHighAnkleSprain =>
      'A more severe sprain involving the ligaments that connect the two lower leg bones (tibia and fibula) just above the ankle.';

  @override
  String get descTurfToe =>
      'A sprain of the main joint of the big toe, usually occurring when the toe is forcibly bent upwards.';

  @override
  String get descPlantarFasciitis =>
      'Often driven by degenerative changes rather than purely inflammation, this affects the thick band of tissue on the bottom of the foot, causing stabbing heel pain.';

  @override
  String get descMidfootArthritis =>
      'Wear-and-tear of the cartilage in the middle of the foot, causing a deep, aching pain when walking or standing.';

  @override
  String get descAlzheimers =>
      'A progressive neurological disorder that causes brain cells to degenerate and die, leading to memory loss, confusion, and cognitive decline.';

  @override
  String get descAnemia =>
      'A condition where you lack enough healthy red blood cells to carry adequate oxygen to your body\'s tissues, often causing persistent fatigue and weakness.';

  @override
  String get descAngina =>
      'Chest pain or discomfort caused by temporarily reduced blood flow and oxygen to the heart muscle.';

  @override
  String get descAnxietyDisorders =>
      'A group of mental health conditions characterised by persistent, excessive worry or fear that interferes with daily life and activities.';

  @override
  String get descAsthma =>
      'A chronic respiratory condition where the airways become inflamed, narrow, and swell, making it difficult to breathe and causing wheezing.';

  @override
  String get descCeliacDisease =>
      'An autoimmune disorder where ingesting gluten leads to damage in the small intestine, preventing the absorption of nutrients.';

  @override
  String get descChronicKidneyDisease =>
      'A gradual loss of kidney function over time, preventing the kidneys from properly filtering waste and excess fluids from the blood.';

  @override
  String get descCOPD =>
      'A chronic inflammatory lung disease that causes obstructed airflow from the lungs; it includes conditions like emphysema and chronic bronchitis.';

  @override
  String get descCoronaryArteryDisease =>
      'The most common type of heart disease, caused by the build-up of cholesterol plaque in the arteries that supply blood to the heart.';

  @override
  String get descDVT =>
      'A serious condition where a blood clot forms in a deep vein, most commonly in the calf or thigh.';

  @override
  String get descDepression =>
      'A common but serious mood disorder that causes a persistent feeling of sadness, hopelessness, and a loss of interest in daily activities.';

  @override
  String get descDiabetesMellitus =>
      'A group of metabolic diseases that cause high blood sugar. In Type 1, the body produces no insulin. In the much more common Type 2, the body does not use insulin properly.';

  @override
  String get descEndometriosis =>
      'A painful condition where tissue similar to the lining of the uterus grows outside of it, commonly affecting the ovaries and pelvis.';

  @override
  String get descGERD =>
      'A chronic digestive disease where stomach acid or bile frequently flows back into the oesophagus, causing severe heartburn.';

  @override
  String get descGout =>
      'A very painful and complex form of arthritis caused by an excess of uric acid in the blood, which forms sharp crystals in a joint (often the big toe).';

  @override
  String get descHernia =>
      'Occurs when an internal organ pushes through a weak spot in the surrounding muscle or tissue wall.';

  @override
  String get descHypertension =>
      'A highly common cardiovascular condition where the force of the blood against the artery walls is consistently too high, significantly increasing the risk of heart disease and stroke.';

  @override
  String get descHyperthyroidism =>
      'An overactive thyroid condition where the gland produces too much thyroid hormone, significantly speeding up the body\'s metabolism and often causing unintentional weight loss, anxiety, and a rapid heartbeat.';

  @override
  String get descHypothyroidism =>
      'An underactive thyroid condition where the gland does not produce enough thyroid hormone, slowing down the metabolism and commonly leading to fatigue, weight gain, and sensitivity to cold.';

  @override
  String get descKidneyStones =>
      'Hard deposits of minerals and acid salts that stick together in concentrated urine, causing excruciating pain when passing through the urinary tract.';

  @override
  String get descMigraine =>
      'A neurological condition characterised by intense, debilitating, throbbing headaches, often accompanied by nausea and extreme sensitivity to light and sound.';

  @override
  String get descObesity =>
      'A complex, chronic disease involving an excessive amount of body fat that significantly increases the risk of other health problems, such as heart disease, sleep apnoea, and type 2 diabetes.';

  @override
  String get descOsteoarthritis =>
      'The most common form of arthritis, characterised by the progressive wear-and-tear of the protective cartilage on the ends of your bones.';

  @override
  String get descOsteoporosis =>
      'A condition that causes bones to become weak and brittle over time, making them highly susceptible to fractures from even mild stress or falls.';

  @override
  String get descPAD =>
      'A circulatory problem where narrowed arteries reduce blood flow to your limbs, often causing leg pain when walking.';

  @override
  String get descPeripheralNeuropathy =>
      'A result of damage to the peripheral nerves (frequently caused by diabetes) that causes weakness, numbness, and burning pain, usually starting in the hands or feet.';

  @override
  String get descRaynaudsDisease =>
      'A disorder of the blood vessels where cold temperatures or stress cause the vessels to temporarily narrow, turning fingers or toes white or blue and making them feel numb.';

  @override
  String get descRheumatoidArthritis =>
      'A chronic autoimmune and inflammatory disease where the body\'s immune system mistakenly attacks its own joint linings, causing painful swelling.';

  @override
  String get descShingles =>
      'A viral infection caused by the reactivation of the chickenpox virus, leading to a painful, blistering rash.';

  @override
  String get descSleepApnea =>
      'A potentially serious sleep disorder where a person\'s breathing repeatedly stops and starts during the night, leading to poor sleep quality and daytime fatigue.';

  @override
  String get descStroke =>
      'A medical emergency that occurs when the blood supply to part of your brain is interrupted or reduced, preventing brain tissue from getting necessary oxygen and nutrients.';

  @override
  String get account => 'Account';

  @override
  String get availability => 'Availability';

  @override
  String get unavailableModeSettingsTitle => 'Unavailable Mode';

  @override
  String get unavailableModeSettingsSubtitle =>
      'Prevent new subscriptions & messages';

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get masterNotificationToggle => 'Master notification toggle';

  @override
  String get emailNotifications => 'E-mail Notifications';

  @override
  String get emailNotificationsDesc => 'Receive updates via e-mail';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get pushNotificationsDesc => 'Receive push notifications';

  @override
  String get smsNotifications => 'SMS Notifications';

  @override
  String get smsNotificationsDesc => 'Receive text messages';

  @override
  String get preferences => 'Preferences';

  @override
  String get language => 'Language';

  @override
  String get currency => 'Currency';

  @override
  String get measurementUnitsSubtitle => 'Weight, distance, height';

  @override
  String get support => 'Support';

  @override
  String get helpCentre => 'Help Centre';

  @override
  String get helpCentreDesc => 'FAQs and support articles';

  @override
  String get contactUs => 'Contact Us';

  @override
  String get contactUsDesc => 'Get in touch with support';

  @override
  String get about => 'About';

  @override
  String get aboutSubtitle => 'App version and information';

  @override
  String languageChangedTo(String language) {
    return 'Language changed to $language.';
  }

  @override
  String currencyChangedTo(String currency) {
    return 'Currency changed to $currency.';
  }

  @override
  String get weightLiftingHint => 'Used for body weight and lifting metrics.';

  @override
  String get updatePersonalDetails => 'Update your personal details';

  @override
  String get manageYourCredentials => 'Manage your credentials';

  @override
  String get profileInfoTitle => 'Profile Information';

  @override
  String get verificationLinkSent => 'Verification link sent!';

  @override
  String updateMetric(String label) {
    return 'Update $label';
  }

  @override
  String pleaseSelectField(String field) {
    return 'Please select your $field.';
  }

  @override
  String loadingItems(String title) {
    return 'Loading all items in $title…';
  }

  @override
  String get cardNumberLabel => 'Card Number';

  @override
  String get expiryLabel => 'Expiry';

  @override
  String get expiryHint => 'MM/YY';

  @override
  String get cvvLabel => 'CVV';

  @override
  String get programmeSummaryComingSoon => 'Programme summary coming soon.';

  @override
  String get productDetailComingSoon => 'Product detail coming soon.';

  @override
  String get comingSoon => 'Coming soon.';

  @override
  String get saveLocation => 'Save Changes';

  @override
  String get holiday => 'Holiday';

  @override
  String get removeCardPrompt => 'Remove Card?';

  @override
  String get cardRemovedMsg => 'Card removed.';

  @override
  String get expiresTitle => 'EXPIRES';

  @override
  String get payoutBankAccount => 'Payout Bank Account';

  @override
  String get paymentMethodsTitle => 'Payment Methods';

  @override
  String get addCardButton => 'Add Card';

  @override
  String get membershipStarterTier => 'Starter Tier';

  @override
  String get membershipProTrainee => 'Pro Trainee';

  @override
  String get membershipEliteCoaching => 'Elite Coaching';

  @override
  String showingResultsCount(int count) {
    return 'Showing $count Results';
  }

  @override
  String get exportAction => 'EXPORT';

  @override
  String filterParam(String value) {
    return 'Filter: $value';
  }

  @override
  String sortParam(String value) {
    return 'Sort: $value';
  }

  @override
  String get noReviewsMatch => 'No reviews match these filters.';

  @override
  String get reportProfile => 'Report Profile';

  @override
  String get selectReason => 'Select a reason';

  @override
  String get beMoreSpecificTitle => 'Be more specific (optional)';

  @override
  String get submitReport => 'Submit Report';

  @override
  String get autoPlayingIntro => 'Auto-Playing Intro...';

  @override
  String get whereTrainerWorks => 'Where this trainer works in real life';

  @override
  String get mapDetectionInstructions =>
      'Zoom into your location exactly or search your place by name up there, then click Add';

  @override
  String get openInMaps => 'Open in Maps';

  @override
  String get noActiveMemberships => 'No Active Memberships';

  @override
  String get noActiveMembershipsDesc =>
      'You are not currently subscribed to any membership plan. Browse available trainers and subscribe to a plan to unlock exclusive content, personalised coaching, and more.';

  @override
  String get browsePlans => 'Browse Plans';

  @override
  String get errorOccurred => 'Something Went Wrong';

  @override
  String get error404Title => 'Page Not Found';

  @override
  String get error404Desc =>
      'The page you are looking for does not exist or has been moved. Please check the URL or navigate back to the home screen.';

  @override
  String get errorGenericDesc =>
      'An unexpected error occurred. This may be caused by a network issue, a temporary server outage, or an application fault. Please try again shortly.';

  @override
  String get goBack => 'Go Back';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get report => 'Report';

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String get unfollowed => 'Unfollowed';

  @override
  String get training => 'Training';

  @override
  String get diet => 'Diet';

  @override
  String get undo => 'Undo';

  @override
  String get duplicate => 'Duplicate';

  @override
  String get exercises => 'Exercises';

  @override
  String get meals => 'Meals';

  @override
  String get nameRequired => 'Name is required.';

  @override
  String get name => 'Name';

  @override
  String get duration => 'Duration';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get calories => 'Calories';

  @override
  String get dietType => 'Diet Type';

  @override
  String get trainingPlanBuilder => 'Training Plan Builder';

  @override
  String get programmeName => 'Programme Name';

  @override
  String get targetGoal => 'Target Goal';

  @override
  String get programmeColor => 'Programme Color';

  @override
  String get cycleType => 'Cycle Type';

  @override
  String get microcycle => 'Microcycle';

  @override
  String get mesocycle => 'Mesocycle';

  @override
  String get macrocycle => 'Macrocycle';

  @override
  String get description => 'Description';

  @override
  String get workoutDays => 'Workout Days';

  @override
  String get addDay => 'Add Day';

  @override
  String get noWorkoutDaysYet =>
      'No workout days yet. Add a day to start building this plan.';

  @override
  String get addExercise => 'Add Exercise';

  @override
  String get noExercisesInDay => 'No exercises in this day yet.';

  @override
  String get restTime => 'Rest Time';

  @override
  String get rpe => 'RPE';

  @override
  String get notes => 'Notes';

  @override
  String get searchExercises => 'Search exercises...';

  @override
  String get trainingType => 'Training Type';

  @override
  String get targetBodyPart => 'Target Body Part';

  @override
  String get noExercisesFound => 'No exercises match these filters.';

  @override
  String get all => 'All';

  @override
  String get untitledProgramme => 'Untitled Programme';

  @override
  String get noGoalSet => 'No goal set';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String exercisesCount(int count) {
    return '$count exercises';
  }

  @override
  String get catStrength => 'Strength & Muscle Building';

  @override
  String get goalBodybuildingTitle => 'Bodybuilding';

  @override
  String get goalBodybuildingDesc =>
      'A highly structured training style centred on progressive resistance to maximise muscle growth (hypertrophy) and refine physical proportions. It utilises a combination of compound movements and isolation exercises to target specific muscle groups, aiming for aesthetic symmetry, low body fat, and muscular definition.';

  @override
  String get goalPowerliftingTitle => 'Powerlifting';

  @override
  String get goalPowerliftingDesc =>
      'A strength sport focusing entirely on maximising the amount of weight a person can lift for a single repetition (1-Rep Max) in three specific barbell exercises: the squat, the bench press, and the deadlift. Training prioritises low repetitions, heavy loads, and central nervous system adaptation over muscle size.';

  @override
  String get goalOlympicTitle => 'Olympic Weightlifting';

  @override
  String get goalOlympicDesc =>
      'A dynamic and highly technical discipline centred on explosive power, speed, and mobility. Athletes train to master two fast-paced overhead barbell lifts: the snatch and the clean-and-jerk. It requires significant joint flexibility, core stability, and precise technique to drop under a heavy bar quickly.';

  @override
  String get goalStrongmanTitle => 'Strongman';

  @override
  String get goalStrongmanDesc =>
      'A varied, functional strength discipline that tests an athlete\'s raw power and endurance using heavy, awkward, and non-traditional implements. Common exercises include lifting Atlas stones, pulling sledges, carrying heavy yokes, and pressing logs, translating gym strength into real-world lifting capabilities.';

  @override
  String get catAthletic => 'Athletic & Functional Training';

  @override
  String get goalSportsTitle => 'Sports Performance';

  @override
  String get goalSportsDesc =>
      'Conditioning programs meticulously tailored to the specific physical demands of a competitive sport. This training emphasises explosive power, multidirectional agility, reaction time, and injury prevention, ensuring an athlete peaks physically for their specific season or event.';

  @override
  String get goalFunctionalTitle => 'Functional Fitness';

  @override
  String get goalFunctionalDesc =>
      'A constantly varied, high-intensity training methodology designed to prepare the body for any physical contingency. It blends elements of aerobic conditioning, gymnastics, and weightlifting to improve overall work capacity, stamina, and everyday physical readiness.';

  @override
  String get goalCallisthenicsTitle => 'Callisthenics';

  @override
  String get goalCallisthenicsDesc =>
      'A form of strength training that utilises the practitioner\'s own body weight and gravity as resistance. It emphasises mastering movement through space, starting with basics like push-ups and pull-ups, and progressing to advanced isometric holds requiring immense core control, such as planches and front levers.';

  @override
  String get goalCombatTitle => 'Combat Sports Conditioning';

  @override
  String get goalCombatDesc =>
      'Specialised physical preparation for martial arts, boxing, and wrestling. It focuses on building the stamina needed for continuous high-intensity rounds, enhancing rotational core power for striking, and developing the grip and neck strength required for grappling.';

  @override
  String get catRecovery => 'Recovery & Movement Health';

  @override
  String get goalCorrectiveTitle => 'Corrective Exercises';

  @override
  String get goalCorrectiveDesc =>
      'A systematic approach to identifying and addressing physical imbalances, poor posture, and movement compensations. By selectively stretching tight muscles and strengthening weak ones, this discipline helps alleviate chronic pain and retrains the body to move efficiently.';

  @override
  String get goalRehabilitationTitle => 'Rehabilitation';

  @override
  String get goalRehabilitationDesc =>
      'Highly structured, progressive exercise protocols are prescribed to help individuals recover safely from injuries, surgeries, or physical trauma. The primary goal is to safely restore the lost range of motion, rebuild atrophied muscles, and return the user to their baseline physical function.';

  @override
  String get goalMobilityTitle => 'Mobility Training';

  @override
  String get goalMobilityDesc =>
      'A practice focused on actively controlling the body through its full range of motion. Unlike passive stretching, mobility work requires strength and stability at the end ranges of a joint\'s movement, which keeps joints healthy, prevents injury, and improves overall movement quality.';

  @override
  String get catCardio => 'Cardiovascular & Endurance';

  @override
  String get goalHiitTitle => 'HIIT (High-Intensity Interval Training)';

  @override
  String get goalHiitDesc =>
      'A time-efficient cardiovascular methodology alternating between short bursts of near-maximum effort and periods of active recovery or rest. It forces the heart rate to spike quickly, improving cardiovascular capacity, metabolic rate, and caloric burn long after the workout ends.';

  @override
  String get goalEnduranceTitle => 'Endurance Training';

  @override
  String get goalEnduranceDesc =>
      'Steady-state, aerobic exercise designed to be sustained over long periods. Activities like marathon running, long-distance cycling, or swimming train the heart to pump blood more efficiently and increase the muscles\' ability to utilise oxygen, building deep, long-lasting stamina.';

  @override
  String get catMindbody => 'Mind-Body & Core';

  @override
  String get goalYogaTitle => 'Yoga';

  @override
  String get goalYogaDesc =>
      'A comprehensive practice that links physical postures with controlled breathing and mental focus. It improves flexibility, balance, and core strength while actively engaging the parasympathetic nervous system to reduce stress and enhance the mind-body connection.';

  @override
  String get goalPilatesTitle => 'Pilates';

  @override
  String get goalPilatesDesc =>
      'A precision-based training method primarily focused on the deep abdominal core, pelvic floor, and spinal stabilising muscles. Whether performed on a mat or specialised equipment, it emphasises controlled, low-impact movements to improve posture, body alignment, and deep muscular endurance.';

  @override
  String get catSpecialised => 'Specialised Programs';

  @override
  String get goalPrenatalTitle => 'Pre & Postnatal Fitness';

  @override
  String get goalPrenatalDesc =>
      'Carefully modified exercise routines designed to safely navigate the biomechanical changes of pregnancy. It focuses on maintaining strength, reducing back pain, and safely rebuilding core stability and pelvic floor function during postpartum recovery.';

  @override
  String get goalSeniorTitle => 'Senior Fitness';

  @override
  String get goalSeniorDesc =>
      'Exercise programming specifically tailored for ageing populations. It prioritises resistance training to combat age-related muscle loss, weight-bearing exercises to maintain bone density, and balance drills to prevent falls and sustain independent living.';

  @override
  String get goalYouthTitle => 'Youth Fitness';

  @override
  String get goalYouthDesc =>
      'Age-appropriate developmental programming for children and teenagers. It focuses on teaching fundamental movement patterns, developing neuromuscular coordination, and fostering a healthy, lifelong relationship with physical activity without applying excessive loads to growing bones.';
}
