import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../core/c_phone_validator.dart';

abstract class PhoneValidationEvent extends Equatable {
  const PhoneValidationEvent();
  @override
  List<Object?> get props => [];
}

class CountrySelected extends PhoneValidationEvent {
  final String countrySelection;
  final String? dialCodeSelection;
  const CountrySelected(this.countrySelection, {this.dialCodeSelection});
  @override
  List<Object?> get props => [countrySelection, dialCodeSelection];
}

class PhoneNumberChanged extends PhoneValidationEvent {
  final String phoneNumber;
  const PhoneNumberChanged(this.phoneNumber);
  @override
  List<Object?> get props => [phoneNumber];
}

class PhoneValidationState extends Equatable {
  final String selectedCountrySelection;
  final String? selectedDialCode;
  final String phoneNumber;
  final PhoneValidationResult validationResult;
  final bool hasInteracted;

  const PhoneValidationState({
    this.selectedCountrySelection = '',
    this.selectedDialCode,
    this.phoneNumber = '',
    this.validationResult = const PhoneValidationResult(
      isValid: false,
      errorType: PhoneValidationErrorType.empty,
      countryIsoCode: '',
      countryDisplayName: '',
      normalizedDigits: '',
      expectedMinDigits: null,
      expectedMaxDigits: null,
      allowedPrefixes: [],
    ),
    this.hasInteracted = false,
  });

  PhoneValidationState copyWith({
    String? selectedCountrySelection,
    String? selectedDialCode,
    bool clearSelectedDialCode = false,
    String? phoneNumber,
    PhoneValidationResult? validationResult,
    bool? hasInteracted,
  }) {
    return PhoneValidationState(
      selectedCountrySelection:
          selectedCountrySelection ?? this.selectedCountrySelection,
      selectedDialCode: clearSelectedDialCode
          ? null
          : (selectedDialCode ?? this.selectedDialCode),
      phoneNumber: phoneNumber ?? this.phoneNumber,
      validationResult: validationResult ?? this.validationResult,
      hasInteracted: hasInteracted ?? this.hasInteracted,
    );
  }

  bool get isValid => validationResult.isValid;

  /// Resolves the effective ISO code from whichever selection is populated.
  String get effectiveIsoCode {
    final fromCountry =
        PhoneCountryMetadata.isoCodeFromSelection(selectedCountrySelection);
    if (fromCountry != null && fromCountry.isNotEmpty) return fromCountry;
    final fromDial =
        PhoneCountryMetadata.isoCodeFromSelection(selectedDialCode);
    return fromDial ?? '';
  }

  /// Max registration digits for the currently resolved country rule.
  int get maxRegistrationDigits {
    final iso = effectiveIsoCode;
    if (iso.isEmpty) return 15;
    final rule = countryPhoneRules[iso];
    return rule?.registrationMaxDigits ?? 15;
  }

  bool get shouldShowFeedback =>
      hasInteracted ||
      selectedCountrySelection.isNotEmpty ||
      phoneNumber.isNotEmpty;
  bool get shouldShowError => shouldShowFeedback && !validationResult.isValid;
  bool get shouldShowValid => shouldShowFeedback && validationResult.isValid;

  @override
  List<Object?> get props => [
        selectedCountrySelection,
        selectedDialCode,
        phoneNumber,
        validationResult,
        hasInteracted,
      ];
}

class PhoneValidationBloc
    extends Bloc<PhoneValidationEvent, PhoneValidationState> {
  PhoneValidationBloc() : super(const PhoneValidationState()) {
    on<CountrySelected>((event, emit) {
      final result = PhoneValidationService.validateDetailed(
        event.countrySelection,
        state.phoneNumber,
        dialCodeSelection: event.dialCodeSelection,
      );
      emit(state.copyWith(
        selectedCountrySelection: event.countrySelection,
        selectedDialCode: event.dialCodeSelection,
        validationResult: result,
        hasInteracted: state.hasInteracted || state.phoneNumber.isNotEmpty,
      ));
    });

    on<PhoneNumberChanged>((event, emit) {
      final result = PhoneValidationService.validateDetailed(
        state.selectedCountrySelection,
        event.phoneNumber,
        dialCodeSelection: state.selectedDialCode,
      );
      emit(state.copyWith(
        phoneNumber: event.phoneNumber,
        validationResult: result,
        hasInteracted: event.phoneNumber.isNotEmpty || state.hasInteracted,
      ));
    });
  }
}