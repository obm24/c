import 'package:flutter/material.dart';

import 'animations/motion.dart';
import 'c_constants.dart';
import 'c_ui_theme.dart';

class StandardFormWarningBanner extends StatelessWidget {
  final String message;
  final EdgeInsetsGeometry? margin;
  final bool isValid;
  final Widget? trailing;

  const StandardFormWarningBanner({
    super.key,
    required this.message,
    this.margin,
    this.isValid = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor =
        isValid ? AppTheme.cardGreen : AppTheme.error;

    return AppErrorShakeSubtle(
      enabled: !isValid,
      trigger: '$message-$isValid',
      child: AppFadeSlideTransition(
        duration: AppDurations.fast,
        offset: const Offset(0, 0.02),
        child: AnimatedContainer(
          duration: AppMotion.duration(
              context, AppDurations.standard),
          curve: AppCurves.entrance,
          width: double.infinity,
          margin: margin ?? const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(
                AppConstants.kDefaultBorderRadius),
            border: Border.all(
              color: statusColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: AppAnimatedSwitcher(
                  duration: AppDurations.fast,
                  child: Icon(
                    isValid
                        ? Icons.check_circle_outline
                        : Icons.warning_amber_rounded,
                    key: ValueKey(isValid),
                    color: statusColor,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: AppMotion.duration(
                      context, AppDurations.standard),
                  curve: AppCurves.entrance,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    height: 1.4,
                    fontFamily: 'Bai Jamjuree',
                  ),
                  child: Text(message),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}