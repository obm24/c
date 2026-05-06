import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_en.dart';
import 'animations/anim_motion.dart';
import 'c_ui_theme.dart';
import 'c_constants.dart';
import 'c_custom_controls.dart';

// --- EXTENSIONS ---
extension LocalizedBuildContext on BuildContext {
  AppLocalizations get l10n {
    final localizations = AppLocalizations.of(this);
    if (localizations != null) return localizations;
    return AppLocalizationsEn();
  }
}

// --- UTILS ---
String dashboardGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

class AppRoutes {
  static Route<T> noTransitionRoute<T>(Widget page) {
    return AppMotion.pageRoute<T>(page);
  }

  static Route<T> premiumRoute<T>(
    Widget page, {
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    return AppMotion.pageRoute<T>(
      page,
      settings: settings,
      fullscreenDialog: fullscreenDialog,
    );
  }
}

class AppUtils {
  static Future<void> launchLink(BuildContext context, String url,
      {bool fromChat = false}) async {
    final Uri uri = Uri.parse(url);
    if (fromChat) {
      HapticFeedback.lightImpact();
      bool confirm = await AppMotion.showPremiumDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                    backgroundColor: AppTheme.surface,
                    titlePadding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            AppConstants.kDefaultBorderRadius)),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(context.l10n.externalLinkWarning,
                              style: const TextStyle(
                                  color: Colors.orangeAccent,
                                  fontSize: AppConstants.kDefaultTitleFontSize,
                                  fontWeight: FontWeight.bold)),
                        ),
                        const Divider(color: AppTheme.divider, height: 1),
                      ],
                    ),
                    content: Text(
                        '${context.l10n.externalLinkDisclaimer}\n\n$url',
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppConstants.kDefaultSubtitleFontSize)),
                    actions: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.pop(context, false);
                                  },
                                  child: Text(context.l10n.cancel,
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: AppConstants
                                              .kDefaultSubtitleFontSize))),
                              const SizedBox(width: 10),
                              Expanded(
                                  child: SolidConfirmButton(
                                      label: context.l10n.proceed,
                                      height: AppConstants
                                          .kDefaultButtonHeightLarge,
                                      onPressed: () {
                                        HapticFeedback.selectionClick();
                                        Navigator.pop(context, true);
                                      })),
                            ],
                          )
                        ],
                      )
                    ],
                  )) ??
          false;
      if (!confirm) return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static void showToast(BuildContext context, String message) {
    HapticFeedback.lightImpact();
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => _ToastWidget(message: message),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () {
      if (overlayEntry.mounted) overlayEntry.remove();
    });
  }
}

class _ToastWidget extends StatelessWidget {
  final String message;
  const _ToastWidget({required this.message});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).size.height / 2 - 30,
      left: 40,
      right: 40,
      child: IgnorePointer(
        child: AppScaleFadeTransition(
          duration: AppDurations.fast,
          beginScale: 0.98,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: AppTheme.brand,
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                boxShadow: const [
                  BoxShadow(color: Colors.black45, blurRadius: 10)
                ],
              ),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppTheme.confirmationButtonText,
                    fontWeight: FontWeight.bold,
                    fontSize: AppConstants.kDefaultSubtitleFontSize),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- FORMATTERS ---
class NumberBoundsFormatter extends TextInputFormatter {
  final int maxWholeDigits;
  final int maxDecimalDigits;
  final double? maxVal;

  NumberBoundsFormatter(
      {this.maxWholeDigits = 3, this.maxDecimalDigits = 2, this.maxVal});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String text = newValue.text.replaceAll(RegExp(r'[^0-9.]'), '');
    if (text.indexOf('.') != text.lastIndexOf('.')) return oldValue;

    List<String> parts = text.split('.');
    if (parts[0].length > maxWholeDigits) return oldValue;
    if (parts.length > 1 && parts[1].length > maxDecimalDigits) return oldValue;

    final maximumValue = maxVal;
    if (maximumValue != null) {
      double? val = double.tryParse(text);
      if (val != null && val > maximumValue) return oldValue;
    }

    return TextEditingValue(
      text: text,
      selection: newValue.selection.end <= text.length
          ? newValue.selection
          : TextSelection.collapsed(offset: text.length),
    );
  }
}

class ImperialHeightFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;
    String newDigits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (oldValue.text.endsWith("'") &&
        newValue.text == oldValue.text.substring(0, oldValue.text.length - 1)) {
      newDigits = newDigits.isNotEmpty
          ? newDigits.substring(0, newDigits.length - 1)
          : '';
    } else if (oldValue.text.endsWith('"') &&
        newValue.text == oldValue.text.substring(0, oldValue.text.length - 1)) {
      newDigits = newDigits.isNotEmpty
          ? newDigits.substring(0, newDigits.length - 1)
          : '';
    }

    if (newDigits.isEmpty) {
      return const TextEditingValue(
          text: '', selection: TextSelection.collapsed(offset: 0));
    }

    String feetStr = newDigits[0];
    int feet = int.parse(feetStr);

    if (feet > 8) {
      feetStr = '8';
      feet = 8;
    }

    String inches = newDigits.length > 1
        ? newDigits.substring(1, min(3, newDigits.length))
        : '';

    if (inches.isNotEmpty) {
      int? inchesInt = int.tryParse(inches);
      if (inchesInt != null && inchesInt > 11) {
        inches = inches.substring(0, inches.length - 1);
      }
    }

    String formattedText;
    int cursorOffset;

    if (inches.isEmpty) {
      formattedText = "$feetStr'";
      cursorOffset = formattedText.length;
    } else {
      formattedText = "$feetStr' $inches\"";
      cursorOffset = formattedText.length - 1;
    }

    return TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: cursorOffset));
  }
}
