import 'package:flutter_test/flutter_test.dart';
import 'package:tnt/core/c_phone_validator.dart';

void main() {
  group('CountryPhoneRule registration rules', () {
    test('Egypt removes the national trunk prefix for registration input', () {
      final rule = countryPhoneRules['EG']!;

      expect(rule.nationalMobilePrefixes, ['010', '011', '012', '015']);
      expect(rule.registrationMobilePrefixes, ['10', '11', '12', '15']);
      expect(rule.registrationMinDigits, 10);
      expect(rule.registrationMaxDigits, 10);
      expect(rule.usesAdjustedRegistrationInput, isTrue);
    });

    test('United States NANP rules stay unchanged', () {
      final rule = countryPhoneRules['US']!;

      expect(rule.registrationMobilePrefixes,
          ['2', '3', '4', '5', '6', '7', '8', '9']);
      expect(rule.registrationMinDigits, 10);
      expect(rule.registrationMaxDigits, 10);
      expect(rule.usesAdjustedRegistrationInput, isFalse);
    });

    test('Austria keeps variable length after trunk adjustment', () {
      final rule = countryPhoneRules['AT']!;

      expect(rule.registrationMinDigits, 9);
      expect(rule.registrationMaxDigits, 13);
      expect(rule.registrationMobilePrefixes,
          ['650', '660', '664', '676', '680', '681', '688', '699']);
    });
  });

  group('PhoneValidationService.validateDetailed', () {
    test('Egypt selected +20 accepts adjusted local subscriber number', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/eg.svg Egypt',
        '1012345678',
        dialCodeSelection: 'assets/images/flags/eg.svg +20',
      );

      expect(result.isValid, isTrue);
      expect(result.countryIsoCode, 'EG');
      expect(result.normalizedDigits, '1012345678');
      expect(result.allowedPrefixes, ['10', '11', '12', '15']);
      expect(result.expectedMinDigits, 10);
    });

    test('Egypt national trunk input is normalized gracefully', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/eg.svg Egypt',
        '01012345678',
        dialCodeSelection: 'assets/images/flags/eg.svg +20',
      );

      expect(result.isValid, isTrue);
      expect(result.normalizedDigits, '1012345678');
    });

    test('Egypt invalid adjusted prefix fails', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/eg.svg Egypt',
        '1312345678',
        dialCodeSelection: 'assets/images/flags/eg.svg +20',
      );

      expect(result.isValid, isFalse);
      expect(result.errorType, PhoneValidationErrorType.invalidPrefix);
    });

    test('Egypt too short expects 10 registration digits', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/eg.svg Egypt',
        '10123456',
        dialCodeSelection: 'assets/images/flags/eg.svg +20',
      );

      expect(result.isValid, isFalse);
      expect(result.errorType, PhoneValidationErrorType.tooShort);
      expect(result.expectedMinDigits, 10);
    });

    test('Saudi Arabia accepts 5 prefix and 9 digits after +966', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/sa.svg Saudi Arabia',
        '512345678',
        dialCodeSelection: 'assets/images/flags/sa.svg +966',
      );

      expect(result.isValid, isTrue);
      expect(result.countryIsoCode, 'SA');
      expect(result.allowedPrefixes, ['5']);
      expect(result.expectedMaxDigits, 9);
    });

    test('United Kingdom accepts 71 prefix and 10 digits after +44', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/gb-eng.svg United Kingdom',
        '7112345678',
        dialCodeSelection: 'assets/images/flags/gb-eng.svg +44',
      );

      expect(result.isValid, isTrue);
      expect(result.countryIsoCode, 'GB');
      expect(result.allowedPrefixes,
          ['71', '72', '73', '74', '75', '77', '78', '79']);
      expect(result.expectedMaxDigits, 10);
    });

    test('United States validates unchanged NANP rules', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/us.svg United States',
        '2125550123',
        dialCodeSelection: 'assets/images/flags/us.svg +1',
      );

      expect(result.isValid, isTrue);
      expect(result.countryIsoCode, 'US');
      expect(result.expectedMinDigits, 10);
      expect(result.allowedPrefixes, ['2', '3', '4', '5', '6', '7', '8', '9']);
    });

    test('South Korea uses adjusted local rules after +82', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/kr.svg South Korea',
        '1012345678',
        dialCodeSelection: 'assets/images/flags/kr.svg +82',
      );

      expect(result.isValid, isTrue);
      expect(result.countryIsoCode, 'KR');
      expect(result.countryDisplayName, 'South Korea');
      expect(result.expectedMinDigits, 10);
      expect(result.expectedMaxDigits, 10);
      expect(
        result.allowedPrefixes,
        ['10', '11', '16', '17', '18', '19'],
      );
    });

    test('Selected country wins over mismatched dial-code selection', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/kr.svg South Korea',
        '1012345678',
        dialCodeSelection: 'assets/images/flags/eg.svg +20',
      );

      expect(result.isValid, isTrue);
      expect(result.countryIsoCode, 'KR');
      expect(result.countryDisplayName, 'South Korea');
      expect(result.callingCode, '+82');
      expect(result.allowedPrefixes, ['10', '11', '16', '17', '18', '19']);
    });

    test('Missing country selection falls back to dial-code country', () {
      final result = PhoneValidationService.validateDetailed(
        '',
        '1012345678',
        dialCodeSelection: 'assets/images/flags/kr.svg +82',
      );

      expect(result.isValid, isTrue);
      expect(result.countryIsoCode, 'KR');
      expect(result.countryDisplayName, 'South Korea');
    });

    test('Formatting and pasted country code are normalized', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/eg.svg Egypt',
        '+20 10-1234-5678',
        dialCodeSelection: 'assets/images/flags/eg.svg +20',
      );

      expect(result.isValid, isTrue);
      expect(result.normalizedDigits, '1012345678');
    });

    test('Unsupported country fallback', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/ax.svg +358',
        '12345678',
        dialCodeSelection: 'assets/images/flags/ax.svg +358',
      );

      expect(result.isValid, isFalse);
      expect(result.errorType, PhoneValidationErrorType.unsupportedCountry);
    });

    test('South Korea too long stays invalid with selected-country limits', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/kr.svg South Korea',
        '10123456789',
        dialCodeSelection: 'assets/images/flags/kr.svg +82',
      );

      expect(result.isValid, isFalse);
      expect(result.errorType, PhoneValidationErrorType.tooLong);
      expect(result.expectedMaxDigits, 10);
    });
  });

  group('PhoneValidationMessageBuilder', () {
    test('builds adjusted Egypt empty warning', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/eg.svg Egypt',
        '',
        dialCodeSelection: 'assets/images/flags/eg.svg +20',
      );

      expect(
        PhoneValidationMessageBuilder.buildMessage(result),
        'Egypt mobile numbers must contain 10 digits after +20 and start with 10, 11, 12, or 15. Current digits: 0/10.',
      );
    });

    test('builds adjusted Saudi warning', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/sa.svg Saudi Arabia',
        '',
        dialCodeSelection: 'assets/images/flags/sa.svg +966',
      );

      expect(
        PhoneValidationMessageBuilder.buildMessage(result),
        'Saudi Arabia mobile numbers must contain 9 digits after +966 and start with 5. Current digits: 0/9.',
      );
    });

    test('builds adjusted South Korea warning', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/kr.svg South Korea',
        '',
        dialCodeSelection: 'assets/images/flags/kr.svg +82',
      );

      expect(
        PhoneValidationMessageBuilder.buildMessage(result, compact: true),
        'South Korea mobile numbers must contain 10 digits after +82 and start with one of the approved mobile prefixes. Current digits: 0/10.',
      );
    });

    test('builds compact variable-length warning', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/at.svg Austria',
        '',
        dialCodeSelection: 'assets/images/flags/at.svg +43',
      );

      expect(
        PhoneValidationMessageBuilder.buildMessage(result, compact: true),
        'Austria mobile numbers must contain 9-13 digits after +43 and start with one of the approved mobile prefixes. Current digits: 0/9-13.',
      );
    });

    test('builds country-specific invalid-prefix warning', () {
      final result = PhoneValidationService.validateDetailed(
        'assets/images/flags/eg.svg Egypt',
        '1312345678',
        dialCodeSelection: 'assets/images/flags/eg.svg +20',
      );

      expect(
        PhoneValidationMessageBuilder.buildMessage(result),
        'Invalid mobile prefix for Egypt. Start with 10, 11, 12, or 15 after +20.',
      );
    });

    test('switching countries changes the warning immediately', () {
      final egyptResult = PhoneValidationService.validateDetailed(
        'assets/images/flags/eg.svg Egypt',
        '10123',
        dialCodeSelection: 'assets/images/flags/eg.svg +20',
      );
      final southKoreaResult = PhoneValidationService.validateDetailed(
        'assets/images/flags/kr.svg South Korea',
        '10123',
        dialCodeSelection: 'assets/images/flags/kr.svg +82',
      );

      expect(
        PhoneValidationMessageBuilder.buildMessage(egyptResult, compact: true),
        'Egypt mobile numbers must contain 10 digits after +20. Current digits: 5/10.',
      );
      expect(
        PhoneValidationMessageBuilder.buildMessage(
          southKoreaResult,
          compact: true,
        ),
        'South Korea mobile numbers must contain 10 digits after +82. Current digits: 5/10.',
      );
    });
  });
}
