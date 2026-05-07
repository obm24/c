import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'animations/anim_motion.dart';
import 'c_constants.dart';
import 'c_ui_theme.dart';

// =============================================================================
// HAPTIC ALIAS
// =============================================================================
enum TnTHaptic { none, light, selection }

// =============================================================================
// TNT PRESSABLE  (unchanged public API)
// =============================================================================
class TnTPressable extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final double pressedScale;
  final double pressedOpacity;
  final HitTestBehavior behavior;
  final TnTHaptic haptic;
  final BorderRadius? borderRadius;

  const TnTPressable({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.pressedScale = 0.97,
    this.pressedOpacity = 0.88,
    this.behavior = HitTestBehavior.opaque,
    this.haptic = TnTHaptic.selection,
    this.borderRadius,
  });

  AppMotionHaptic get _appHaptic {
    switch (haptic) {
      case TnTHaptic.none:      return AppMotionHaptic.none;
      case TnTHaptic.light:     return AppMotionHaptic.light;
      case TnTHaptic.selection: return AppMotionHaptic.selection;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppPressable(
      onTap: onTap,
      onLongPress: onLongPress,
      enabled: enabled,
      pressedScale: pressedScale,
      pressedOpacity: pressedOpacity,
      behavior: behavior,
      haptic: _appHaptic,
      borderRadius: borderRadius,
      child: child,
    );
  }
}

// =============================================================================
// TNT PREMIUM CARD  (unchanged public API + editorial gradient support)
// =============================================================================
class TnTPremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final double? width;
  final double? height;
  final double radius;
  final Color? accentColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool elevated;
  final bool muted;
  final Clip clipBehavior;

  const TnTPremiumCard({
    super.key,
    required this.child,
    this.margin,
    this.padding = const EdgeInsets.all(16),
    this.width,
    this.height,
    this.radius = AppConstants.kDefaultBorderRadius,
    this.accentColor,
    this.backgroundColor,
    this.borderColor,
    this.onTap,
    this.onLongPress,
    this.elevated = true,
    this.muted = false,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final radiusValue = BorderRadius.circular(radius);
    final accent = accentColor;
    final card = Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      clipBehavior: clipBehavior,
      decoration: BoxDecoration(
        color: backgroundColor ??
            (muted ? AppTheme.surfaceLow : AppTheme.surfaceRaised),
        borderRadius: radiusValue,
        border:
            Border.all(color: borderColor ?? AppTheme.outlineSoft),
        gradient: accent == null
            ? AppTheme.surfaceGradient
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent.withValues(alpha: 0.14),
                  Colors.white.withValues(alpha: 0.018),
                  Colors.transparent,
                ],
                stops: const [0, 0.42, 1],
              ),
        boxShadow:
            elevated ? AppTheme.premiumShadow : null,
      ),
      child: child,
    );

    if (onTap == null && onLongPress == null) return card;
    return TnTPressable(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: radiusValue,
      child: card,
    );
  }
}

// =============================================================================
// TNT APPEAR  (unchanged public API)
// =============================================================================
class TnTAppear extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;
  final Curve curve;
  final bool enabled;

  const TnTAppear({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppDurations.standard,
    this.offsetY = 10,
    this.curve = AppCurves.entrance,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppFadeSlideTransition(
      delay: delay,
      duration: duration,
      curve: curve,
      offset: Offset(0, offsetY / 100),
      enabled: enabled,
      child: child,
    );
  }
}

// =============================================================================
// PREMIUM SELECTION BUTTON
// =============================================================================
class PremiumSelectionButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final bool enabled;
  final IconData? leadingIcon;
  final VoidCallback? onTap;
  final VoidCallback? onHelpTap;
  final String? helpTooltip;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final double minHeight;
  final double fontSize;

  const PremiumSelectionButton({
    super.key,
    required this.label,
    this.color = AppTheme.brand,
    this.selected = true,
    this.enabled = true,
    this.leadingIcon,
    this.onTap,
    this.onHelpTap,
    this.helpTooltip,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppConstants.kDefaultBorderRadius),
    ),
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 9),
    this.minHeight = 36,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final icon = leadingIcon;
    final helpAction = onHelpTap;
    final tooltip = helpTooltip?.trim();
    final foreground =
        selected ? color : AppTheme.textPrimary.withValues(alpha: 0.92);
    final borderColor = selected
        ? color.withValues(alpha: 0.48)
        : AppTheme.textSecondary.withValues(alpha: 0.44);
    final background = selected
        ? color.withValues(alpha: 0.12)
        : AppTheme.surface.withValues(alpha: 0.82);
    final minLabelFontSize = fontSize <= 9 ? fontSize : 9.0;

    final button = AppSelectionMotion(
      selected: selected,
      selectedScale: 1.01,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.entrance,
        constraints: BoxConstraints(minHeight: minHeight),
        padding: padding,
        decoration: BoxDecoration(
          color: background,
          borderRadius: borderRadius,
          border: Border.all(color: borderColor, width: 1.4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
            if (selected)
              BoxShadow(
                color: color.withValues(alpha: 0.10),
                blurRadius: 10,
                offset: const Offset(0, 0),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: foreground, size: 16),
              const SizedBox(width: 8),
            ],
            Flexible(
              fit: FlexFit.loose,
              child: AutoSizeText(
                label,
                maxLines: 2,
                minFontSize: minLabelFontSize,
                stepGranularity: 0.5,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                style: TextStyle(
                  color: foreground,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                  height: 1.15,
                ),
              ),
            ),
            if (helpAction != null) ...[
              const SizedBox(width: 10),
              _SelectionHelpButton(
                color: foreground,
                tooltip: tooltip,
                onTap: helpAction,
              ),
            ],
          ],
        ),
      ),
    );

    if (onTap == null || !enabled) return button;
    return TnTPressable(
      onTap: onTap,
      enabled: enabled,
      pressedScale: 0.96,
      borderRadius: borderRadius,
      child: button,
    );
  }
}

class _SelectionHelpButton extends StatelessWidget {
  final Color color;
  final String? tooltip;
  final VoidCallback onTap;

  const _SelectionHelpButton({
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final button = TnTPressable(
      onTap: onTap,
      haptic: TnTHaptic.light,
      pressedScale: 0.92,
      borderRadius: BorderRadius.circular(99),
      child: Container(
        width: 22,
        height: 22,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: 0.42),
            width: 1,
          ),
        ),
        child: Text(
          '?',
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );

    final text = tooltip;
    if (text == null || text.isEmpty) return button;
    return Tooltip(message: text, child: button);
  }
}

// =============================================================================
// TNT CHIP  (unchanged public API)
// =============================================================================
class TnTChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final bool selected;
  final bool compact;
  final VoidCallback? onTap;

  const TnTChip({
    super.key,
    required this.label,
    this.icon,
    this.color = AppTheme.brand,
    this.selected = false,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(999);
    final child = AppSelectionMotion(
      selected: selected,
      selectedScale: 1.02,
      child: AnimatedContainer(
        duration: AppDurations.fast,
        curve: AppCurves.entrance,
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8 : 10,
          vertical: compact ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: selected
              ? color.withValues(alpha: 0.18)
              : color.withValues(alpha: 0.09),
          borderRadius: radius,
          border: Border.all(
            color: color.withValues(
                alpha: selected ? 0.48 : 0.28),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  color: color, size: compact ? 11 : 13),
              SizedBox(width: compact ? 4 : 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: compact ? 10 : 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );

    if (onTap == null) return child;
    return TnTPressable(
      onTap: onTap,
      pressedScale: 0.96,
      borderRadius: radius,
      child: child,
    );
  }
}

// =============================================================================
// TNT EMPTY STATE  (unchanged public API)
// =============================================================================
class TnTEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  const TnTEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return AppFadeSlideTransition(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: 36, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceRaised,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.outlineSoft),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Icon(icon,
                    color: AppTheme.textSecondary, size: 32),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              if (message != null) ...[
                const SizedBox(height: 7),
                Text(
                  message!,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (action != null) ...[
                const SizedBox(height: 18),
                action!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// TNT SKELETON BLOCK  (unchanged public API)
// =============================================================================
class TnTSkeletonBlock extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final double opacity;
  final ShapeBorder? shape;

  const TnTSkeletonBlock({
    super.key,
    this.width,
    required this.height,
    this.radius = 8,
    this.opacity = 0.5,
    this.shape,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: shape == null
          ? BoxDecoration(
              color: AppTheme.surfaceRaised
                  .withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: Colors.white
                    .withValues(alpha: opacity * 0.05),
              ),
            )
          : ShapeDecoration(
              color: AppTheme.surfaceRaised
                  .withValues(alpha: opacity),
              shape: shape!,
            ),
    );
  }
}

// =============================================================================
// NEW — TNT SECTION HEADER
// Editorial overline + title + optional hairline.  Use at the top of every
// major screen section.
// =============================================================================
class TnTSectionHeader extends StatelessWidget {
  final String title;
  final String? overline;
  final String? trailing;
  final VoidCallback? onTrailingTap;
  final bool showDivider;
  final EdgeInsetsGeometry padding;
  final Duration delay;

  const TnTSectionHeader({
    super.key,
    required this.title,
    this.overline,
    this.trailing,
    this.onTrailingTap,
    this.showDivider = true,
    this.padding =
        const EdgeInsets.fromLTRB(0, 0, 0, 12),
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return AppFadeSlideTransition(
      delay: delay,
      duration: AppDurations.standard,
      offset: const Offset(0, 0.02),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (overline != null) ...[
              Text(
                overline!.toUpperCase(),
                style: AppTheme.overline(),
              ),
              const SizedBox(height: 6),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTheme.sectionHeading(),
                  ),
                ),
                if (trailing != null)
                  TnTPressable(
                    onTap: onTrailingTap,
                    child: Text(
                      trailing!,
                      style: AppTheme.caption(
                          color: AppTheme.brand),
                    ),
                  ),
              ],
            ),
            if (showDivider) ...[
              const SizedBox(height: 12),
              AppHairlineDivider(
                color: AppTheme.hairlineDark,
                delay: delay +
                    const Duration(milliseconds: 80),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// NEW — TNT STAT TILE
// Small metric card used in dashboards: label + value + optional trend badge.
// =============================================================================
class TnTStatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final String? trend;        // e.g. '+2.4%'
  final bool trendPositive;
  final Color? accentColor;
  final Duration delay;

  const TnTStatTile({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.trend,
    this.trendPositive = true,
    this.accentColor,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppTheme.brand;
    return TnTAppear(
      delay: delay,
      child: TnTPremiumCard(
        accentColor: accent,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label.toUpperCase(),
                style: AppTheme.overline()),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Bai Jamjuree',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    height: 1.0,
                  ),
                ),
                if (unit != null) ...[
                  const SizedBox(width: 4),
                  Padding(
                    padding:
                        const EdgeInsets.only(bottom: 3),
                    child: Text(unit!,
                        style: AppTheme.caption()),
                  ),
                ],
              ],
            ),
            if (trend != null) ...[
              const SizedBox(height: 6),
              _TrendBadge(
                  label: trend!,
                  positive: trendPositive),
            ],
          ],
        ),
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final String label;
  final bool positive;

  const _TrendBadge({required this.label, required this.positive});

  @override
  Widget build(BuildContext context) {
    final color =
        positive ? AppTheme.cardGreen : AppTheme.cardRed;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: color.withValues(alpha: 0.28)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Bai Jamjuree',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

// =============================================================================
// NEW — TNT EDITORIAL ROW
// A single interactive row with left content, optional leading icon, trailing
// widget, and the premium beige highlight on selection.
// Used for settings, menu rows, list items.
// =============================================================================
class TnTEditorialRow extends StatelessWidget {
  final String label;
  final String? sublabel;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool selected;
  final bool showDivider;
  final EdgeInsetsGeometry padding;

  const TnTEditorialRow({
    super.key,
    required this.label,
    this.sublabel,
    this.leading,
    this.trailing,
    this.onTap,
    this.selected = false,
    this.showDivider = true,
    this.padding = const EdgeInsets.symmetric(
        horizontal: 0, vertical: 14),
  });

  @override
  Widget build(BuildContext context) {
    return AppMenuRowHighlight(
      selected: selected,
      child: TnTPressable(
        onTap: onTap,
        pressedScale: 0.99,
        pressedOpacity: 0.7,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: padding,
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontFamily: 'Bai Jamjuree',
                            color: selected
                                ? AppTheme.textPrimary
                                : AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: selected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                        if (sublabel != null) ...[
                          const SizedBox(height: 2),
                          Text(sublabel!,
                              style: AppTheme.caption()),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...[
                    const SizedBox(width: 12),
                    trailing!,
                  ] else if (onTap != null)
                    const Icon(
                      Icons.chevron_right,
                      color: AppTheme.textTertiary,
                      size: 18,
                    ),
                ],
              ),
            ),
            if (showDivider)
              Container(
                height: 1,
                color: AppTheme.hairlineDark,
              ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// NEW — TNT HERO CARD
// Full-bleed dark card with a cinematic background image, hero title, and
// optional metadata strip at the bottom.  Used for programme / workout heroes.
// =============================================================================
class TnTHeroCard extends StatelessWidget {
  final Widget? backgroundImage;
  final String title;
  final String? subtitle;
  final String? overlineText;
  final List<Widget> metadataItems;
  final VoidCallback? onTap;
  final double height;
  final BorderRadius? borderRadius;

  const TnTHeroCard({
    super.key,
    this.backgroundImage,
    required this.title,
    this.subtitle,
    this.overlineText,
    this.metadataItems = const [],
    this.onTap,
    this.height = 220,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ??
        BorderRadius.circular(
            AppConstants.kDefaultBorderRadius + 2);

    return TnTPressable(
      onTap: onTap,
      borderRadius: radius,
      pressedScale: 0.985,
      pressedOpacity: 0.9,
      child: ClipRRect(
        borderRadius: radius,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            color: AppTheme.cinematicDark,
            borderRadius: radius,
            boxShadow: AppTheme.elevatedShadow,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cinematic background image
              if (backgroundImage != null)
                AppCinematicImageReveal(
                  endOpacity: 0.65,
                  image: backgroundImage!,
                ),

              // Hero scrim gradient
              Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.heroScrimGradient,
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    if (overlineText != null) ...[
                      AppFadeSlideTransition(
                        duration: AppDurations.metadataReveal,
                        offset: const Offset(0, 0.02),
                        child: Text(
                          overlineText!.toUpperCase(),
                          style: AppTheme.overline(
                              color: AppTheme.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                    const Spacer(),
                    AppHeroTitleReveal(
                      title: title,
                      subtitle: subtitle,
                      titleStyle: AppTheme.sectionHeading()
                          .copyWith(fontSize: 26),
                      subtitleStyle:
                          AppTheme.caption(),
                    ),
                    if (metadataItems.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      AppHairlineDivider(
                        color: AppTheme.hairlineDark,
                      ),
                      const SizedBox(height: 10),
                      AppMetadataReveal(
                        items: metadataItems,
                        initialDelay: const Duration(
                            milliseconds: 200),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// NEW — TNT DIVIDER  (convenience wrapper around AppHairlineDivider)
// Drop-in replacement for Flutter's Divider with editorial styling.
// =============================================================================
class TnTDivider extends StatelessWidget {
  final bool animated;
  final Color? color;
  final Duration delay;

  const TnTDivider({
    super.key,
    this.animated = false,
    this.color,
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return AppHairlineDivider(
      color: color ?? AppTheme.hairlineDark,
      delay: delay,
      enabled: animated,
    );
  }
}

// =============================================================================
// NEW — TNT PROGRESS BAR
// Slim animated progress bar with accent colour and editorial feel.
// =============================================================================
class TnTProgressBar extends StatelessWidget {
  final double value;           // 0.0 – 1.0
  final Color? color;
  final double height;
  final String? label;
  final String? trailing;
  final Duration animationDuration;

  const TnTProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 4,
    this.label,
    this.trailing,
    this.animationDuration = AppDurations.slowReveal,
  });

  @override
  Widget build(BuildContext context) {
    final accent = color ?? AppTheme.brand;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || trailing != null) ...[
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              if (label != null)
                Text(label!,
                    style: AppTheme.caption()),
              if (trailing != null)
                Text(trailing!,
                    style: AppTheme.caption(
                        color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 6),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(height),
          child: Stack(
            children: [
              // Track
              Container(
                height: height,
                color: AppTheme.surfaceHigh,
              ),
              // Fill
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
                duration: AppMotion.reduceMotion(context)
                    ? AppDurations.instant
                    : animationDuration,
                curve: AppCurves.panelWipe,
                builder: (context, v, _) {
                  return FractionallySizedBox(
                    widthFactor: v,
                    child: Container(
                      height: height,
                      decoration: BoxDecoration(
                        color: accent,
                        borderRadius:
                            BorderRadius.circular(height),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
