import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

// =============================================================================
// DURATIONS
// =============================================================================
class AppDurations {
  const AppDurations._();

  static const Duration instant       = Duration.zero;
  static const Duration veryFast      = Duration(milliseconds: 120);
  static const Duration fast          = Duration(milliseconds: 160);
  static const Duration standard      = Duration(milliseconds: 260);
  static const Duration screen        = Duration(milliseconds: 340);
  static const Duration modal         = Duration(milliseconds: 360);
  static const Duration slowReveal    = Duration(milliseconds: 480);
  static const Duration staggerStep   = Duration(milliseconds: 35);

  // ── Editorial / VFX ──────────────────────────────────────────────────────
  static const Duration panelWipe           = Duration(milliseconds: 680);
  static const Duration menuOpenClose       = Duration(milliseconds: 560);
  static const Duration heroTitle           = Duration(milliseconds: 700);
  static const Duration heroSubtitle        = Duration(milliseconds: 500);
  static const Duration emblemReveal        = Duration(milliseconds: 600);
  static const Duration canvasTransition    = Duration(milliseconds: 800);
  static const Duration hairlineDraw        = Duration(milliseconds: 550);
  static const Duration metadataReveal      = Duration(milliseconds: 400);
  static const Duration menuRowStagger      = Duration(milliseconds: 55);
  static const Duration cinematicImageFade  = Duration(milliseconds: 900);
}

// =============================================================================
// CURVES
// =============================================================================
class AppCurves {
  const AppCurves._();

  static const Curve entrance   = Curves.easeOutCubic;
  static const Curve exit       = Curves.easeInCubic;
  static const Curve standard   = Curves.easeInOutCubic;
  static const Curve emphasized = Curves.fastOutSlowIn;
  static const Curve press      = Curves.easeOutCubic;

  // ── Editorial / VFX ──────────────────────────────────────────────────────
  /// Sharp deceleration — panel wipes, hero reveals.
  static const Curve panelWipe    = Cubic(0.22, 1.0, 0.36, 1.0);
  /// Symmetric — full-screen canvas transitions.
  static const Curve symmetric    = Cubic(0.65, 0.0, 0.35, 1.0);
  /// Gentle settle — emblem / metadata reveals.
  static const Curve gentleSettle = Cubic(0.34, 1.0, 0.64, 1.0);
}

// =============================================================================
// HAPTICS
// =============================================================================
enum AppMotionHaptic { none, light, selection }

// =============================================================================
// CORE HELPERS
// =============================================================================
class AppMotion {
  const AppMotion._();

  static bool reduceMotion(BuildContext context) {
    final media = MediaQuery.maybeOf(context);
    return media?.disableAnimations == true ||
        media?.accessibleNavigation == true;
  }

  static Duration duration(BuildContext context, Duration base) =>
      reduceMotion(context) ? AppDurations.instant : base;

  // ── Page / Route builders ─────────────────────────────────────────────────
  static PageRouteBuilder<T> pageRoute<T>(
    Widget page, {
    RouteSettings? settings,
    bool fullscreenDialog = false,
  }) {
    return PageRouteBuilder<T>(
      settings: settings,
      fullscreenDialog: fullscreenDialog,
      transitionDuration:
          fullscreenDialog ? AppDurations.modal : AppDurations.screen,
      reverseTransitionDuration: AppDurations.standard,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder:
          fullscreenDialog ? fadeTransitions : screenTransitions,
    );
  }

  static CustomTransitionPage<T> goRouterPage<T>({
    required LocalKey key,
    required Widget child,
    String? name,
    Object? arguments,
    String? restorationId,
    bool fullscreenDialog = false,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      fullscreenDialog: fullscreenDialog,
      transitionDuration:
          fullscreenDialog ? AppDurations.modal : AppDurations.screen,
      reverseTransitionDuration: AppDurations.standard,
      transitionsBuilder:
          fullscreenDialog ? fadeTransitions : screenTransitions,
      child: child,
    );
  }

  static CustomTransitionPage<T> fadeGoRouterPage<T>({
    required LocalKey key,
    required Widget child,
    String? name,
    Object? arguments,
    String? restorationId,
    bool fullscreenDialog = true,
    bool opaque = true,
    bool barrierDismissible = false,
    Color? barrierColor,
    String? barrierLabel,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      fullscreenDialog: fullscreenDialog,
      opaque: opaque,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      barrierLabel: barrierLabel,
      transitionDuration: AppDurations.modal,
      reverseTransitionDuration: AppDurations.standard,
      transitionsBuilder: fadeTransitions,
      child: child,
    );
  }

  // ── Standard screen transition (fade + subtle slide) ─────────────────────
  static Widget screenTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (reduceMotion(context)) return child;

    final curved = CurvedAnimation(
      parent: animation,
      curve: AppCurves.entrance,
      reverseCurve: AppCurves.exit,
    );
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    );
  }

  static Widget fadeTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (reduceMotion(context)) return child;

    final curved = CurvedAnimation(
      parent: animation,
      curve: AppCurves.entrance,
      reverseCurve: AppCurves.exit,
    );
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(curved),
      child: child,
    );
  }

  // ── Dialog / Bottom-sheet transitions ────────────────────────────────────
  static Widget dialogTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (reduceMotion(context)) return child;

    return fadeTransitions(context, animation, secondaryAnimation, child);
  }

  // ── showPremiumDialog ─────────────────────────────────────────────────────
  static Future<T?> showPremiumDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    String? barrierLabel,
    bool useRootNavigator = true,
    RouteSettings? routeSettings,
  }) {
    final navigator =
        Navigator.of(context, rootNavigator: useRootNavigator);
    final capturedThemes = InheritedTheme.capture(
      from: context,
      to: navigator.context,
    );
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor:
          barrierColor ?? Colors.black.withValues(alpha: 0.62),
      barrierLabel: barrierLabel ??
          MaterialLocalizations.of(context).modalBarrierDismissLabel,
      useRootNavigator: useRootNavigator,
      routeSettings: routeSettings,
      transitionDuration: duration(context, AppDurations.modal),
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        return capturedThemes.wrap(
          SafeArea(child: Builder(builder: builder)),
        );
      },
      transitionBuilder: dialogTransitions,
    );
  }

  // ── showPremiumBottomSheet ────────────────────────────────────────────────
  static Future<T?> showPremiumBottomSheet<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Color? backgroundColor,
    ShapeBorder? shape,
    bool isScrollControlled = false,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool enableDrag = true,
    bool useSafeArea = false,
    Color? barrierColor,
    BoxConstraints? constraints,
    RouteSettings? routeSettings,
  }) async {
    final navigator =
        Navigator.of(context, rootNavigator: useRootNavigator);
    final controller =
        BottomSheet.createAnimationController(navigator)
          ..duration = duration(context, AppDurations.modal)
          ..reverseDuration =
              duration(context, AppDurations.standard);

    try {
      return await showModalBottomSheet<T>(
        context: context,
        builder: builder,
        backgroundColor: backgroundColor,
        shape: shape,
        isScrollControlled: isScrollControlled,
        useRootNavigator: useRootNavigator,
        isDismissible: isDismissible,
        enableDrag: enableDrag,
        useSafeArea: useSafeArea,
        barrierColor: barrierColor,
        constraints: constraints,
        routeSettings: routeSettings,
        transitionAnimationController: controller,
      );
    } finally {
      controller.dispose();
    }
  }

  // ── Haptics ───────────────────────────────────────────────────────────────
  static void runHaptic(AppMotionHaptic haptic) {
    switch (haptic) {
      case AppMotionHaptic.none:
        return;
      case AppMotionHaptic.light:
        HapticFeedback.lightImpact();
        return;
      case AppMotionHaptic.selection:
        HapticFeedback.selectionClick();
        return;
    }
  }
}

// =============================================================================
// PAGE TRANSITIONS BUILDER (Navigator 1.0)
// =============================================================================
class AppPageTransitionsBuilder extends PageTransitionsBuilder {
  const AppPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) =>
      AppMotion.screenTransitions(
          context, animation, secondaryAnimation, child);
}

// =============================================================================
// EDITORIAL PANEL WIPE TRANSITION
// Slides a solid panel (cream or dark) horizontally to mask/reveal content.
// =============================================================================
class AppPanelWipe extends StatefulWidget {
  final Widget child;
  final Color panelColor;
  /// [true] = wipe enters from left; [false] = enters from right.
  final bool fromLeft;
  final Duration duration;
  final Curve curve;
  final bool enabled;

  const AppPanelWipe({
    super.key,
    required this.child,
    this.panelColor = const Color(0xFFF5F0E8),   // warm cream
    this.fromLeft = true,
    this.duration = AppDurations.panelWipe,
    this.curve = AppCurves.panelWipe,
    this.enabled = true,
  });

  @override
  State<AppPanelWipe> createState() => _AppPanelWipeState();
}

class _AppPanelWipeState extends State<AppPanelWipe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.enabled || AppMotion.reduceMotion(context)) {
        _ctrl.value = 1;
        return;
      }
      _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || AppMotion.reduceMotion(context)) {
      return widget.child;
    }

    final curved =
        CurvedAnimation(parent: _ctrl, curve: widget.curve);

    return AnimatedBuilder(
      animation: curved,
      child: widget.child,
      builder: (context, child) {
        // Panel slides OUT to reveal the child beneath.
        final panelOffset = widget.fromLeft
            ? Offset(-(curved.value), 0)
            : Offset(curved.value, 0);

        return Stack(
          children: [
            // Revealed content fades in gently.
            Opacity(
              opacity: Curves.easeInCubic.transform(curved.value),
              child: child,
            ),
            // Sliding panel mask.
            SlideTransition(
              position: AlwaysStoppedAnimation(panelOffset),
              child: Container(color: widget.panelColor),
            ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// CREAM CANVAS INTERSTITIAL
// Full-screen warm-cream canvas with a centered emblem; used between major
// route changes.  Drive [show] from parent state.
// =============================================================================
class AppCreamCanvasInterstitial extends StatelessWidget {
  final bool show;
  final Widget? emblem;
  final Color canvasColor;
  final Duration duration;

  const AppCreamCanvasInterstitial({
    super.key,
    required this.show,
    this.emblem,
    this.canvasColor = const Color(0xFFF5F0E8),
    this.duration = AppDurations.canvasTransition,
  });

  @override
  Widget build(BuildContext context) {
    final visibleEmblem = emblem;

    return AnimatedSwitcher(
      duration: AppMotion.reduceMotion(context)
          ? AppDurations.instant
          : duration,
      switchInCurve: AppCurves.panelWipe,
      switchOutCurve: AppCurves.symmetric,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      child: show
          ? Container(
              key: const ValueKey('cream-canvas'),
              color: canvasColor,
              alignment: Alignment.center,
              child: visibleEmblem != null
                  ? AppScaleFadeTransition(
                      beginScale: 0.94,
                      duration: AppDurations.emblemReveal,
                      child: visibleEmblem,
                    )
                  : null,
            )
          : const SizedBox.shrink(key: ValueKey('canvas-hidden')),
    );
  }
}

// =============================================================================
// CENTER-OUT DARK REVEAL
// A dark panel expands from the vertical centre axis to fill the screen.
// =============================================================================
class AppCenterOutDarkReveal extends StatefulWidget {
  final Widget child;
  final Color darkColor;
  final Duration duration;
  final Curve curve;
  final bool enabled;

  const AppCenterOutDarkReveal({
    super.key,
    required this.child,
    this.darkColor = const Color(0xFF111315),
    this.duration = AppDurations.canvasTransition,
    this.curve = AppCurves.panelWipe,
    this.enabled = true,
  });

  @override
  State<AppCenterOutDarkReveal> createState() =>
      _AppCenterOutDarkRevealState();
}

class _AppCenterOutDarkRevealState extends State<AppCenterOutDarkReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.enabled || AppMotion.reduceMotion(context)) {
        _ctrl.value = 1;
        return;
      }
      _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || AppMotion.reduceMotion(context)) {
      return widget.child;
    }

    final curved =
        CurvedAnimation(parent: _ctrl, curve: widget.curve);

    return AnimatedBuilder(
      animation: curved,
      child: widget.child,
      builder: (context, child) {
        // Scale from 0 width (centre) to full width.
        return Stack(
          children: [
            Opacity(
              opacity: curved.value,
              child: child,
            ),
            if (curved.value < 1.0)
              Align(
                alignment: Alignment.center,
                child: FractionallySizedBox(
                  widthFactor: 1.0 - curved.value,
                  child: Container(color: widget.darkColor),
                ),
              ),
          ],
        );
      },
    );
  }
}

// =============================================================================
// ANIMATED HAIRLINE DIVIDER
// A 1px line that draws in from an edge or from the centre.
// =============================================================================
enum HairlineDirection { leftToRight, rightToLeft, topToBottom, centerOut }

class AppHairlineDivider extends StatefulWidget {
  final bool horizontal;
  final HairlineDirection direction;
  final Color color;
  final Duration delay;
  final Duration duration;
  final double thickness;
  final bool enabled;

  const AppHairlineDivider({
    super.key,
    this.horizontal = true,
    this.direction = HairlineDirection.leftToRight,
    this.color = const Color(0x22FFFFFF),
    this.delay = Duration.zero,
    this.duration = AppDurations.hairlineDraw,
    this.thickness = 1.0,
    this.enabled = true,
  });

  @override
  State<AppHairlineDivider> createState() => _AppHairlineDividerState();
}

class _AppHairlineDividerState extends State<AppHairlineDivider>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.enabled || AppMotion.reduceMotion(context)) {
        _ctrl.value = 1;
        return;
      }
      Future<void>.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || AppMotion.reduceMotion(context)) {
      return Container(
        width: widget.horizontal ? double.infinity : widget.thickness,
        height: widget.horizontal ? widget.thickness : double.infinity,
        color: widget.color,
      );
    }

    final curved =
        CurvedAnimation(parent: _ctrl, curve: AppCurves.panelWipe);

    return AnimatedBuilder(
      animation: curved,
      builder: (context, _) {
        double progressValue = curved.value;

        if (widget.horizontal) {
          return SizedBox(
            height: widget.thickness,
            child: FractionallySizedBox(
              widthFactor: progressValue,
              alignment:
                  widget.direction == HairlineDirection.rightToLeft
                      ? Alignment.centerRight
                      : widget.direction == HairlineDirection.centerOut
                          ? Alignment.center
                          : Alignment.centerLeft,
              child: Container(color: widget.color),
            ),
          );
        } else {
          return SizedBox(
            width: widget.thickness,
            child: FractionallySizedBox(
              heightFactor: progressValue,
              alignment:
                  widget.direction == HairlineDirection.centerOut
                      ? Alignment.center
                      : Alignment.topCenter,
              child: Container(color: widget.color),
            ),
          );
        }
      },
    );
  }
}

// =============================================================================
// HERO TITLE REVEAL
// Large title text fades in + subtle scale.  Optional delayed subtitle.
// =============================================================================
class AppHeroTitleReveal extends StatelessWidget {
  final String title;
  final String? subtitle;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;
  final Duration delay;
  final bool enabled;

  const AppHeroTitleReveal({
    super.key,
    required this.title,
    this.subtitle,
    this.titleStyle,
    this.subtitleStyle,
    this.delay = Duration.zero,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppScaleFadeTransition(
          delay: delay,
          duration: AppDurations.heroTitle,
          curve: AppCurves.panelWipe,
          beginScale: 0.96,
          enabled: enabled,
          child: Text(
            title,
            style: titleStyle ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  height: 1.1,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        if (subtitleText != null) ...[
          const SizedBox(height: 12),
          AppFadeSlideTransition(
            delay: delay +
                const Duration(milliseconds: 200),
            duration: AppDurations.heroSubtitle,
            curve: AppCurves.gentleSettle,
            offset: const Offset(0, 0.03),
            enabled: enabled,
            child: Text(
              subtitleText,
              style: subtitleStyle ??
                  const TextStyle(
                    color: Color(0xFFA0A5AA),
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    height: 1.5,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}

// =============================================================================
// CINEMATIC IMAGE REVEAL
// Dark hero image that fades in slowly from near-black to its natural opacity.
// =============================================================================
class AppCinematicImageReveal extends StatefulWidget {
  final Widget image;
  final double beginOpacity;
  final double endOpacity;
  final Duration delay;
  final Duration duration;
  final bool enabled;

  const AppCinematicImageReveal({
    super.key,
    required this.image,
    this.beginOpacity = 0.0,
    this.endOpacity = 0.72,
    this.delay = Duration.zero,
    this.duration = AppDurations.cinematicImageFade,
    this.enabled = true,
  });

  @override
  State<AppCinematicImageReveal> createState() =>
      _AppCinematicImageRevealState();
}

class _AppCinematicImageRevealState extends State<AppCinematicImageReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: widget.duration);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.enabled || AppMotion.reduceMotion(context)) {
        _ctrl.value = 1;
        return;
      }
      Future<void>.delayed(widget.delay, () {
        if (mounted) _ctrl.forward();
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || AppMotion.reduceMotion(context)) {
      return Opacity(opacity: widget.endOpacity, child: widget.image);
    }

    final curved = CurvedAnimation(
        parent: _ctrl, curve: AppCurves.gentleSettle);

    return AnimatedBuilder(
      animation: curved,
      child: widget.image,
      builder: (context, child) {
        final opacity = widget.beginOpacity +
            (widget.endOpacity - widget.beginOpacity) *
                curved.value;
        return Opacity(opacity: opacity, child: child);
      },
    );
  }
}

// =============================================================================
// STAGGERED MENU ROW REVEAL
// Wraps a list of menu rows and animates each in sequentially.
// =============================================================================
class AppMenuRowReveal extends StatelessWidget {
  final List<Widget> rows;
  final Duration initialDelay;
  final Duration stepDelay;
  final bool enabled;

  const AppMenuRowReveal({
    super.key,
    required this.rows,
    this.initialDelay = Duration.zero,
    this.stepDelay = AppDurations.menuRowStagger,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: rows.asMap().entries.map((entry) {
        final i = entry.key;
        final row = entry.value;
        return AppFadeSlideTransition(
          delay: initialDelay + (stepDelay * i),
          duration: AppDurations.menuOpenClose,
          curve: AppCurves.panelWipe,
          offset: const Offset(-0.04, 0),
          enabled: enabled,
          child: row,
        );
      }).toList(),
    );
  }
}

// =============================================================================
// MENU ROW SELECTION HIGHLIGHT
// Warm beige band that slides in behind the selected row text.
// =============================================================================
class AppMenuRowHighlight extends StatelessWidget {
  final Widget child;
  final bool selected;
  final Color highlightColor;
  final Duration duration;

  const AppMenuRowHighlight({
    super.key,
    required this.child,
    required this.selected,
    this.highlightColor = const Color(0x18F5F0E8),  // very soft cream
    this.duration = AppDurations.fast,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppMotion.reduceMotion(context)
          ? AppDurations.instant
          : duration,
      curve: AppCurves.entrance,
      decoration: BoxDecoration(
        color: selected ? highlightColor : Colors.transparent,
      ),
      child: child,
    );
  }
}

// =============================================================================
// METADATA / FOOTER STAGGERED REVEAL
// Small supporting elements that fade in after the hero title.
// =============================================================================
class AppMetadataReveal extends StatelessWidget {
  final List<Widget> items;
  final Duration initialDelay;
  final Duration stepDelay;
  final MainAxisAlignment mainAxisAlignment;
  final bool enabled;

  const AppMetadataReveal({
    super.key,
    required this.items,
    this.initialDelay = const Duration(milliseconds: 300),
    this.stepDelay = const Duration(milliseconds: 60),
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      children: items.asMap().entries.map((entry) {
        return AppFadeSlideTransition(
          delay: initialDelay +
              (stepDelay * entry.key),
          duration: AppDurations.metadataReveal,
          curve: AppCurves.gentleSettle,
          offset: const Offset(0, 0.025),
          enabled: enabled,
          child: entry.value,
        );
      }).toList(),
    );
  }
}

// =============================================================================
// APP FADE SLIDE TRANSITION  (unchanged public API)
// =============================================================================
class AppFadeSlideTransition extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final Offset offset;
  final bool enabled;

  const AppFadeSlideTransition({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppDurations.standard,
    this.curve = AppCurves.entrance,
    this.offset = const Offset(0, 0.035),
    this.enabled = true,
  });

  @override
  State<AppFadeSlideTransition> createState() =>
      _AppFadeSlideTransitionState();
}

class _AppFadeSlideTransitionState extends State<AppFadeSlideTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.enabled || AppMotion.reduceMotion(context)) {
        _controller.value = 1;
        return;
      }
      if (widget.delay == Duration.zero) {
        _controller.forward();
        return;
      }
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    });
  }

  @override
  void didUpdateWidget(covariant AppFadeSlideTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || AppMotion.reduceMotion(context)) {
      return widget.child;
    }
    final curved =
        CurvedAnimation(parent: _controller, curve: widget.curve);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(curved),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: widget.offset,
          end: Offset.zero,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}

// =============================================================================
// APP SCALE FADE TRANSITION  (unchanged public API)
// =============================================================================
class AppScaleFadeTransition extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Curve curve;
  final double beginScale;
  final bool enabled;

  const AppScaleFadeTransition({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppDurations.standard,
    this.curve = AppCurves.entrance,
    this.beginScale = 0.975,
    this.enabled = true,
  });

  @override
  State<AppScaleFadeTransition> createState() =>
      _AppScaleFadeTransitionState();
}

class _AppScaleFadeTransitionState extends State<AppScaleFadeTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (!widget.enabled || AppMotion.reduceMotion(context)) {
        _controller.value = 1;
        return;
      }
      if (widget.delay == Duration.zero) {
        _controller.forward();
        return;
      }
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    });
  }

  @override
  void didUpdateWidget(covariant AppScaleFadeTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || AppMotion.reduceMotion(context)) {
      return widget.child;
    }
    final curved =
        CurvedAnimation(parent: _controller, curve: widget.curve);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(curved),
      child: ScaleTransition(
        scale: Tween<double>(
          begin: widget.beginScale,
          end: 1,
        ).animate(curved),
        child: widget.child,
      ),
    );
  }
}

// =============================================================================
// APP ANIMATED SWITCHER  (unchanged public API)
// =============================================================================
class AppAnimatedSwitcher extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve switchInCurve;
  final Curve switchOutCurve;
  final AnimatedSwitcherLayoutBuilder layoutBuilder;

  const AppAnimatedSwitcher({
    super.key,
    required this.child,
    this.duration = AppDurations.standard,
    this.reverseDuration,
    this.switchInCurve = AppCurves.entrance,
    this.switchOutCurve = AppCurves.exit,
    this.layoutBuilder = AnimatedSwitcher.defaultLayoutBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: AppMotion.duration(context, duration),
      reverseDuration:
          AppMotion.duration(context, reverseDuration ?? duration),
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      layoutBuilder: layoutBuilder,
      transitionBuilder: (child, animation) {
        if (AppMotion.reduceMotion(context)) return child;
        final curved = CurvedAnimation(
          parent: animation,
          curve: AppCurves.entrance,
          reverseCurve: AppCurves.exit,
        );
        return FadeTransition(
          opacity: Tween<double>(begin: 0, end: 1).animate(curved),
          child: ScaleTransition(
            scale:
                Tween<double>(begin: 0.985, end: 1).animate(curved),
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.025),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

// =============================================================================
// APP STAGGERED LIST  (unchanged public API)
// =============================================================================
class AppStaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration initialDelay;
  final Duration stepDelay;
  final Duration duration;
  final Axis direction;
  final int animateLimit;
  final Offset offset;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisAlignment mainAxisAlignment;
  final MainAxisSize mainAxisSize;

  const AppStaggeredList({
    super.key,
    required this.children,
    this.initialDelay = Duration.zero,
    this.stepDelay = AppDurations.staggerStep,
    this.duration = AppDurations.standard,
    this.direction = Axis.vertical,
    this.animateLimit = 24,
    this.offset = const Offset(0, 0.035),
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  @override
  Widget build(BuildContext context) {
    if (children.length > animateLimit ||
        AppMotion.reduceMotion(context)) {
      return direction == Axis.vertical
          ? Column(
              crossAxisAlignment: crossAxisAlignment,
              mainAxisAlignment: mainAxisAlignment,
              mainAxisSize: mainAxisSize,
              children: children,
            )
          : Row(
              crossAxisAlignment: crossAxisAlignment,
              mainAxisAlignment: mainAxisAlignment,
              mainAxisSize: mainAxisSize,
              children: children,
            );
    }

    final revealed = children.asMap().entries.map((entry) {
      return AppFadeSlideTransition(
        delay: initialDelay + (stepDelay * entry.key),
        duration: duration,
        offset: offset,
        child: entry.value,
      );
    }).toList();

    return direction == Axis.vertical
        ? Column(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: revealed,
          )
        : Row(
            crossAxisAlignment: crossAxisAlignment,
            mainAxisAlignment: mainAxisAlignment,
            mainAxisSize: mainAxisSize,
            children: revealed,
          );
  }
}

// =============================================================================
// APP TAB PAGE TRANSITION  (unchanged public API)
// =============================================================================
class AppTabPageTransition extends StatelessWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;
  final Curve curve;

  const AppTabPageTransition({
    super.key,
    required this.index,
    required this.children,
    this.duration = AppDurations.standard,
    this.curve = AppCurves.entrance,
  });

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduceMotion(context)) {
      return IndexedStack(index: index, children: children);
    }
    return Stack(
      children: [
        for (var i = 0; i < children.length; i++)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: i != index,
              child: TickerMode(
                enabled: i == index,
                child: AnimatedOpacity(
                  opacity: i == index ? 1 : 0,
                  duration: AppMotion.duration(context, duration),
                  curve: curve,
                  child: AnimatedSlide(
                    offset: i == index
                        ? Offset.zero
                        : const Offset(0, 0.012),
                    duration: AppMotion.duration(context, duration),
                    curve: curve,
                    child: children[i],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// APP PRESSABLE  (unchanged public API)
// =============================================================================
class AppPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double pressedScale;
  final double pressedOpacity;
  final Duration duration;
  final Curve curve;
  final HitTestBehavior behavior;
  final AppMotionHaptic haptic;
  final BorderRadius? borderRadius;

  const AppPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.pressedScale = 0.97,
    this.pressedOpacity = 0.9,
    this.duration = AppDurations.veryFast,
    this.curve = AppCurves.press,
    this.behavior = HitTestBehavior.opaque,
    this.haptic = AppMotionHaptic.selection,
    this.borderRadius,
  });

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable> {
  bool _pressed = false;

  bool get _canPress =>
      widget.enabled &&
      (widget.onTap != null || widget.onLongPress != null);

  void _setPressed(bool value) {
    if (!_canPress || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    if (!_canPress) return;
    AppMotion.runHaptic(widget.haptic);
    widget.onTap?.call();
  }

  void _handleLongPress() {
    if (!_canPress) return;
    AppMotion.runHaptic(widget.haptic);
    widget.onLongPress?.call();
  }

  @override
  Widget build(BuildContext context) {
    final borderRadius = widget.borderRadius;
    final reduced = AppMotion.reduceMotion(context);
    final motionChild = AnimatedScale(
      duration: AppMotion.duration(context, widget.duration),
      curve: widget.curve,
      scale: !reduced && _pressed ? widget.pressedScale : 1,
      child: AnimatedOpacity(
        duration: AppMotion.duration(context, widget.duration),
        curve: widget.curve,
        opacity: !reduced && _pressed ? widget.pressedOpacity : 1,
        child: widget.child,
      ),
    );

    return GestureDetector(
      behavior: widget.behavior,
      onTap: _canPress ? _handleTap : null,
      onLongPress: _canPress ? _handleLongPress : null,
      onTapDown: _canPress ? (_) => _setPressed(true) : null,
      onTapUp: _canPress ? (_) => _setPressed(false) : null,
      onTapCancel: _canPress ? () => _setPressed(false) : null,
      child: borderRadius == null
          ? motionChild
          : ClipRRect(
              borderRadius: borderRadius, child: motionChild),
    );
  }
}

// ── Aliases kept for backwards compatibility ──────────────────────────────
class AppButtonMotion extends AppPressable {
  const AppButtonMotion({
    super.key,
    required super.child,
    super.onTap,
    super.onLongPress,
    super.enabled,
    super.pressedScale,
    super.pressedOpacity,
    super.duration,
    super.curve,
    super.behavior,
    super.haptic,
    super.borderRadius,
  });
}

// =============================================================================
// APP SELECTION MOTION  (unchanged public API)
// =============================================================================
class AppSelectionMotion extends StatelessWidget {
  final Widget child;
  final bool selected;
  final double selectedScale;
  final Duration duration;
  final Curve curve;

  const AppSelectionMotion({
    super.key,
    required this.child,
    required this.selected,
    this.selectedScale = 1.012,
    this.duration = AppDurations.fast,
    this.curve = AppCurves.entrance,
  });

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduceMotion(context)) return child;
    return AnimatedScale(
      scale: selected ? selectedScale : 1,
      duration: AppMotion.duration(context, duration),
      curve: curve,
      child: child,
    );
  }
}

// =============================================================================
// APP SUCCESS REVEAL  (unchanged public API)
// =============================================================================
class AppSuccessReveal extends StatelessWidget {
  final Widget child;
  final bool visible;
  final Duration duration;

  const AppSuccessReveal({
    super.key,
    required this.child,
    this.visible = true,
    this.duration = AppDurations.standard,
  });

  @override
  Widget build(BuildContext context) {
    return AppAnimatedSwitcher(
      duration: duration,
      child: visible
          ? AppScaleFadeTransition(
              key: const ValueKey('success-visible'),
              duration: duration,
              beginScale: 0.96,
              child: child,
            )
          : const SizedBox.shrink(
              key: ValueKey('success-hidden')),
    );
  }
}

// =============================================================================
// APP ERROR SHAKE SUBTLE  (unchanged public API)
// =============================================================================
class AppErrorShakeSubtle extends StatefulWidget {
  final Widget child;
  final Object? trigger;
  final bool enabled;
  final double distance;
  final Duration duration;

  const AppErrorShakeSubtle({
    super.key,
    required this.child,
    this.trigger,
    this.enabled = true,
    this.distance = 4,
    this.duration = AppDurations.standard,
  });

  @override
  State<AppErrorShakeSubtle> createState() =>
      _AppErrorShakeSubtleState();
}

class _AppErrorShakeSubtleState extends State<AppErrorShakeSubtle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant AppErrorShakeSubtle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
    }
    if (widget.enabled &&
        oldWidget.trigger != widget.trigger &&
        !AppMotion.reduceMotion(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || AppMotion.reduceMotion(context)) {
      return widget.child;
    }
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final progress = _controller.value;
        final wave = math.sin(progress * math.pi * 4);
        final fade = 1 - progress;
        return Transform.translate(
          offset: Offset(wave * widget.distance * fade, 0),
          child: child,
        );
      },
    );
  }
}
