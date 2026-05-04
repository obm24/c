import 'package:equatable/equatable.dart';

enum PhoneValidationErrorType {
  empty,
  unsupportedCountry,
  tooShort,
  tooLong,
  invalidPrefix,
  valid,
}

class CountryPhoneRule extends Equatable {
  final String isoCode;
  final String countryName;
  final String callingCode;
  final int nationalMinDigits;
  final int nationalMaxDigits;
  final List<String> nationalMobilePrefixes;
  final String? nationalTrunkPrefix;

  const CountryPhoneRule({
    required this.isoCode,
    required this.countryName,
    required this.callingCode,
    required this.nationalMinDigits,
    required this.nationalMaxDigits,
    required this.nationalMobilePrefixes,
    this.nationalTrunkPrefix,
  });

  bool get usesAdjustedRegistrationInput {
    final trunk = nationalTrunkPrefix;
    return trunk != null &&
        trunk.isNotEmpty &&
        nationalMobilePrefixes.isNotEmpty &&
        nationalMobilePrefixes.every((prefix) =>
            prefix.length > trunk.length && prefix.startsWith(trunk));
  }

  int get registrationMinDigits => usesAdjustedRegistrationInput
      ? nationalMinDigits - nationalTrunkPrefix!.length
      : nationalMinDigits;

  int get registrationMaxDigits => usesAdjustedRegistrationInput
      ? nationalMaxDigits - nationalTrunkPrefix!.length
      : nationalMaxDigits;

  List<String> get registrationMobilePrefixes {
    if (!usesAdjustedRegistrationInput) return nationalMobilePrefixes;
    final trunk = nationalTrunkPrefix!;
    return List.unmodifiable(nationalMobilePrefixes
        .map((prefix) => prefix.substring(trunk.length))
        .where((prefix) => prefix.isNotEmpty)
        .toList());
  }

  String normalizeRegistrationDigits(String phoneNumber) {
    var digits = PhoneValidationService.normalizeDigits(phoneNumber);
    final callingDigits = PhoneValidationService.normalizeDigits(callingCode);
    if (callingDigits.isNotEmpty) {
      if (digits.startsWith('00$callingDigits')) {
        digits = digits.substring(callingDigits.length + 2);
      } else if (digits.startsWith(callingDigits)) {
        digits = digits.substring(callingDigits.length);
      }
    }

    final trunk = nationalTrunkPrefix;
    if (usesAdjustedRegistrationInput &&
        trunk != null &&
        digits.startsWith(trunk)) {
      final adjusted = digits.substring(trunk.length);
      if (registrationMobilePrefixes.any(adjusted.startsWith) &&
          adjusted.length >= registrationMinDigits &&
          adjusted.length <= registrationMaxDigits) {
        digits = adjusted;
      }
    }
    return digits;
  }

  @override
  List<Object?> get props => [
        isoCode,
        countryName,
        callingCode,
        nationalMinDigits,
        nationalMaxDigits,
        nationalMobilePrefixes,
        nationalTrunkPrefix,
      ];
}

class PhoneCountryMetadata {
  static final RegExp _flagIsoPattern = RegExp(
    r'assets/images/flags/([a-z]{2})(?:-[a-z]+)?\.svg',
    caseSensitive: false,
  );

  static List<String> get countryCodeEntries => _countryCodeEntries;

  static String? isoCodeFromSelection(String? selection) {
    if (selection == null) return null;
    final trimmed = selection.trim();
    if (trimmed.isEmpty) return null;
    if (RegExp(r'^[A-Za-z]{2}$').hasMatch(trimmed)) {
      return trimmed.toUpperCase();
    }
    final match = _flagIsoPattern.firstMatch(trimmed);
    if (match != null) {
      return (match.group(1) ?? '').toUpperCase();
    }
    return null;
  }

  static String displayNameFromIso(String? isoCode) {
    final rule = countryPhoneRules[isoCode?.toUpperCase()];
    return rule?.countryName ?? (isoCode ?? '').toUpperCase();
  }

  static String displayNameFromSelection(String? selection) {
    if (selection == null || selection.trim().isEmpty) return '';
    final isoCode = isoCodeFromSelection(selection);
    final rule = countryPhoneRules[isoCode];
    if (rule != null) return rule.countryName;
    if (selection.startsWith('assets/images/flags/')) {
      final firstSpaceIdx = selection.indexOf(' ');
      if (firstSpaceIdx != -1) {
        return selection.substring(firstSpaceIdx + 1).trim();
      }
    }
    return selection.trim();
  }

  static String countryEntryFromSelection(String? selection) {
    final isoCode = isoCodeFromSelection(selection);
    final rule = countryPhoneRules[isoCode];
    if (rule == null) return '';
    return 'assets/images/flags/${rule.isoCode.toLowerCase()}.svg ${rule.countryName}';
  }

  static CountryPhoneRule? ruleFromSelection(
    String? countrySelection, {
    String? dialCodeSelection,
  }) {
    final countryIso = isoCodeFromSelection(countrySelection);
    if (countryIso != null && countryPhoneRules.containsKey(countryIso)) {
      return countryPhoneRules[countryIso];
    }
    final dialIso = isoCodeFromSelection(dialCodeSelection);
    if (dialIso != null && countryPhoneRules.containsKey(dialIso)) {
      return countryPhoneRules[dialIso];
    }
    return null;
  }
}

class AppCountryMetadata {
  static String? isoCodeFromSelection(String? selection) =>
      PhoneCountryMetadata.isoCodeFromSelection(selection);

  static String displayNameFromIso(String? isoCode) =>
      PhoneCountryMetadata.displayNameFromIso(isoCode);

  static String displayNameFromSelection(String? selection) =>
      PhoneCountryMetadata.displayNameFromSelection(selection);

  static String countryEntryFromSelection(String? selection) =>
      PhoneCountryMetadata.countryEntryFromSelection(selection);
}

const List<String> _countryCodeEntries = [
  'assets/images/flags/us.svg +1',
  'assets/images/flags/ca.svg +1',
  'assets/images/flags/ag.svg +1',
  'assets/images/flags/ai.svg +1',
  'assets/images/flags/as.svg +1',
  'assets/images/flags/bb.svg +1',
  'assets/images/flags/bm.svg +1',
  'assets/images/flags/bs.svg +1',
  'assets/images/flags/dm.svg +1',
  'assets/images/flags/do.svg +1',
  'assets/images/flags/gd.svg +1',
  'assets/images/flags/gu.svg +1',
  'assets/images/flags/jm.svg +1',
  'assets/images/flags/kn.svg +1',
  'assets/images/flags/ky.svg +1',
  'assets/images/flags/lc.svg +1',
  'assets/images/flags/mp.svg +1',
  'assets/images/flags/ms.svg +1',
  'assets/images/flags/pr.svg +1',
  'assets/images/flags/sx.svg +1',
  'assets/images/flags/tc.svg +1',
  'assets/images/flags/tt.svg +1',
  'assets/images/flags/vc.svg +1',
  'assets/images/flags/vg.svg +1',
  'assets/images/flags/vi.svg +1',
  'assets/images/flags/dz.svg +213',
  'assets/images/flags/ao.svg +244',
  'assets/images/flags/bj.svg +229',
  'assets/images/flags/bw.svg +267',
  'assets/images/flags/bf.svg +226',
  'assets/images/flags/bi.svg +257',
  'assets/images/flags/cm.svg +237',
  'assets/images/flags/cv.svg +238',
  'assets/images/flags/cf.svg +236',
  'assets/images/flags/td.svg +235',
  'assets/images/flags/km.svg +269',
  'assets/images/flags/cg.svg +242',
  'assets/images/flags/cd.svg +243',
  'assets/images/flags/dj.svg +253',
  'assets/images/flags/eg.svg +20',
  'assets/images/flags/gq.svg +240',
  'assets/images/flags/er.svg +291',
  'assets/images/flags/sz.svg +268',
  'assets/images/flags/et.svg +251',
  'assets/images/flags/ga.svg +241',
  'assets/images/flags/gm.svg +220',
  'assets/images/flags/gh.svg +233',
  'assets/images/flags/gn.svg +224',
  'assets/images/flags/gw.svg +245',
  'assets/images/flags/ci.svg +225',
  'assets/images/flags/ke.svg +254',
  'assets/images/flags/ls.svg +266',
  'assets/images/flags/lr.svg +231',
  'assets/images/flags/ly.svg +218',
  'assets/images/flags/mg.svg +261',
  'assets/images/flags/mw.svg +265',
  'assets/images/flags/ml.svg +223',
  'assets/images/flags/mr.svg +222',
  'assets/images/flags/mu.svg +230',
  'assets/images/flags/ma.svg +212',
  'assets/images/flags/mz.svg +258',
  'assets/images/flags/na.svg +264',
  'assets/images/flags/ne.svg +227',
  'assets/images/flags/ng.svg +234',
  'assets/images/flags/rw.svg +250',
  'assets/images/flags/st.svg +239',
  'assets/images/flags/sn.svg +221',
  'assets/images/flags/sc.svg +248',
  'assets/images/flags/sl.svg +232',
  'assets/images/flags/za.svg +27',
  'assets/images/flags/ss.svg +211',
  'assets/images/flags/sd.svg +249',
  'assets/images/flags/tz.svg +255',
  'assets/images/flags/tg.svg +228',
  'assets/images/flags/tn.svg +216',
  'assets/images/flags/ug.svg +256',
  'assets/images/flags/zm.svg +260',
  'assets/images/flags/zw.svg +263',
  'assets/images/flags/al.svg +355',
  'assets/images/flags/ad.svg +376',
  'assets/images/flags/at.svg +43',
  'assets/images/flags/by.svg +375',
  'assets/images/flags/be.svg +32',
  'assets/images/flags/ba.svg +387',
  'assets/images/flags/bg.svg +359',
  'assets/images/flags/hr.svg +385',
  'assets/images/flags/cy.svg +357',
  'assets/images/flags/cz.svg +420',
  'assets/images/flags/dk.svg +45',
  'assets/images/flags/ee.svg +372',
  'assets/images/flags/fi.svg +358',
  'assets/images/flags/fr.svg +33',
  'assets/images/flags/de.svg +49',
  'assets/images/flags/gr.svg +30',
  'assets/images/flags/hu.svg +36',
  'assets/images/flags/is.svg +354',
  'assets/images/flags/ie.svg +353',
  'assets/images/flags/it.svg +39',
  'assets/images/flags/lv.svg +371',
  'assets/images/flags/li.svg +423',
  'assets/images/flags/lt.svg +370',
  'assets/images/flags/lu.svg +352',
  'assets/images/flags/mt.svg +356',
  'assets/images/flags/md.svg +373',
  'assets/images/flags/mc.svg +377',
  'assets/images/flags/me.svg +382',
  'assets/images/flags/nl.svg +31',
  'assets/images/flags/mk.svg +389',
  'assets/images/flags/no.svg +47',
  'assets/images/flags/pl.svg +48',
  'assets/images/flags/pt.svg +351',
  'assets/images/flags/ro.svg +40',
  'assets/images/flags/sm.svg +378',
  'assets/images/flags/rs.svg +381',
  'assets/images/flags/sk.svg +421',
  'assets/images/flags/si.svg +386',
  'assets/images/flags/es.svg +34',
  'assets/images/flags/se.svg +46',
  'assets/images/flags/ch.svg +41',
  'assets/images/flags/gb-eng.svg +44',
  'assets/images/flags/ar.svg +54',
  'assets/images/flags/bz.svg +501',
  'assets/images/flags/bo.svg +591',
  'assets/images/flags/br.svg +55',
  'assets/images/flags/cl.svg +56',
  'assets/images/flags/co.svg +57',
  'assets/images/flags/cr.svg +506',
  'assets/images/flags/cu.svg +53',
  'assets/images/flags/ec.svg +593',
  'assets/images/flags/sv.svg +503',
  'assets/images/flags/gt.svg +502',
  'assets/images/flags/gy.svg +592',
  'assets/images/flags/ht.svg +509',
  'assets/images/flags/hn.svg +504',
  'assets/images/flags/mx.svg +52',
  'assets/images/flags/ni.svg +505',
  'assets/images/flags/pa.svg +507',
  'assets/images/flags/py.svg +595',
  'assets/images/flags/pe.svg +51',
  'assets/images/flags/sr.svg +597',
  'assets/images/flags/uy.svg +598',
  'assets/images/flags/ve.svg +58',
  'assets/images/flags/au.svg +61',
  'assets/images/flags/fj.svg +679',
  'assets/images/flags/id.svg +62',
  'assets/images/flags/ki.svg +686',
  'assets/images/flags/my.svg +60',
  'assets/images/flags/mh.svg +692',
  'assets/images/flags/fm.svg +691',
  'assets/images/flags/nr.svg +674',
  'assets/images/flags/nz.svg +64',
  'assets/images/flags/pw.svg +680',
  'assets/images/flags/pg.svg +675',
  'assets/images/flags/ph.svg +63',
  'assets/images/flags/ws.svg +685',
  'assets/images/flags/sg.svg +65',
  'assets/images/flags/sb.svg +677',
  'assets/images/flags/th.svg +66',
  'assets/images/flags/to.svg +676',
  'assets/images/flags/tv.svg +688',
  'assets/images/flags/vu.svg +678',
  'assets/images/flags/vn.svg +84',
  'assets/images/flags/ru.svg +7',
  'assets/images/flags/kz.svg +7',
  'assets/images/flags/cn.svg +86',
  'assets/images/flags/jp.svg +81',
  'assets/images/flags/kp.svg +850',
  'assets/images/flags/kr.svg +82',
  'assets/images/flags/tw.svg +886',
  'assets/images/flags/af.svg +93',
  'assets/images/flags/az.svg +994',
  'assets/images/flags/bh.svg +973',
  'assets/images/flags/bd.svg +880',
  'assets/images/flags/bt.svg +975',
  'assets/images/flags/bn.svg +673',
  'assets/images/flags/ge.svg +995',
  'assets/images/flags/in.svg +91',
  'assets/images/flags/ir.svg +98',
  'assets/images/flags/iq.svg +964',
  'assets/images/flags/il.svg +962',
  'assets/images/flags/kw.svg +965',
  'assets/images/flags/kg.svg +996',
  'assets/images/flags/la.svg +856',
  'assets/images/flags/lb.svg +961',
  'assets/images/flags/mv.svg +960',
  'assets/images/flags/mn.svg +976',
  'assets/images/flags/mm.svg +95',
  'assets/images/flags/np.svg +977',
  'assets/images/flags/om.svg +968',
  'assets/images/flags/pk.svg +92',
  'assets/images/flags/ps.svg +970',
  'assets/images/flags/qa.svg +974',
  'assets/images/flags/sa.svg +966',
  'assets/images/flags/lk.svg +94',
  'assets/images/flags/sy.svg +963',
  'assets/images/flags/tj.svg +992',
  'assets/images/flags/tr.svg +90',
  'assets/images/flags/tm.svg +993',
  'assets/images/flags/ae.svg +971',
  'assets/images/flags/ye.svg +967',
];

class PhoneValidationResult extends Equatable {
  final bool isValid;
  final PhoneValidationErrorType errorType;
  final String countryIsoCode;
  final String countryDisplayName;
  final String normalizedDigits;
  final int? expectedMinDigits;
  final int? expectedMaxDigits;
  final List<String> allowedPrefixes;
  final String? examplePrefix;
  final String callingCode;

  const PhoneValidationResult({
    required this.isValid,
    required this.errorType,
    required this.countryIsoCode,
    required this.countryDisplayName,
    required this.normalizedDigits,
    required this.expectedMinDigits,
    required this.expectedMaxDigits,
    required this.allowedPrefixes,
    this.examplePrefix,
    this.callingCode = '',
  });

  const PhoneValidationResult._({
    required this.isValid,
    required this.errorType,
    required this.countryIsoCode,
    required this.countryDisplayName,
    required this.normalizedDigits,
    required this.expectedMinDigits,
    required this.expectedMaxDigits,
    required this.allowedPrefixes,
    required this.examplePrefix,
    required this.callingCode,
  });

  factory PhoneValidationResult.valid({
    required String countryIsoCode,
    required String countryDisplayName,
    required String normalizedDigits,
    required int? expectedMinDigits,
    required int? expectedMaxDigits,
    required List<String> allowedPrefixes,
    required String callingCode,
  }) {
    return PhoneValidationResult._(
      isValid: true,
      errorType: PhoneValidationErrorType.valid,
      countryIsoCode: countryIsoCode,
      countryDisplayName: countryDisplayName,
      normalizedDigits: normalizedDigits,
      expectedMinDigits: expectedMinDigits,
      expectedMaxDigits: expectedMaxDigits,
      allowedPrefixes: List.unmodifiable(allowedPrefixes),
      examplePrefix: allowedPrefixes.isEmpty ? null : allowedPrefixes.first,
      callingCode: callingCode,
    );
  }

  factory PhoneValidationResult.invalid({
    required PhoneValidationErrorType errorType,
    required String countryIsoCode,
    required String countryDisplayName,
    required String normalizedDigits,
    int? expectedMinDigits,
    int? expectedMaxDigits,
    List<String> allowedPrefixes = const [],
    String callingCode = '',
  }) {
    return PhoneValidationResult._(
      isValid: false,
      errorType: errorType,
      countryIsoCode: countryIsoCode,
      countryDisplayName: countryDisplayName,
      normalizedDigits: normalizedDigits,
      expectedMinDigits: expectedMinDigits,
      expectedMaxDigits: expectedMaxDigits,
      allowedPrefixes: List.unmodifiable(allowedPrefixes),
      examplePrefix: allowedPrefixes.isEmpty ? null : allowedPrefixes.first,
      callingCode: callingCode,
    );
  }

  bool get isUnsupportedCountry =>
      errorType == PhoneValidationErrorType.unsupportedCountry;

  bool get hasLongPrefixList => allowedPrefixes.length > 4;

  @override
  List<Object?> get props => [
        isValid,
        errorType,
        countryIsoCode,
        countryDisplayName,
        normalizedDigits,
        expectedMinDigits,
        expectedMaxDigits,
        allowedPrefixes,
        examplePrefix,
        callingCode,
      ];
}

/// Global Telecommunications Mobile Validation Dataset
/// Key: ISO 3166-1 Alpha-2 Country Code
/// Value: Object containing local length constraints and valid mobile prefixes (inclusive of local trunks where mandated)
const Map<String, CountryPhoneRule> countryPhoneRules = {
  'US': CountryPhoneRule(
    isoCode: 'US',
    countryName: 'United States',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['2', '3', '4', '5', '6', '7', '8', '9'],
  ),
  'CA': CountryPhoneRule(
    isoCode: 'CA',
    countryName: 'Canada',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['2', '3', '4', '5', '6', '7', '8', '9'],
  ),
  'AG': CountryPhoneRule(
    isoCode: 'AG',
    countryName: 'Antigua and Barbuda',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['268'],
  ),
  'AI': CountryPhoneRule(
    isoCode: 'AI',
    countryName: 'Anguilla',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['264'],
  ),
  'AS': CountryPhoneRule(
    isoCode: 'AS',
    countryName: 'American Samoa',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['684'],
  ),
  'BB': CountryPhoneRule(
    isoCode: 'BB',
    countryName: 'Barbados',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['246'],
  ),
  'BM': CountryPhoneRule(
    isoCode: 'BM',
    countryName: 'Bermuda',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['441'],
  ),
  'BS': CountryPhoneRule(
    isoCode: 'BS',
    countryName: 'Bahamas',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['242'],
  ),
  'DM': CountryPhoneRule(
    isoCode: 'DM',
    countryName: 'Dominica',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['767'],
  ),
  'DO': CountryPhoneRule(
    isoCode: 'DO',
    countryName: 'Dominican Republic',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['809', '829', '849'],
  ),
  'GD': CountryPhoneRule(
    isoCode: 'GD',
    countryName: 'Grenada',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['473'],
  ),
  'GU': CountryPhoneRule(
    isoCode: 'GU',
    countryName: 'Guam',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['671'],
  ),
  'JM': CountryPhoneRule(
    isoCode: 'JM',
    countryName: 'Jamaica',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['658', '876'],
  ),
  'KN': CountryPhoneRule(
    isoCode: 'KN',
    countryName: 'Saint Kitts and Nevis',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['869'],
  ),
  'KY': CountryPhoneRule(
    isoCode: 'KY',
    countryName: 'Cayman Islands',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['345'],
  ),
  'LC': CountryPhoneRule(
    isoCode: 'LC',
    countryName: 'Saint Lucia',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['758'],
  ),
  'MP': CountryPhoneRule(
    isoCode: 'MP',
    countryName: 'Northern Mariana Islands',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['670'],
  ),
  'MS': CountryPhoneRule(
    isoCode: 'MS',
    countryName: 'Montserrat',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['664'],
  ),
  'PR': CountryPhoneRule(
    isoCode: 'PR',
    countryName: 'Puerto Rico',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['787', '939'],
  ),
  'SX': CountryPhoneRule(
    isoCode: 'SX',
    countryName: 'Sint Maarten',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['721'],
  ),
  'TC': CountryPhoneRule(
    isoCode: 'TC',
    countryName: 'Turks and Caicos Islands',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['649'],
  ),
  'TT': CountryPhoneRule(
    isoCode: 'TT',
    countryName: 'Trinidad and Tobago',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['868'],
  ),
  'VC': CountryPhoneRule(
    isoCode: 'VC',
    countryName: 'Saint Vincent and the Grenadines',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['784'],
  ),
  'VG': CountryPhoneRule(
    isoCode: 'VG',
    countryName: 'British Virgin Islands',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['284'],
  ),
  'VI': CountryPhoneRule(
    isoCode: 'VI',
    countryName: 'U.S. Virgin Islands',
    callingCode: '+1',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['340'],
  ),
  'DZ': CountryPhoneRule(
    isoCode: 'DZ',
    countryName: 'Algeria',
    callingCode: '+213',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['05', '06', '07'],
    nationalTrunkPrefix: '0',
  ),
  'AO': CountryPhoneRule(
    isoCode: 'AO',
    countryName: 'Angola',
    callingCode: '+244',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['91', '92', '93', '94', '99'],
  ),
  'BJ': CountryPhoneRule(
    isoCode: 'BJ',
    countryName: 'Benin',
    callingCode: '+229',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['4', '5', '6', '9'],
  ),
  'BW': CountryPhoneRule(
    isoCode: 'BW',
    countryName: 'Botswana',
    callingCode: '+267',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['71', '72', '73', '74', '75', '76', '77'],
  ),
  'BF': CountryPhoneRule(
    isoCode: 'BF',
    countryName: 'Burkina Faso',
    callingCode: '+226',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['5', '6', '7'],
  ),
  'BI': CountryPhoneRule(
    isoCode: 'BI',
    countryName: 'Burundi',
    callingCode: '+257',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['29', '61', '68', '69', '7'],
  ),
  'CM': CountryPhoneRule(
    isoCode: 'CM',
    countryName: 'Cameroon',
    callingCode: '+237',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['6'],
  ),
  'CV': CountryPhoneRule(
    isoCode: 'CV',
    countryName: 'Cape Verde',
    callingCode: '+238',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['5', '9'],
  ),
  'CF': CountryPhoneRule(
    isoCode: 'CF',
    countryName: 'Central African Republic',
    callingCode: '+236',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['7'],
  ),
  'TD': CountryPhoneRule(
    isoCode: 'TD',
    countryName: 'Chad',
    callingCode: '+235',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['6', '7', '9'],
  ),
  'KM': CountryPhoneRule(
    isoCode: 'KM',
    countryName: 'Comoros',
    callingCode: '+269',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['3'],
  ),
  'CG': CountryPhoneRule(
    isoCode: 'CG',
    countryName: 'Congo (Republic)',
    callingCode: '+242',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['04', '05', '06'],
    nationalTrunkPrefix: '0',
  ),
  'CD': CountryPhoneRule(
    isoCode: 'CD',
    countryName: 'Congo (DRC)',
    callingCode: '+243',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['8', '9'],
  ),
  'DJ': CountryPhoneRule(
    isoCode: 'DJ',
    countryName: 'Djibouti',
    callingCode: '+253',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['77'],
  ),
  'EG': CountryPhoneRule(
    isoCode: 'EG',
    countryName: 'Egypt',
    callingCode: '+20',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['010', '011', '012', '015'],
    nationalTrunkPrefix: '0',
  ),
  'GQ': CountryPhoneRule(
    isoCode: 'GQ',
    countryName: 'Equatorial Guinea',
    callingCode: '+240',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['2', '5'],
  ),
  'ER': CountryPhoneRule(
    isoCode: 'ER',
    countryName: 'Eritrea',
    callingCode: '+291',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['1', '7'],
  ),
  'SZ': CountryPhoneRule(
    isoCode: 'SZ',
    countryName: 'Eswatini',
    callingCode: '+268',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['76', '78', '79'],
  ),
  'ET': CountryPhoneRule(
    isoCode: 'ET',
    countryName: 'Ethiopia',
    callingCode: '+251',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['09'],
    nationalTrunkPrefix: '0',
  ),
  'GA': CountryPhoneRule(
    isoCode: 'GA',
    countryName: 'Gabon',
    callingCode: '+241',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['06', '07'],
    nationalTrunkPrefix: '0',
  ),
  'GM': CountryPhoneRule(
    isoCode: 'GM',
    countryName: 'Gambia',
    callingCode: '+220',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['2', '3', '5', '6', '7', '9'],
  ),
  'GH': CountryPhoneRule(
    isoCode: 'GH',
    countryName: 'Ghana',
    callingCode: '+233',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['02', '05'],
    nationalTrunkPrefix: '0',
  ),
  'GN': CountryPhoneRule(
    isoCode: 'GN',
    countryName: 'Guinea',
    callingCode: '+224',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['6'],
  ),
  'GW': CountryPhoneRule(
    isoCode: 'GW',
    countryName: 'Guinea-Bissau',
    callingCode: '+245',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['9'],
  ),
  'CI': CountryPhoneRule(
    isoCode: 'CI',
    countryName: 'Côte d\'Ivoire',
    callingCode: '+225',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['01', '05', '07'],
    nationalTrunkPrefix: '0',
  ),
  'KE': CountryPhoneRule(
    isoCode: 'KE',
    countryName: 'Kenya',
    callingCode: '+254',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['07', '01'],
    nationalTrunkPrefix: '0',
  ),
  'LS': CountryPhoneRule(
    isoCode: 'LS',
    countryName: 'Lesotho',
    callingCode: '+266',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['5', '6'],
  ),
  'LR': CountryPhoneRule(
    isoCode: 'LR',
    countryName: 'Liberia',
    callingCode: '+231',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['05', '07', '08'],
    nationalTrunkPrefix: '0',
  ),
  'LY': CountryPhoneRule(
    isoCode: 'LY',
    countryName: 'Libya',
    callingCode: '+218',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['091', '092', '093', '094', '095'],
    nationalTrunkPrefix: '0',
  ),
  'MG': CountryPhoneRule(
    isoCode: 'MG',
    countryName: 'Madagascar',
    callingCode: '+261',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['32', '33', '34', '38', '39'],
  ),
  'MW': CountryPhoneRule(
    isoCode: 'MW',
    countryName: 'Malawi',
    callingCode: '+265',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['88', '99', '31'],
  ),
  'ML': CountryPhoneRule(
    isoCode: 'ML',
    countryName: 'Mali',
    callingCode: '+223',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['5', '6', '7', '8', '9'],
  ),
  'MR': CountryPhoneRule(
    isoCode: 'MR',
    countryName: 'Mauritania',
    callingCode: '+222',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['2', '3', '4'],
  ),
  'MU': CountryPhoneRule(
    isoCode: 'MU',
    countryName: 'Mauritius',
    callingCode: '+230',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['5'],
  ),
  'MA': CountryPhoneRule(
    isoCode: 'MA',
    countryName: 'Morocco',
    callingCode: '+212',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['06', '07'],
    nationalTrunkPrefix: '0',
  ),
  'MZ': CountryPhoneRule(
    isoCode: 'MZ',
    countryName: 'Mozambique',
    callingCode: '+258',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['82', '83', '84', '85', '86', '87'],
  ),
  'NA': CountryPhoneRule(
    isoCode: 'NA',
    countryName: 'Namibia',
    callingCode: '+264',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['081', '085'],
    nationalTrunkPrefix: '0',
  ),
  'NE': CountryPhoneRule(
    isoCode: 'NE',
    countryName: 'Niger',
    callingCode: '+227',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['7', '8', '9'],
  ),
  'NG': CountryPhoneRule(
    isoCode: 'NG',
    countryName: 'Nigeria',
    callingCode: '+234',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['070', '080', '081', '090', '091'],
    nationalTrunkPrefix: '0',
  ),
  'RW': CountryPhoneRule(
    isoCode: 'RW',
    countryName: 'Rwanda',
    callingCode: '+250',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['72', '73', '78', '79'],
  ),
  'ST': CountryPhoneRule(
    isoCode: 'ST',
    countryName: 'Sao Tome and Principe',
    callingCode: '+239',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['9'],
  ),
  'SN': CountryPhoneRule(
    isoCode: 'SN',
    countryName: 'Senegal',
    callingCode: '+221',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['70', '75', '76', '77', '78'],
  ),
  'SC': CountryPhoneRule(
    isoCode: 'SC',
    countryName: 'Seychelles',
    callingCode: '+248',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['2'],
  ),
  'SL': CountryPhoneRule(
    isoCode: 'SL',
    countryName: 'Sierra Leone',
    callingCode: '+232',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['03', '07', '08', '09'],
    nationalTrunkPrefix: '0',
  ),
  'ZA': CountryPhoneRule(
    isoCode: 'ZA',
    countryName: 'South Africa',
    callingCode: '+27',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['06', '07', '08'],
    nationalTrunkPrefix: '0',
  ),
  'SS': CountryPhoneRule(
    isoCode: 'SS',
    countryName: 'South Sudan',
    callingCode: '+211',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['09'],
    nationalTrunkPrefix: '0',
  ),
  'SD': CountryPhoneRule(
    isoCode: 'SD',
    countryName: 'Sudan',
    callingCode: '+249',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['09', '01'],
    nationalTrunkPrefix: '0',
  ),
  'TZ': CountryPhoneRule(
    isoCode: 'TZ',
    countryName: 'Tanzania',
    callingCode: '+255',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['06', '07'],
    nationalTrunkPrefix: '0',
  ),
  'TG': CountryPhoneRule(
    isoCode: 'TG',
    countryName: 'Togo',
    callingCode: '+228',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['7', '9'],
  ),
  'TN': CountryPhoneRule(
    isoCode: 'TN',
    countryName: 'Tunisia',
    callingCode: '+216',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['2', '4', '5', '9'],
  ),
  'UG': CountryPhoneRule(
    isoCode: 'UG',
    countryName: 'Uganda',
    callingCode: '+256',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['07'],
    nationalTrunkPrefix: '0',
  ),
  'ZM': CountryPhoneRule(
    isoCode: 'ZM',
    countryName: 'Zambia',
    callingCode: '+260',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['095', '096', '097'],
    nationalTrunkPrefix: '0',
  ),
  'ZW': CountryPhoneRule(
    isoCode: 'ZW',
    countryName: 'Zimbabwe',
    callingCode: '+263',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['071', '073', '077', '078'],
    nationalTrunkPrefix: '0',
  ),
  'AL': CountryPhoneRule(
    isoCode: 'AL',
    countryName: 'Albania',
    callingCode: '+355',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['06'],
    nationalTrunkPrefix: '0',
  ),
  'AD': CountryPhoneRule(
    isoCode: 'AD',
    countryName: 'Andorra',
    callingCode: '+376',
    nationalMinDigits: 6,
    nationalMaxDigits: 6,
    nationalMobilePrefixes: ['3', '4', '6'],
  ),
  'AT': CountryPhoneRule(
    isoCode: 'AT',
    countryName: 'Austria',
    callingCode: '+43',
    nationalMinDigits: 10,
    nationalMaxDigits: 14,
    nationalMobilePrefixes: [
      '0650',
      '0660',
      '0664',
      '0676',
      '0680',
      '0681',
      '0688',
      '0699',
    ],
    nationalTrunkPrefix: '0',
  ),
  'BY': CountryPhoneRule(
    isoCode: 'BY',
    countryName: 'Belarus',
    callingCode: '+375',
    nationalMinDigits: 12,
    nationalMaxDigits: 12,
    nationalMobilePrefixes: ['8025', '8029', '8033', '8044'],
  ),
  'BE': CountryPhoneRule(
    isoCode: 'BE',
    countryName: 'Belgium',
    callingCode: '+32',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['045', '046', '047', '048', '049'],
    nationalTrunkPrefix: '0',
  ),
  'BA': CountryPhoneRule(
    isoCode: 'BA',
    countryName: 'Bosnia and Herzegovina',
    callingCode: '+387',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['06'],
    nationalTrunkPrefix: '0',
  ),
  'BG': CountryPhoneRule(
    isoCode: 'BG',
    countryName: 'Bulgaria',
    callingCode: '+359',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['087', '088', '089', '098'],
    nationalTrunkPrefix: '0',
  ),
  'HR': CountryPhoneRule(
    isoCode: 'HR',
    countryName: 'Croatia',
    callingCode: '+385',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['09'],
    nationalTrunkPrefix: '0',
  ),
  'CY': CountryPhoneRule(
    isoCode: 'CY',
    countryName: 'Cyprus',
    callingCode: '+357',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['9'],
  ),
  'CZ': CountryPhoneRule(
    isoCode: 'CZ',
    countryName: 'Czech Republic',
    callingCode: '+420',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['6', '7'],
  ),
  'DK': CountryPhoneRule(
    isoCode: 'DK',
    countryName: 'Denmark',
    callingCode: '+45',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['2', '3', '4', '5', '6', '7', '8', '9'],
  ),
  'EE': CountryPhoneRule(
    isoCode: 'EE',
    countryName: 'Estonia',
    callingCode: '+372',
    nationalMinDigits: 7,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['5', '8'],
  ),
  'FI': CountryPhoneRule(
    isoCode: 'FI',
    countryName: 'Finland',
    callingCode: '+358',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['04', '050'],
    nationalTrunkPrefix: '0',
  ),
  'FR': CountryPhoneRule(
    isoCode: 'FR',
    countryName: 'France',
    callingCode: '+33',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['06', '07'],
    nationalTrunkPrefix: '0',
  ),
  'DE': CountryPhoneRule(
    isoCode: 'DE',
    countryName: 'Germany',
    callingCode: '+49',
    nationalMinDigits: 11,
    nationalMaxDigits: 12,
    nationalMobilePrefixes: ['015', '016', '017'],
    nationalTrunkPrefix: '0',
  ),
  'GR': CountryPhoneRule(
    isoCode: 'GR',
    countryName: 'Greece',
    callingCode: '+30',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['69'],
  ),
  'HU': CountryPhoneRule(
    isoCode: 'HU',
    countryName: 'Hungary',
    callingCode: '+36',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['0620', '0630', '0631', '0650', '0670'],
    nationalTrunkPrefix: '0',
  ),
  'IS': CountryPhoneRule(
    isoCode: 'IS',
    countryName: 'Iceland',
    callingCode: '+354',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['6', '7', '8'],
  ),
  'IE': CountryPhoneRule(
    isoCode: 'IE',
    countryName: 'Ireland',
    callingCode: '+353',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['083', '085', '086', '087', '089'],
    nationalTrunkPrefix: '0',
  ),
  'IT': CountryPhoneRule(
    isoCode: 'IT',
    countryName: 'Italy',
    callingCode: '+39',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['3'],
  ),
  'LV': CountryPhoneRule(
    isoCode: 'LV',
    countryName: 'Latvia',
    callingCode: '+371',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['2'],
  ),
  'LI': CountryPhoneRule(
    isoCode: 'LI',
    countryName: 'Liechtenstein',
    callingCode: '+423',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['7'],
  ),
  'LT': CountryPhoneRule(
    isoCode: 'LT',
    countryName: 'Lithuania',
    callingCode: '+370',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['86'],
  ),
  'LU': CountryPhoneRule(
    isoCode: 'LU',
    countryName: 'Luxembourg',
    callingCode: '+352',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['6'],
  ),
  'MT': CountryPhoneRule(
    isoCode: 'MT',
    countryName: 'Malta',
    callingCode: '+356',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['7', '9'],
  ),
  'MD': CountryPhoneRule(
    isoCode: 'MD',
    countryName: 'Moldova',
    callingCode: '+373',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['06', '07'],
    nationalTrunkPrefix: '0',
  ),
  'MC': CountryPhoneRule(
    isoCode: 'MC',
    countryName: 'Monaco',
    callingCode: '+377',
    nationalMinDigits: 8,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['4', '6'],
  ),
  'ME': CountryPhoneRule(
    isoCode: 'ME',
    countryName: 'Montenegro',
    callingCode: '+382',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['06'],
    nationalTrunkPrefix: '0',
  ),
  'NL': CountryPhoneRule(
    isoCode: 'NL',
    countryName: 'Netherlands',
    callingCode: '+31',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['06'],
    nationalTrunkPrefix: '0',
  ),
  'MK': CountryPhoneRule(
    isoCode: 'MK',
    countryName: 'North Macedonia',
    callingCode: '+389',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['07'],
    nationalTrunkPrefix: '0',
  ),
  'NO': CountryPhoneRule(
    isoCode: 'NO',
    countryName: 'Norway',
    callingCode: '+47',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['4', '9'],
  ),
  'PL': CountryPhoneRule(
    isoCode: 'PL',
    countryName: 'Poland',
    callingCode: '+48',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['4', '5', '6', '7', '8'],
  ),
  'PT': CountryPhoneRule(
    isoCode: 'PT',
    countryName: 'Portugal',
    callingCode: '+351',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['91', '92', '93', '96'],
  ),
  'RO': CountryPhoneRule(
    isoCode: 'RO',
    countryName: 'Romania',
    callingCode: '+40',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['07'],
    nationalTrunkPrefix: '0',
  ),
  'SM': CountryPhoneRule(
    isoCode: 'SM',
    countryName: 'San Marino',
    callingCode: '+378',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['66'],
  ),
  'RS': CountryPhoneRule(
    isoCode: 'RS',
    countryName: 'Serbia',
    callingCode: '+381',
    nationalMinDigits: 9,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['06'],
    nationalTrunkPrefix: '0',
  ),
  'SK': CountryPhoneRule(
    isoCode: 'SK',
    countryName: 'Slovakia',
    callingCode: '+421',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['09'],
    nationalTrunkPrefix: '0',
  ),
  'SI': CountryPhoneRule(
    isoCode: 'SI',
    countryName: 'Slovenia',
    callingCode: '+386',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['031', '040', '041', '051', '06', '070', '071'],
    nationalTrunkPrefix: '0',
  ),
  'ES': CountryPhoneRule(
    isoCode: 'ES',
    countryName: 'Spain',
    callingCode: '+34',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['6', '7'],
  ),
  'SE': CountryPhoneRule(
    isoCode: 'SE',
    countryName: 'Sweden',
    callingCode: '+46',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['07'],
    nationalTrunkPrefix: '0',
  ),
  'CH': CountryPhoneRule(
    isoCode: 'CH',
    countryName: 'Switzerland',
    callingCode: '+41',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['07'],
    nationalTrunkPrefix: '0',
  ),
  'GB': CountryPhoneRule(
    isoCode: 'GB',
    countryName: 'United Kingdom',
    callingCode: '+44',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: [
      '071',
      '072',
      '073',
      '074',
      '075',
      '077',
      '078',
      '079'
    ],
    nationalTrunkPrefix: '0',
  ),
  'AR': CountryPhoneRule(
    isoCode: 'AR',
    countryName: 'Argentina',
    callingCode: '+54',
    nationalMinDigits: 12,
    nationalMaxDigits: 13,
    nationalMobilePrefixes: ['01115', '015'],
    nationalTrunkPrefix: '0',
  ),
  'BZ': CountryPhoneRule(
    isoCode: 'BZ',
    countryName: 'Belize',
    callingCode: '+501',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['6'],
  ),
  'BO': CountryPhoneRule(
    isoCode: 'BO',
    countryName: 'Bolivia',
    callingCode: '+591',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['6', '7'],
  ),
  'BR': CountryPhoneRule(
    isoCode: 'BR',
    countryName: 'Brazil',
    callingCode: '+55',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['1', '2', '3', '4', '5', '6', '7', '8', '9'],
  ),
  'CL': CountryPhoneRule(
    isoCode: 'CL',
    countryName: 'Chile',
    callingCode: '+56',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['9'],
  ),
  'CO': CountryPhoneRule(
    isoCode: 'CO',
    countryName: 'Colombia',
    callingCode: '+57',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['3'],
  ),
  'CR': CountryPhoneRule(
    isoCode: 'CR',
    countryName: 'Costa Rica',
    callingCode: '+506',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['5', '6', '7', '8'],
  ),
  'CU': CountryPhoneRule(
    isoCode: 'CU',
    countryName: 'Cuba',
    callingCode: '+53',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['5'],
  ),
  'EC': CountryPhoneRule(
    isoCode: 'EC',
    countryName: 'Ecuador',
    callingCode: '+593',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['09'],
    nationalTrunkPrefix: '0',
  ),
  'SV': CountryPhoneRule(
    isoCode: 'SV',
    countryName: 'El Salvador',
    callingCode: '+503',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['6', '7'],
  ),
  'GT': CountryPhoneRule(
    isoCode: 'GT',
    countryName: 'Guatemala',
    callingCode: '+502',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['3', '4', '5', '8'],
  ),
  'GY': CountryPhoneRule(
    isoCode: 'GY',
    countryName: 'Guyana',
    callingCode: '+592',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['6'],
  ),
  'HT': CountryPhoneRule(
    isoCode: 'HT',
    countryName: 'Haiti',
    callingCode: '+509',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['3', '4'],
  ),
  'HN': CountryPhoneRule(
    isoCode: 'HN',
    countryName: 'Honduras',
    callingCode: '+504',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['3', '8', '9'],
  ),
  'MX': CountryPhoneRule(
    isoCode: 'MX',
    countryName: 'Mexico',
    callingCode: '+52',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['2', '3', '4', '5', '6', '7', '8', '9'],
  ),
  'NI': CountryPhoneRule(
    isoCode: 'NI',
    countryName: 'Nicaragua',
    callingCode: '+505',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['5', '7', '8'],
  ),
  'PA': CountryPhoneRule(
    isoCode: 'PA',
    countryName: 'Panama',
    callingCode: '+507',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['6'],
  ),
  'PY': CountryPhoneRule(
    isoCode: 'PY',
    countryName: 'Paraguay',
    callingCode: '+595',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['09'],
    nationalTrunkPrefix: '0',
  ),
  'PE': CountryPhoneRule(
    isoCode: 'PE',
    countryName: 'Peru',
    callingCode: '+51',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['9'],
  ),
  'SR': CountryPhoneRule(
    isoCode: 'SR',
    countryName: 'Suriname',
    callingCode: '+597',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['7', '8'],
  ),
  'UY': CountryPhoneRule(
    isoCode: 'UY',
    countryName: 'Uruguay',
    callingCode: '+598',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['09'],
    nationalTrunkPrefix: '0',
  ),
  'VE': CountryPhoneRule(
    isoCode: 'VE',
    countryName: 'Venezuela',
    callingCode: '+58',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['0412', '0414', '0416', '0424', '0426'],
    nationalTrunkPrefix: '0',
  ),
  'AU': CountryPhoneRule(
    isoCode: 'AU',
    countryName: 'Australia',
    callingCode: '+61',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['04', '05'],
    nationalTrunkPrefix: '0',
  ),
  'FJ': CountryPhoneRule(
    isoCode: 'FJ',
    countryName: 'Fiji',
    callingCode: '+679',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['7', '8', '9'],
  ),
  'ID': CountryPhoneRule(
    isoCode: 'ID',
    countryName: 'Indonesia',
    callingCode: '+62',
    nationalMinDigits: 10,
    nationalMaxDigits: 13,
    nationalMobilePrefixes: ['08'],
    nationalTrunkPrefix: '0',
  ),
  'KI': CountryPhoneRule(
    isoCode: 'KI',
    countryName: 'Kiribati',
    callingCode: '+686',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['7'],
  ),
  'MY': CountryPhoneRule(
    isoCode: 'MY',
    countryName: 'Malaysia',
    callingCode: '+60',
    nationalMinDigits: 10,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['01'],
    nationalTrunkPrefix: '0',
  ),
  'MH': CountryPhoneRule(
    isoCode: 'MH',
    countryName: 'Marshall Islands',
    callingCode: '+692',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['4', '5'],
  ),
  'FM': CountryPhoneRule(
    isoCode: 'FM',
    countryName: 'Micronesia',
    callingCode: '+691',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['3'],
  ),
  'NR': CountryPhoneRule(
    isoCode: 'NR',
    countryName: 'Nauru',
    callingCode: '+674',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['55'],
  ),
  'NZ': CountryPhoneRule(
    isoCode: 'NZ',
    countryName: 'New Zealand',
    callingCode: '+64',
    nationalMinDigits: 9,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['02'],
    nationalTrunkPrefix: '0',
  ),
  'PW': CountryPhoneRule(
    isoCode: 'PW',
    countryName: 'Palau',
    callingCode: '+680',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['6'],
  ),
  'PG': CountryPhoneRule(
    isoCode: 'PG',
    countryName: 'Papua New Guinea',
    callingCode: '+675',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['7'],
  ),
  'PH': CountryPhoneRule(
    isoCode: 'PH',
    countryName: 'Philippines',
    callingCode: '+63',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['08', '09'],
    nationalTrunkPrefix: '0',
  ),
  'WS': CountryPhoneRule(
    isoCode: 'WS',
    countryName: 'Samoa',
    callingCode: '+685',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['7'],
  ),
  'SG': CountryPhoneRule(
    isoCode: 'SG',
    countryName: 'Singapore',
    callingCode: '+65',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['8', '9'],
  ),
  'SB': CountryPhoneRule(
    isoCode: 'SB',
    countryName: 'Solomon Islands',
    callingCode: '+677',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['7', '8'],
  ),
  'TH': CountryPhoneRule(
    isoCode: 'TH',
    countryName: 'Thailand',
    callingCode: '+66',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['06', '08', '09'],
    nationalTrunkPrefix: '0',
  ),
  'TO': CountryPhoneRule(
    isoCode: 'TO',
    countryName: 'Tonga',
    callingCode: '+676',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['7', '8'],
  ),
  'TV': CountryPhoneRule(
    isoCode: 'TV',
    countryName: 'Tuvalu',
    callingCode: '+688',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['9'],
  ),
  'VU': CountryPhoneRule(
    isoCode: 'VU',
    countryName: 'Vanuatu',
    callingCode: '+678',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['5', '7'],
  ),
  'VN': CountryPhoneRule(
    isoCode: 'VN',
    countryName: 'Vietnam',
    callingCode: '+84',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['03', '05', '07', '08', '09'],
    nationalTrunkPrefix: '0',
  ),
  'RU': CountryPhoneRule(
    isoCode: 'RU',
    countryName: 'Russia',
    callingCode: '+7',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['89'],
  ),
  'KZ': CountryPhoneRule(
    isoCode: 'KZ',
    countryName: 'Kazakhstan',
    callingCode: '+7',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['870', '874', '875', '877', '878'],
  ),
  'CN': CountryPhoneRule(
    isoCode: 'CN',
    countryName: 'China',
    callingCode: '+86',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['13', '14', '15', '16', '17', '18', '19'],
  ),
  'JP': CountryPhoneRule(
    isoCode: 'JP',
    countryName: 'Japan',
    callingCode: '+81',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['070', '080', '090'],
    nationalTrunkPrefix: '0',
  ),
  'KP': CountryPhoneRule(
    isoCode: 'KP',
    countryName: 'North Korea',
    callingCode: '+850',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['191', '192', '193'],
  ),
  'KR': CountryPhoneRule(
    isoCode: 'KR',
    countryName: 'South Korea',
    callingCode: '+82',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['010', '011', '016', '017', '018', '019'],
    nationalTrunkPrefix: '0',
  ),
  'TW': CountryPhoneRule(
    isoCode: 'TW',
    countryName: 'Taiwan',
    callingCode: '+886',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['09'],
    nationalTrunkPrefix: '0',
  ),
  'AF': CountryPhoneRule(
    isoCode: 'AF',
    countryName: 'Afghanistan',
    callingCode: '+93',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['07'],
    nationalTrunkPrefix: '0',
  ),
  'AZ': CountryPhoneRule(
    isoCode: 'AZ',
    countryName: 'Azerbaijan',
    callingCode: '+994',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['050', '051', '055', '070', '077', '099'],
    nationalTrunkPrefix: '0',
  ),
  'BH': CountryPhoneRule(
    isoCode: 'BH',
    countryName: 'Bahrain',
    callingCode: '+973',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['3'],
  ),
  'BD': CountryPhoneRule(
    isoCode: 'BD',
    countryName: 'Bangladesh',
    callingCode: '+880',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['013', '014', '015', '016', '017', '018', '019'],
    nationalTrunkPrefix: '0',
  ),
  'BT': CountryPhoneRule(
    isoCode: 'BT',
    countryName: 'Bhutan',
    callingCode: '+975',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['17', '77'],
  ),
  'BN': CountryPhoneRule(
    isoCode: 'BN',
    countryName: 'Brunei',
    callingCode: '+673',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['7', '8'],
  ),
  'GE': CountryPhoneRule(
    isoCode: 'GE',
    countryName: 'Georgia',
    callingCode: '+995',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['5'],
  ),
  'IN': CountryPhoneRule(
    isoCode: 'IN',
    countryName: 'India',
    callingCode: '+91',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['6', '7', '8', '9'],
  ),
  'IR': CountryPhoneRule(
    isoCode: 'IR',
    countryName: 'Iran',
    callingCode: '+98',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['09'],
    nationalTrunkPrefix: '0',
  ),
  'IQ': CountryPhoneRule(
    isoCode: 'IQ',
    countryName: 'Iraq',
    callingCode: '+964',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['075', '077', '078', '079'],
    nationalTrunkPrefix: '0',
  ),
  'IL': CountryPhoneRule(
    isoCode: 'IL',
    countryName: 'Israel',
    callingCode: '',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['05'],
    nationalTrunkPrefix: '0',
  ),
  'JO': CountryPhoneRule(
    isoCode: 'JO',
    countryName: 'Jordan',
    callingCode: '+962',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['077', '078', '079'],
    nationalTrunkPrefix: '0',
  ),
  'KW': CountryPhoneRule(
    isoCode: 'KW',
    countryName: 'Kuwait',
    callingCode: '+965',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['5', '6', '9'],
  ),
  'KG': CountryPhoneRule(
    isoCode: 'KG',
    countryName: 'Kyrgyzstan',
    callingCode: '+996',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['05', '07', '09'],
    nationalTrunkPrefix: '0',
  ),
  'LA': CountryPhoneRule(
    isoCode: 'LA',
    countryName: 'Laos',
    callingCode: '+856',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['020'],
    nationalTrunkPrefix: '0',
  ),
  'LB': CountryPhoneRule(
    isoCode: 'LB',
    countryName: 'Lebanon',
    callingCode: '+961',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['03', '70', '71', '76', '78', '79', '81'],
  ),
  'MV': CountryPhoneRule(
    isoCode: 'MV',
    countryName: 'Maldives',
    callingCode: '+960',
    nationalMinDigits: 7,
    nationalMaxDigits: 7,
    nationalMobilePrefixes: ['7', '9'],
  ),
  'MN': CountryPhoneRule(
    isoCode: 'MN',
    countryName: 'Mongolia',
    callingCode: '+976',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['8', '9'],
  ),
  'MM': CountryPhoneRule(
    isoCode: 'MM',
    countryName: 'Myanmar',
    callingCode: '+95',
    nationalMinDigits: 9,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['09'],
    nationalTrunkPrefix: '0',
  ),
  'NP': CountryPhoneRule(
    isoCode: 'NP',
    countryName: 'Nepal',
    callingCode: '+977',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['97', '98'],
  ),
  'OM': CountryPhoneRule(
    isoCode: 'OM',
    countryName: 'Oman',
    callingCode: '+968',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['7', '9'],
  ),
  'PK': CountryPhoneRule(
    isoCode: 'PK',
    countryName: 'Pakistan',
    callingCode: '+92',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['03'],
    nationalTrunkPrefix: '0',
  ),
  'PS': CountryPhoneRule(
    isoCode: 'PS',
    countryName: 'Palestine',
    callingCode: '+970',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['056', '059'],
    nationalTrunkPrefix: '0',
  ),
  'QA': CountryPhoneRule(
    isoCode: 'QA',
    countryName: 'Qatar',
    callingCode: '+974',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['3', '5', '6', '7'],
  ),
  'SA': CountryPhoneRule(
    isoCode: 'SA',
    countryName: 'Saudi Arabia',
    callingCode: '+966',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['05'],
    nationalTrunkPrefix: '0',
  ),
  'LK': CountryPhoneRule(
    isoCode: 'LK',
    countryName: 'Sri Lanka',
    callingCode: '+94',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['07'],
    nationalTrunkPrefix: '0',
  ),
  'SY': CountryPhoneRule(
    isoCode: 'SY',
    countryName: 'Syria',
    callingCode: '+963',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['09'],
    nationalTrunkPrefix: '0',
  ),
  'TJ': CountryPhoneRule(
    isoCode: 'TJ',
    countryName: 'Tajikistan',
    callingCode: '+992',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['0', '1', '2', '3', '4', '5', '7', '8', '9'],
  ),
  'TR': CountryPhoneRule(
    isoCode: 'TR',
    countryName: 'Turkey',
    callingCode: '+90',
    nationalMinDigits: 11,
    nationalMaxDigits: 11,
    nationalMobilePrefixes: ['05'],
    nationalTrunkPrefix: '0',
  ),
  'TM': CountryPhoneRule(
    isoCode: 'TM',
    countryName: 'Turkmenistan',
    callingCode: '+993',
    nationalMinDigits: 8,
    nationalMaxDigits: 8,
    nationalMobilePrefixes: ['6'],
  ),
  'AE': CountryPhoneRule(
    isoCode: 'AE',
    countryName: 'United Arab Emirates',
    callingCode: '+971',
    nationalMinDigits: 10,
    nationalMaxDigits: 10,
    nationalMobilePrefixes: ['05'],
    nationalTrunkPrefix: '0',
  ),
  'YE': CountryPhoneRule(
    isoCode: 'YE',
    countryName: 'Yemen',
    callingCode: '+967',
    nationalMinDigits: 9,
    nationalMaxDigits: 9,
    nationalMobilePrefixes: ['70', '71', '73', '77'],
  ),
};

final Map<String, CountryPhoneRule> globalMobileNumberingPlan =
    countryPhoneRules;

class PhoneValidationService {
  static String normalizeDigits(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'\D'), '');
  }

  static String resolveIsoCode(
    String? countrySelection, {
    String? dialCodeSelection,
  }) {
    return PhoneCountryMetadata.isoCodeFromSelection(countrySelection) ??
        PhoneCountryMetadata.isoCodeFromSelection(dialCodeSelection) ??
        '';
  }

  static String resolveCountryDisplayName(
    String? countrySelection, {
    String? dialCodeSelection,
    String? isoCode,
  }) {
    final selection =
        (countrySelection != null && countrySelection.trim().isNotEmpty)
            ? countrySelection
            : dialCodeSelection;
    final fromSelection = PhoneCountryMetadata.displayNameFromSelection(
      selection,
    );
    if (fromSelection.isNotEmpty) {
      return fromSelection;
    }
    return PhoneCountryMetadata.displayNameFromIso(isoCode);
  }

  static PhoneValidationResult validateDetailed(
    String? countrySelection,
    String phoneNumber, {
    String? dialCodeSelection,
  }) {
    final rule = PhoneCountryMetadata.ruleFromSelection(
      countrySelection,
      dialCodeSelection: dialCodeSelection,
    );
    final isoCode = rule?.isoCode ??
        resolveIsoCode(
          countrySelection,
          dialCodeSelection: dialCodeSelection,
        );
    final displayName = rule?.countryName ??
        resolveCountryDisplayName(
          countrySelection,
          dialCodeSelection: dialCodeSelection,
          isoCode: isoCode,
        );
    final digits = rule?.normalizeRegistrationDigits(phoneNumber) ??
        normalizeDigits(phoneNumber);

    if (rule == null) {
      return PhoneValidationResult.invalid(
        errorType: PhoneValidationErrorType.unsupportedCountry,
        countryIsoCode: isoCode,
        countryDisplayName: displayName,
        normalizedDigits: digits,
      );
    }

    final minDigits = rule.registrationMinDigits;
    final maxDigits = rule.registrationMaxDigits;
    final prefixes = rule.registrationMobilePrefixes;

    if (digits.isEmpty) {
      return PhoneValidationResult.invalid(
        errorType: PhoneValidationErrorType.empty,
        countryIsoCode: isoCode,
        countryDisplayName: displayName,
        normalizedDigits: digits,
        expectedMinDigits: minDigits,
        expectedMaxDigits: maxDigits,
        allowedPrefixes: prefixes,
        callingCode: rule.callingCode,
      );
    }

    if (digits.length < minDigits) {
      return PhoneValidationResult.invalid(
        errorType: PhoneValidationErrorType.tooShort,
        countryIsoCode: isoCode,
        countryDisplayName: displayName,
        normalizedDigits: digits,
        expectedMinDigits: minDigits,
        expectedMaxDigits: maxDigits,
        allowedPrefixes: prefixes,
        callingCode: rule.callingCode,
      );
    }

    if (digits.length > maxDigits) {
      return PhoneValidationResult.invalid(
        errorType: PhoneValidationErrorType.tooLong,
        countryIsoCode: isoCode,
        countryDisplayName: displayName,
        normalizedDigits: digits,
        expectedMinDigits: minDigits,
        expectedMaxDigits: maxDigits,
        allowedPrefixes: prefixes,
        callingCode: rule.callingCode,
      );
    }

    final validPrefix = prefixes.any(digits.startsWith);
    if (!validPrefix) {
      return PhoneValidationResult.invalid(
        errorType: PhoneValidationErrorType.invalidPrefix,
        countryIsoCode: isoCode,
        countryDisplayName: displayName,
        normalizedDigits: digits,
        expectedMinDigits: minDigits,
        expectedMaxDigits: maxDigits,
        allowedPrefixes: prefixes,
        callingCode: rule.callingCode,
      );
    }

    return PhoneValidationResult.valid(
      countryIsoCode: isoCode,
      countryDisplayName: displayName,
      normalizedDigits: digits,
      expectedMinDigits: minDigits,
      expectedMaxDigits: maxDigits,
      allowedPrefixes: prefixes,
      callingCode: rule.callingCode,
    );
  }

  static String validate(
    String? countrySelection,
    String phoneNumber, {
    String? dialCodeSelection,
  }) {
    final result = validateDetailed(
      countrySelection,
      phoneNumber,
      dialCodeSelection: dialCodeSelection,
    );
    return result.isValid ? '' : 'invalid_for_country';
  }
}

class PhoneValidationMessageBuilder {
  static String buildMessage(
    PhoneValidationResult result, {
    bool compact = false,
  }) {
    final countryName = result.countryDisplayName.isNotEmpty
        ? result.countryDisplayName
        : 'this country';

    switch (result.errorType) {
      case PhoneValidationErrorType.empty:
        return '${_countryRuleSummary(result, compact: compact)} ${_currentDigits(result)}.';
      case PhoneValidationErrorType.unsupportedCountry:
        return 'Mobile-number rules are not available for this country yet. Please check the number carefully.';
      case PhoneValidationErrorType.tooShort:
      case PhoneValidationErrorType.tooLong:
        return '${_countryLengthSummary(result)} ${_currentDigits(result)}.';
      case PhoneValidationErrorType.invalidPrefix:
        if (compact && result.hasLongPrefixList) {
          return 'Invalid mobile prefix for $countryName. Start with one of the approved mobile prefixes${_afterCallingCodeSuffix(result)}.';
        }
        return 'Invalid mobile prefix for $countryName. Start with ${_joinPrefixes(result.allowedPrefixes)}${_afterCallingCodeSuffix(result)}.';
      case PhoneValidationErrorType.valid:
        return compact && result.countryDisplayName.isNotEmpty
            ? 'Valid mobile number for $countryName.'
            : 'Valid ${_countryAdjective(countryName)} mobile number.';
    }
  }

  static String buildPrefixDetails(PhoneValidationResult result) {
    final countryName = result.countryDisplayName.isNotEmpty
        ? result.countryDisplayName
        : 'this country';
    return '$countryName mobile numbers must start with one of these approved prefixes${_afterCallingCodeSuffix(result)}: ${_joinPrefixes(result.allowedPrefixes)}.';
  }

  static String _digitExpectation(PhoneValidationResult result) {
    final min = result.expectedMinDigits;
    final max = result.expectedMaxDigits;
    if (min == null || max == null) return 'the required number of digits';
    if (min == max) {
      return '$min ${min == 1 ? 'digit' : 'digits'}';
    }
    return '$min-$max digits';
  }

  static String _afterCallingCode(PhoneValidationResult result) {
    return result.callingCode.isEmpty ? '' : 'after ${result.callingCode}';
  }

  static String _afterCallingCodeSuffix(PhoneValidationResult result) {
    final after = _afterCallingCode(result);
    return after.isEmpty ? '' : ' $after';
  }

  static String _countryLengthSummary(PhoneValidationResult result) {
    final countryName = result.countryDisplayName.isNotEmpty
        ? result.countryDisplayName
        : 'This country';
    final after = _afterCallingCode(result);
    return '$countryName mobile numbers must contain ${_digitExpectation(result)}${after.isEmpty ? '' : ' $after'}.';
  }

  static String _countryRuleSummary(
    PhoneValidationResult result, {
    bool compact = false,
  }) {
    final countryName = result.countryDisplayName.isNotEmpty
        ? result.countryDisplayName
        : 'This country';
    final expected = _digitExpectation(result);
    final prefixText = compact && result.hasLongPrefixList
        ? 'one of the approved mobile prefixes'
        : _joinPrefixes(result.allowedPrefixes);
    final after = _afterCallingCode(result);
    return '$countryName mobile numbers must contain $expected${after.isEmpty ? '' : ' $after'} and start with $prefixText.';
  }

  static String _currentDigits(PhoneValidationResult result) {
    final min = result.expectedMinDigits;
    final max = result.expectedMaxDigits;
    final actualDigits = result.normalizedDigits.length;
    if (min == null || max == null) {
      return 'Current digits: $actualDigits';
    }
    final target = min == max ? '$max' : '$min-$max';
    return 'Current digits: $actualDigits/$target';
  }

  static String _joinPrefixes(List<String> prefixes) {
    if (prefixes.isEmpty) return '';
    if (prefixes.length == 1) return prefixes.first;
    if (prefixes.length == 2) return '${prefixes[0]} or ${prefixes[1]}';
    return '${prefixes.sublist(0, prefixes.length - 1).join(', ')}, or ${prefixes.last}';
  }

  static String _countryAdjective(String countryName) {
    switch (countryName) {
      case 'Egypt':
        return 'Egyptian';
      case 'United Kingdom':
        return 'UK';
      case 'United States':
        return 'US';
      default:
        return countryName;
    }
  }
}
