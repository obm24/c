import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'c_ui_theme.dart';
import 'c_core_utils.dart';
import 'c_custom_controls.dart';

// =============================================================================
// APP ERROR SCREEN
// Graceful, branded error screen shown for unhandled exceptions, 404s, and
// other failures. Provides useful context to the user and avoids leaving
// them on a blank white page.
// =============================================================================
class AppErrorScreen extends StatelessWidget {
  final String? title;
  final String? description;
  final String? errorCode;
  final VoidCallback? onRetry;
  final VoidCallback? onGoBack;

  const AppErrorScreen({
    super.key,
    this.title,
    this.description,
    this.errorCode,
    this.onRetry,
    this.onGoBack,
  });

  @override
  Widget build(BuildContext context) {
    final errTitle = title ?? context.l10n.errorOccurred;
    final errDesc = description ?? context.l10n.errorGenericDesc;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // Error icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: AppTheme.error.withValues(alpha: 0.3), width: 2),
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: AppTheme.error, size: 56),
              ),
              const SizedBox(height: 32),

              // Error code badge (e.g. "404", "500")
              if (errorCode != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('Error $errorCode',
                      style: const TextStyle(
                          color: AppTheme.error,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0)),
                ),
                const SizedBox(height: 16),
              ],

              // Title
              Text(errTitle,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 16),

              // Description
              Text(errDesc,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 14, height: 1.6),
                  textAlign: TextAlign.center),

              const Spacer(flex: 2),

              // Action buttons
              if (onRetry != null)
                SolidConfirmButton(
                  label: context.l10n.tryAgain,
                  icon: Icons.refresh,
                  height: 50,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onRetry!();
                  },
                ),
              if (onRetry != null && onGoBack != null)
                const SizedBox(height: 12),
              if (onGoBack != null)
                OutlineActionButton(
                  label: context.l10n.goBack,
                  icon: const Icon(Icons.arrow_back,
                      color: AppTheme.brand, size: 18),
                  height: 50,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    onGoBack!();
                  },
                ),
              // If no callbacks are provided, show a generic back button
              if (onRetry == null && onGoBack == null)
                OutlineActionButton(
                  label: context.l10n.goBack,
                  icon: const Icon(Icons.arrow_back,
                      color: AppTheme.brand, size: 18),
                  height: 50,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).maybePop();
                  },
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// FLUTTER ERROR WIDGET BUILDER
// Replaces the default red/yellow error screen with a branded screen.
// =============================================================================
class AppErrorWidgetBuilder {
  /// Installs a custom ErrorWidget.builder that shows a branded error screen
  /// instead of the default Flutter red error message.
  static void install() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return _InlineErrorWidget(details: details);
    };
  }
}

class _InlineErrorWidget extends StatelessWidget {
  final FlutterErrorDetails details;
  const _InlineErrorWidget({required this.details});

  @override
  Widget build(BuildContext context) {
    // Parse error type for a friendlier message
    final errorString = details.exception.toString();
    String friendlyTitle = 'Something Went Wrong';
    String friendlyDesc =
        'An unexpected rendering error occurred. This section of the app could not be displayed.';
    String? code;

    if (errorString.contains('404') || errorString.contains('Not Found')) {
      friendlyTitle = 'Page Not Found';
      friendlyDesc =
          'The content you are looking for does not exist or has been moved.';
      code = '404';
    } else if (errorString.contains('timeout') ||
        errorString.contains('Timeout')) {
      friendlyTitle = 'Connection Timed Out';
      friendlyDesc =
          'The request took too long. Please check your connection and try again.';
      code = 'TIMEOUT';
    } else if (errorString.contains('network') ||
        errorString.contains('SocketException')) {
      friendlyTitle = 'Network Error';
      friendlyDesc =
          'Unable to connect to the server. Please check your internet connection.';
      code = 'NETWORK';
    }

    return Material(
      color: AppTheme.bg,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: AppTheme.error, size: 36),
              ),
              const SizedBox(height: 20),
              if (code != null) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppTheme.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12)),
                  child: Text(code,
                      style: const TextStyle(
                          color: AppTheme.error,
                          fontSize: 12,
                          fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
              ],
              Text(friendlyTitle,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(friendlyDesc,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              OutlineActionButton(
                label: context.l10n.goBack,
                icon: const Icon(Icons.arrow_back,
                    color: AppTheme.brand, size: 18),
                height: 44,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
