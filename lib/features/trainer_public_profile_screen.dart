import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_core_utils.dart';
import '../core/c_custom_controls.dart';
import '../core/c_visual_effects.dart';

// =============================================================================
// TRAINER PUBLIC PROFILE SCREEN
// =============================================================================
class TrainerPublicProfileScreen extends StatefulWidget {
  final Map<String, dynamic> trainer;
  const TrainerPublicProfileScreen({super.key, required this.trainer});
  @override
  State<TrainerPublicProfileScreen> createState() =>
      _TrainerPublicProfileScreenState();
}

class _TrainerPublicProfileScreenState extends State<TrainerPublicProfileScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isFollowing = false;
  final ScrollController _scrollController = ScrollController();
  bool _headerCollapsed = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final collapsed = _scrollController.offset > 260;
    if (collapsed != _headerCollapsed) {
      setState(() => _headerCollapsed = collapsed);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REPORT MODAL  (category → subcategory → confirmation)
  // ─────────────────────────────────────────────────────────────────────────
  void _showReportModal(BuildContext context) {
    String? selectedCategory;
    String? selectedSubcategory;
    bool submitted = false;

    const Map<String, List<String>> categories = {
      'Spam or Scam': [
        'Posting repetitive content',
        'Fake giveaways or promotions',
        'Directing to suspicious links',
        'Selling counterfeit goods',
      ],
      'Harassment or Bullying': [
        'Targeting an individual',
        'Threatening behaviour',
        'Coordinated harassment',
        'Sharing private information',
      ],
      'Misinformation': [
        'False health or fitness claims',
        'Dangerous advice',
        'Misleading credentials',
        'Medical misinformation',
      ],
      'Hate Speech': [
        'Targeting a race or ethnicity',
        'Targeting religion',
        'Targeting gender or sexuality',
        'Dehumanising content',
      ],
      'Violence or Dangerous Content': [
        'Graphic violence',
        'Glorifying self-harm',
        'Endangering minors',
        'Incitement to violence',
      ],
      'Intellectual Property': [
        'Copyright infringement',
        'Trademark violation',
        'Counterfeit merchandise',
      ],
      'Other': [
        'Impersonation',
        'Nudity or sexual content',
        'Something else',
      ],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setM) {
        if (submitted) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(32, 20, 32, 40),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _sheetHandle(),
              const SizedBox(height: 30),
              const Icon(Icons.check_circle_rounded,
                  color: Colors.greenAccent, size: 64),
              const SizedBox(height: 20),
              Text(context.l10n.reportSubmitted,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center),
              const SizedBox(height: 12),
              const Text(
                'Thank you for helping keep the community safe.\nOur Trust & Safety team will review your report within 24 hours. Your identity remains strictly confidential.',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 14, height: 1.6),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              SolidConfirmButton(
                  label: context.l10n.save,
                  height: AppConstants.kDefaultButtonHeightLarge,
                  onPressed: () => Navigator.pop(ctx)),
            ]),
          );
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.72,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scroll) => ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              _sheetHandle(),
              const SizedBox(height: 20),
              Row(children: [
                const Icon(Icons.flag_rounded, color: AppTheme.error, size: 22),
                const SizedBox(width: 10),
                Text(context.l10n.reportProfile,
                    style: const TextStyle(
                        color: AppTheme.error,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ]),
              const SizedBox(height: 6),
              const Text(
                'Help us understand what\'s wrong. Your report is anonymous and reviewed by our Trust & Safety team.',
                style: TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 20),
              const Divider(color: AppTheme.divider),
              const SizedBox(height: 16),
              Text(context.l10n.selectReason,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              ...categories.keys.map((cat) {
                final isSel = cat == selectedCategory;
                return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setM(() {
                            selectedCategory = cat;
                            selectedSubcategory = null;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppTheme.brand.withValues(alpha: 0.08)
                                : AppTheme.bg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color:
                                    isSel ? AppTheme.brand : AppTheme.divider,
                                width: isSel ? 1.5 : 1),
                          ),
                          child: Row(children: [
                            Expanded(
                                child: Text(cat,
                                    style: TextStyle(
                                        color: isSel
                                            ? AppTheme.brand
                                            : AppTheme.textPrimary,
                                        fontWeight: isSel
                                            ? FontWeight.bold
                                            : FontWeight.normal))),
                            Icon(
                                isSel
                                    ? Icons.keyboard_arrow_up
                                    : Icons.keyboard_arrow_down,
                                color: isSel
                                    ? AppTheme.brand
                                    : AppTheme.textSecondary,
                                size: 20),
                          ]),
                        ),
                      ),
                      if (isSel) ...[
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(context.l10n.beMoreSpecificTitle,
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12)),
                        ),
                        ...categories[cat]!.map((sub) {
                          final subSel = sub == selectedSubcategory;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setM(() => selectedSubcategory = sub);
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              margin: const EdgeInsets.only(left: 8, bottom: 6),
                              decoration: BoxDecoration(
                                color: subSel
                                    ? AppTheme.brand
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: subSel
                                        ? AppTheme.brand
                                        : AppTheme.divider),
                              ),
                              child: Row(children: [
                                Icon(
                                    subSel
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: subSel
                                        ? AppTheme.confirmationButtonText
                                        : AppTheme.textSecondary,
                                    size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                    child: Text(sub,
                                        style: TextStyle(
                                            color: subSel
                                                ? AppTheme
                                                    .confirmationButtonText
                                                : AppTheme.textPrimary,
                                            fontSize: 13,
                                            fontWeight: subSel
                                                ? FontWeight.bold
                                                : FontWeight.normal))),
                              ]),
                            ),
                          );
                        }),
                        const SizedBox(height: 8),
                      ],
                    ]);
              }),
              const SizedBox(height: 16),
              SolidConfirmButton(
                label: context.l10n.submitReport,
                height: AppConstants.kDefaultButtonHeightLarge,
                onPressed: selectedCategory != null
                    ? () {
                        HapticFeedback.selectionClick();
                        setM(() => submitted = true);
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              OutlineActionButton(
                label: context.l10n.cancel,
                height: AppConstants.kDefaultButtonHeightLarge,
                textColor: AppTheme.textPrimary,
                borderColor: AppTheme.textSecondary,
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SHARE SHEET
  // ─────────────────────────────────────────────────────────────────────────
  void _showShareSheet(BuildContext context) {
    final link = 'https://TnT.app/t/${widget.trainer['username']}';
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _sheetHandle(),
          const SizedBox(height: 25),
          Align(
              alignment: Alignment.centerLeft,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.l10n.shareProfile,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15),
                    const Divider(color: AppTheme.divider, height: 1),
                  ])),
          const SizedBox(height: 25),
          // Share-to chips row
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _shareChip(Icons.link, 'Copy Link', () {
              HapticFeedback.selectionClick();
              Clipboard.setData(ClipboardData(text: link));
              Navigator.pop(ctx);
              AppUtils.showToast(context, context.l10n.urlCopied);
            }),
            _shareChip(Icons.qr_code_2_rounded, 'QR Code', () {
              Navigator.pop(ctx);
              _showQrSheet(context, link);
            }),
            _shareChip(CupertinoIcons.chat_bubble_text_fill, 'Message', () {
              Clipboard.setData(ClipboardData(text: link));
              Navigator.pop(ctx);
              AppUtils.showToast(context, context.l10n.urlCopied);
            }),
          ]),
          const SizedBox(height: 25),
          // URL display bar
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                color: AppTheme.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.divider)),
            child: Row(children: [
              Expanded(
                  child: Text(link,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13),
                      overflow: TextOverflow.ellipsis)),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  Clipboard.setData(ClipboardData(text: link));
                  Navigator.pop(ctx);
                  AppUtils.showToast(context, context.l10n.urlCopied);
                },
                child: const Icon(Icons.copy, color: AppTheme.brand, size: 20),
              ),
            ]),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _shareChip(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
              color: AppTheme.bg,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.divider)),
          child: Icon(icon, color: AppTheme.brand, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }

  void _showQrSheet(BuildContext context, String link) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          _sheetHandle(),
          const SizedBox(height: 24),
          const Text('Profile QR Code',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          // Placeholder QR visual — replace with qr_flutter in production
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Center(
                child: Icon(Icons.qr_code_2_rounded,
                    color: Colors.black, size: 160)),
          ),
          const SizedBox(height: 20),
          Text(link,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
              textAlign: TextAlign.center),
          const SizedBox(height: 28),
          SolidConfirmButton(
              label: 'Save to Gallery',
              icon: Icons.download_rounded,
              height: AppConstants.kDefaultButtonHeightLarge,
              onPressed: () {
                Navigator.pop(ctx);
                AppUtils.showToast(context, 'QR saved to gallery');
              }),
          const SizedBox(height: 12),
          OutlineActionButton(
              label: context.l10n.cancel,
              height: AppConstants.kDefaultButtonHeightLarge,
              textColor: AppTheme.textPrimary,
              borderColor: AppTheme.textSecondary,
              onPressed: () => Navigator.pop(ctx)),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TESTIMONIALS MODAL
  // ─────────────────────────────────────────────────────────────────────────
  void _showTestimonialsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(24),
          children: [
            _sheetHandle(),
            const SizedBox(height: 20),
            Text(context.l10n.successStories,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Real results from real clients',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 15),
            const Divider(color: AppTheme.divider, height: 1),
            const SizedBox(height: 25),
            _testimonialCard(
                name: 'Sarah M.',
                result: 'Lost 30 lbs in 4 months',
                quote:
                    'Best investment I\'ve ever made. The personalised approach made all the difference.',
                before:
                    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
                after:
                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400'),
            _testimonialCard(
                name: 'John K.',
                result: 'Gained 15 lbs muscle',
                quote:
                    'Finally broke through my plateau with the right guidance and programming.',
                before:
                    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
                after:
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400'),
          ],
        ),
      ),
    );
  }

  Widget _testimonialCard({
    required String name,
    required String result,
    required String quote,
    required String before,
    required String after,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(before,
                  width: 80, height: 100, fit: BoxFit.cover)),
          const SizedBox(width: 15),
          Column(children: [
            const Icon(Icons.arrow_forward, color: AppTheme.brand, size: 22),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                  color: AppTheme.brand.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6)),
              child: const Text('Before / After',
                  style: TextStyle(
                      color: AppTheme.brand,
                      fontSize: 9,
                      fontWeight: FontWeight.bold)),
            ),
          ]),
          const SizedBox(width: 15),
          ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(after,
                  width: 80, height: 100, fit: BoxFit.cover)),
        ]),
        const SizedBox(height: 20),
        Row(children: [
          Text(name,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          const Icon(CupertinoIcons.checkmark_seal_fill,
              color: AppTheme.brand, size: 14),
        ]),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.greenAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6)),
          child: Text(result,
              style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 12),
        Text('"$quote"',
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                height: 1.4,
                fontStyle: FontStyle.italic)),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // REVIEWS MODAL
  // ─────────────────────────────────────────────────────────────────────────
  void _showReviewsModal(BuildContext context) {
    final reviews = [
      {
        'author': 'Omar K.',
        'rating': 5,
        'date': '2024-03-22',
        'content': 'Incredible transformation. The nutrition plan was spot on.',
        'verified': true
      },
      {
        'author': 'Sarah L.',
        'rating': 5,
        'date': '2024-02-15',
        'content': 'Very professional and responsive. Highly recommend!',
        'verified': true
      },
      {
        'author': 'Mike D.',
        'rating': 4,
        'date': '2024-01-10',
        'content':
            'Tough workouts but exactly what I needed to break my plateau.',
        'verified': false
      },
      {
        'author': 'Anonymous',
        'rating': 3,
        'date': '2023-12-05',
        'content':
            'Good programs but responses were sometimes delayed over the holidays.',
        'verified': false
      },
    ];

    // Aggregate stats
    final total = reviews.length;
    final avg =
        reviews.fold<double>(0, (sum, r) => sum + (r['rating'] as int)) / total;
    final Map<int, int> dist = {5: 0, 4: 0, 3: 0, 2: 0, 1: 0};
    for (final r in reviews) {
      dist[(r['rating'] as int)] = (dist[(r['rating'] as int)] ?? 0) + 1;
    }

    String filt = 'All', sort = 'Newest';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setM) {
        var displayed = reviews
            .where((r) =>
                filt == 'All' || r['rating'].toString() == filt.split(' ')[0])
            .toList();
        if (sort == 'Highest') {
          displayed.sort(
              (a, b) => (b['rating'] as int).compareTo(a['rating'] as int));
        } else if (sort == 'Lowest') {
          displayed.sort(
              (a, b) => (a['rating'] as int).compareTo(b['rating'] as int));
        } else if (sort == 'Oldest') {
          displayed.sort(
              (a, b) => (a['date'] as String).compareTo(b['date'] as String));
        } else {
          displayed.sort(
              (a, b) => (b['date'] as String).compareTo(a['date'] as String));
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scroll) => Column(children: [
            const SizedBox(height: 15),
            _sheetHandle(),
            const SizedBox(height: 20),
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.l10n.clientReviews,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      // ── Rating summary card ──────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                            color: AppTheme.bg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.divider)),
                        child: Row(children: [
                          // Big average
                          Column(children: [
                            Text(avg.toStringAsFixed(1),
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize: 44,
                                    fontWeight: FontWeight.bold,
                                    height: 1.0)),
                            Row(
                                children: List.generate(
                                    5,
                                    (j) => Icon(
                                        j < avg.round()
                                            ? Icons.star
                                            : Icons.star_border,
                                        color: AppTheme.cardYellow,
                                        size: 14))),
                            const SizedBox(height: 4),
                            Text('$total reviews',
                                style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                          ]),
                          const SizedBox(width: 20),
                          // Distribution bars
                          Expanded(
                              child: Column(
                                  children: [5, 4, 3, 2, 1].map((star) {
                            final count = dist[star] ?? 0;
                            final pct = total > 0 ? count / total : 0.0;
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(children: [
                                Text('$star',
                                    style: const TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11)),
                                const SizedBox(width: 4),
                                const Icon(Icons.star,
                                    color: AppTheme.cardYellow, size: 11),
                                const SizedBox(width: 6),
                                Expanded(
                                    child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                      value: pct,
                                      backgroundColor: AppTheme.divider,
                                      color: AppTheme.cardYellow,
                                      minHeight: 6),
                                )),
                                const SizedBox(width: 6),
                                SizedBox(
                                  width: 14,
                                  child: Text('$count',
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 11)),
                                ),
                              ]),
                            );
                          }).toList())),
                        ]),
                      ),
                      const SizedBox(height: 15),
                      const Divider(color: AppTheme.divider, height: 1),
                    ])),
            const SizedBox(height: 12),
            // Filter / sort
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(children: [
                  Expanded(
                      child: _dropdownPill(
                          filt,
                          ['All', '5 Stars', '4 Stars', '3 Stars'],
                          'Filter',
                          (v) => setM(() => filt = v!))),
                  const SizedBox(width: 15),
                  Expanded(
                      child: _dropdownPill(
                          sort,
                          ['Newest', 'Oldest', 'Highest', 'Lowest'],
                          'Sort',
                          (v) => setM(() => sort = v!))),
                ])),
            const SizedBox(height: 12),
            const Divider(color: AppTheme.divider, height: 1),
            Expanded(
              child: displayed.isEmpty
                  ? Center(
                      child: Text(context.l10n.noReviewsMatch,
                          style:
                              const TextStyle(color: AppTheme.textSecondary)))
                  : ListView.separated(
                      controller: scroll,
                      padding: const EdgeInsets.all(24),
                      itemCount: displayed.length,
                      separatorBuilder: (_, __) =>
                          const Divider(color: AppTheme.divider, height: 30),
                      itemBuilder: (_, i) {
                        final r = displayed[i];
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Text(r['author'] as String,
                                          style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontWeight: FontWeight.bold)),
                                      if (r['verified'] == true) ...[
                                        const SizedBox(width: 6),
                                        const Icon(
                                            CupertinoIcons.checkmark_seal_fill,
                                            color: AppTheme.brand,
                                            size: 15)
                                      ],
                                    ]),
                                    Text(r['date'] as String,
                                        style: const TextStyle(
                                            color: AppTheme.textSecondary,
                                            fontSize: 12)),
                                  ]),
                              const SizedBox(height: 8),
                              Row(
                                  children: List.generate(
                                      5,
                                      (j) => Icon(
                                          j < (r['rating'] as int)
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: j < (r['rating'] as int)
                                              ? AppTheme.cardYellow
                                              : AppTheme.textSecondary,
                                          size: 16))),
                              const SizedBox(height: 10),
                              Text(r['content'] as String,
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 13,
                                      height: 1.4)),
                            ]);
                      },
                    ),
            ),
          ]),
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AVAILABILITY QUICK-VIEW  (new feature)
  // ─────────────────────────────────────────────────────────────────────────
  void _showAvailabilitySheet(BuildContext context) {
    // Mock weekly schedule
    const schedule = {
      'Mon': ['7:00 AM', '8:00 AM', '9:00 AM', '6:00 PM', '7:00 PM'],
      'Tue': ['7:00 AM', '8:00 AM', '5:00 PM', '6:00 PM'],
      'Wed': <String>[],
      'Thu': ['7:00 AM', '8:00 AM', '6:00 PM', '7:00 PM'],
      'Fri': ['7:00 AM', '9:00 AM'],
      'Sat': ['10:00 AM', '11:00 AM', '12:00 PM'],
      'Sun': <String>[],
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        expand: false,
        builder: (_, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(24),
          children: [
            _sheetHandle(),
            const SizedBox(height: 20),
            Row(children: [
              const Icon(CupertinoIcons.calendar,
                  color: AppTheme.brand, size: 20),
              const SizedBox(width: 10),
              const Text('Weekly Availability',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 6),
            const Text('Book a session directly — slots fill fast.',
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            const Divider(color: AppTheme.divider),
            const SizedBox(height: 16),
            ...schedule.entries.map((e) {
              final slots = e.value;
              final hasSlots = slots.isNotEmpty;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        SizedBox(
                          width: 36,
                          child: Text(e.key,
                              style: TextStyle(
                                  color: hasSlots
                                      ? AppTheme.textPrimary
                                      : AppTheme.textSecondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                        ),
                        const SizedBox(width: 10),
                        if (!hasSlots)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                                color: AppTheme.divider,
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text('Unavailable',
                                style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11)),
                          )
                        else
                          Expanded(
                            child: Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: slots
                                  .map((s) => GestureDetector(
                                        onTap: () {
                                          HapticFeedback.selectionClick();
                                          Navigator.pop(ctx);
                                          AppUtils.showToast(context,
                                              'Booking request sent for ${e.key} $s');
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                              color: AppTheme.brand
                                                  .withValues(alpha: 0.08),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                  color: AppTheme.brand
                                                      .withValues(alpha: 0.4))),
                                          child: Text(s,
                                              style: const TextStyle(
                                                  color: AppTheme.brand,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ))
                                  .toList(),
                            ),
                          ),
                      ]),
                      if (hasSlots)
                        const Padding(
                          padding: EdgeInsets.only(top: 10),
                          child: Divider(color: AppTheme.divider, height: 1),
                        ),
                    ]),
              );
            }),
            const SizedBox(height: 8),
            SolidConfirmButton(
              label: 'Request Custom Time',
              icon: Icons.add,
              height: AppConstants.kDefaultButtonHeightLarge,
              onPressed: () {
                Navigator.pop(ctx);
                AppUtils.showToast(context, 'Custom request sent!');
              },
            ),
            const SizedBox(height: 12),
            OutlineActionButton(
                label: context.l10n.cancel,
                height: AppConstants.kDefaultButtonHeightLarge,
                textColor: AppTheme.textPrimary,
                borderColor: AppTheme.textSecondary,
                onPressed: () => Navigator.pop(ctx)),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _sheetHandle() => Center(
        child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(10))),
      );

  Widget _dropdownPill(String val, List<String> items, String prefix,
      ValueChanged<String?> onChange) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.divider)),
      child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
        value: val,
        dropdownColor: AppTheme.surface,
        icon: const Icon(Icons.keyboard_arrow_down,
            color: AppTheme.textSecondary, size: 20),
        isExpanded: true,
        style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold),
        items: items
            .map((v) => DropdownMenuItem(value: v, child: Text('$prefix: $v')))
            .toList(),
        onChanged: onChange,
      )),
    );
  }

  Widget _statCol(String label, String value) => Expanded(
        child: Column(children: [
          Text(value,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
        ]),
      );

  Widget _floatBtn(IconData icon, Color color, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: AppTheme.bg.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.divider)),
          child: Icon(icon, color: color, size: 20),
        ),
      );

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(children: [
        NestedScrollView(
          headerSliverBuilder: (context, _) => [
            // ── Hero banner ──────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 340,
              pinned: true,
              backgroundColor: AppTheme.bg,
              elevation: 0,
              // Collapsed app bar shows name when scrolled
              title: _headerCollapsed
                  ? Row(children: [
                      CircleAvatar(
                        radius: 15,
                        backgroundColor: AppTheme.surface,
                        backgroundImage: (widget.trainer['profileImage'] !=
                                    null &&
                                widget.trainer['profileImage']
                                    .toString()
                                    .trim()
                                    .isNotEmpty)
                            ? NetworkImage(widget.trainer['profileImage'])
                            : const NetworkImage(
                                'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?q=80&w=2070&auto=format&fit=crop'),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                            '${widget.trainer['firstName']} ${widget.trainer['lastName']}',
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ])
                  : null,
              leading: IconButton(
                icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: AppTheme.bg.withValues(alpha: 0.8),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.arrow_back,
                        color: AppTheme.textPrimary, size: 20)),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(fit: StackFit.expand, children: [
                  // Banner image / video placeholder
                  Image.network(
                      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?q=80&w=1470&auto=format&fit=crop',
                      fit: BoxFit.cover),
                  Container(color: Colors.black.withValues(alpha: 0.35)),
                  // Tap-to-play intro video hint
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      AppUtils.showToast(context, 'Playing intro video…');
                    },
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white54, width: 1.5)),
                            child: const Icon(Icons.play_arrow_rounded,
                                color: Colors.white, size: 38),
                          ),
                          const SizedBox(height: 10),
                          Text(context.l10n.autoPlayingIntro,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 13)),
                        ])),
                  ),
                  // Bottom gradient fade into bg
                  Positioned.fill(
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppTheme.bg.withValues(alpha: 0.7),
                      AppTheme.bg,
                    ],
                  )))),
                ]),
              ),
            ),

            // ── Profile header ──────────────────────────────────────────
            SliverToBoxAdapter(
                child: Stack(clipBehavior: Clip.none, children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 68, left: 24, right: 24, bottom: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name row
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                  Text('@${widget.trainer['username']}',
                                      style: const TextStyle(
                                          color: AppTheme.brand,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600),
                                      overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 2),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Flexible(
                                        child: Text(
                                            '${widget.trainer['firstName']} ${widget.trainer['lastName']}',
                                            style: const TextStyle(
                                                color: AppTheme.textPrimary,
                                                fontSize: 26,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.3)),
                                      ),
                                      const SizedBox(width: 10),
                                      // Online indicator badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            color: Colors.greenAccent
                                                .withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                                color: Colors.greenAccent
                                                    .withValues(alpha: 0.4))),
                                        child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                  width: 7,
                                                  height: 7,
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Colors
                                                              .greenAccent,
                                                          shape:
                                                              BoxShape.circle)),
                                              const SizedBox(width: 5),
                                              const Text('Online',
                                                  style: TextStyle(
                                                      color: Colors.greenAccent,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ]),
                                      ),
                                    ],
                                  ),
                                ])),
                          ]),
                      const SizedBox(height: 10),
                      // Star rating row — tappable → reviews modal
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showReviewsModal(context);
                        },
                        child: Row(children: [
                          ...List.generate(5, (i) {
                            final rating = double.tryParse(
                                    widget.trainer['rating'] ?? '4.9') ??
                                4.9;
                            final filled = i < rating.floor();
                            final half = !filled && (rating - i) >= 0.5;
                            return Icon(
                              filled
                                  ? Icons.star
                                  : (half
                                      ? Icons.star_half
                                      : Icons.star_border),
                              color: Colors.white,
                              size: 20,
                            );
                          }),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.trainer['rating'] ?? '4.9'} · (4 reviews)',
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: AppTheme.textSecondary),
                          ),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      // Meta row: location, gender/age
                      Wrap(
                        spacing: 14,
                        runSpacing: 6,
                        children: [
                          _metaChip(
                              CupertinoIcons.location_solid,
                              (widget.trainer['countryOfEmployment'] as String?)
                                      ?.replaceAll(
                                          RegExp(r'[\u{1F1E6}-\u{1F1FF}]{2}',
                                              unicode: true),
                                          '')
                                      .trim() ??
                                  'Egypt'),
                          _metaChip(Icons.male,
                              '${widget.trainer['gender'] ?? 'Male'}, ${widget.trainer['age'] ?? '32'} yrs'),
                        ],
                      ),
                      const SizedBox(height: 22),
                      // Stats row
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.divider)),
                        child: Row(children: [
                          _statCol('Posts', '0'),
                          _dividerLine(),
                          _statCol('Followers',
                              '${widget.trainer['followers'] ?? '0'}'),
                          _dividerLine(),
                          _statCol('Following',
                              '${widget.trainer['following'] ?? '0'}'),
                          _dividerLine(),
                          _statCol('Experience',
                              '${widget.trainer['yearsExperience'] ?? '0'} Yrs'),
                        ]),
                      ),
                      const SizedBox(height: 20),
                      // Bio
                      if (widget.trainer['bio'] != null &&
                          (widget.trainer['bio'] as String)
                              .trim()
                              .isNotEmpty) ...[
                        _ExpandableBio(bio: widget.trainer['bio'] as String),
                        const SizedBox(height: 20),
                      ],
                      // CTA Buttons — primary row
                      Row(children: [
                        Expanded(
                            child: SolidConfirmButton(
                                label: 'Send Message',
                                icon: Icons.chat_bubble_outline,
                                height: AppConstants.kDefaultButtonHeightLarge,
                                onPressed: () {
                                  HapticFeedback.lightImpact();
                                  AppUtils.launchLink(context,
                                      'https://example.com/message/${widget.trainer['username']}',
                                      fromChat: false);
                                })),
                        const SizedBox(width: 12),
                        Expanded(
                            child: OutlineActionButton(
                          label: _isFollowing
                              ? 'Following Trainer'
                              : 'Follow Trainer',
                          icon: Icon(
                              _isFollowing ? Icons.check : Icons.person_add,
                              color: AppTheme.brand,
                              size: 18),
                          height: AppConstants.kDefaultButtonHeightLarge,
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            setState(() => _isFollowing = !_isFollowing);
                            AppUtils.showToast(context,
                                _isFollowing ? 'Following!' : 'Unfollowed');
                          },
                        )),
                      ]),
                      const SizedBox(height: 12),
                      // Secondary row — schedule / products / stories
                      Row(children: [
                        Expanded(
                            child: OutlineActionButton(
                                label: 'View Schedule',
                                icon: const Icon(
                                    CupertinoIcons.calendar_badge_plus,
                                    color: AppTheme.brand,
                                    size: 16),
                                height: AppConstants.kDefaultButtonHeightLarge,
                                onPressed: () =>
                                    _showAvailabilitySheet(context))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: OutlineActionButton(
                                label: 'View Products',
                                icon: const Icon(Icons.shopping_bag_outlined,
                                    color: AppTheme.brand, size: 16),
                                height: AppConstants.kDefaultButtonHeightLarge,
                                onPressed: () => Navigator.push(
                                    context,
                                    AppRoutes.noTransitionRoute(
                                        ProductsAndOffersScreen(
                                            trainerName:
                                                '${widget.trainer['firstName']} ${widget.trainer['lastName']}'))))),
                        const SizedBox(width: 10),
                        Expanded(
                            child: OutlineActionButton(
                                label: 'Client Stories',
                                icon: const Icon(Icons.auto_graph,
                                    color: AppTheme.brand, size: 16),
                                height: AppConstants.kDefaultButtonHeightLarge,
                                onPressed: () =>
                                    _showTestimonialsModal(context))),
                      ]),
                      const Divider(color: AppTheme.divider, height: 40),
                      // Specialities
                      if (widget.trainer['specialties'] != null &&
                          (widget.trainer['specialties'] as List)
                              .isNotEmpty) ...[
                        _sectionTitle(context.l10n.specialities),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ((widget.trainer['specialties'] as List)
                                  .cast<String>())
                              .map<Widget>((s) => _specialtyChip(s))
                              .toList(),
                        ),
                        const Divider(color: AppTheme.divider, height: 40),
                      ],
                      // Credentials
                      if (widget.trainer['credentials'] != null &&
                          (widget.trainer['credentials'] as List)
                              .isNotEmpty) ...[
                        _sectionTitle(context.l10n.credentials),
                        const SizedBox(height: 14),
                        ...((widget.trainer['credentials'] as List)
                                .cast<String>())
                            .map<Widget>((c) => _credentialTile(c)),
                        const Divider(color: AppTheme.divider, height: 40),
                      ],
                      // Places of employment
                      _sectionTitle(context.l10n.placesOfEmployment),
                      const SizedBox(height: 4),
                      Text(
                          'Where ${widget.trainer['firstName'] ?? 'this trainer'} works in real life',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                      const SizedBox(height: 14),
                      _buildPlacesOfEmployment(),
                      const SizedBox(height: 20),
                    ]),
              ),

              // ── Avatar overlapping banner ─────────────────────────────
              Positioned(
                top: -58,
                left: 24,
                child: Stack(clipBehavior: Clip.none, children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.bg, width: 4),
                    ),
                    child: ClipOval(
                      child: (widget.trainer['profileImage'] != null &&
                              widget.trainer['profileImage']
                                  .toString()
                                  .trim()
                                  .isNotEmpty)
                          ? Image.network(
                              widget.trainer['profileImage'],
                              width: 108,
                              height: 108,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person,
                                      size: 50, color: AppTheme.brand),
                            )
                          : Image.network(
                              'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?q=80&w=2070&auto=format&fit=crop',
                              width: 108,
                              height: 108,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.bg,
                        border: Border.all(color: AppTheme.bg, width: 2),
                      ),
                      child: const Icon(CupertinoIcons.checkmark_seal_fill,
                          color: AppTheme.brand, size: 24),
                    ),
                  ),
                ]),
              ),
            ])),

            // ── Sticky tab bar ────────────────────────────────────────────
            SliverPersistentHeader(
              pinned: true,
              delegate: _SliverTabBarDelegate(TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.brand,
                indicatorWeight: 2.5,
                labelColor: AppTheme.brand,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                dividerColor: AppTheme.divider,
                tabs: const [
                  Tab(text: 'Plans'),
                  Tab(text: 'Posts'),
                  Tab(text: 'Premium')
                ],
              )),
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [_buildPlansTab(), _buildPostsTab(), _buildPremiumTab()],
          ),
        ),

        // ── Floating share + report buttons ──────────────────────────────
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          right: 16,
          child: Row(children: [
            _floatBtn(CupertinoIcons.share, AppTheme.textPrimary, () {
              HapticFeedback.lightImpact();
              _showShareSheet(context);
            }),
            const SizedBox(width: 10),
            _floatBtn(Icons.flag_rounded, Colors.redAccent, () {
              HapticFeedback.lightImpact();
              _showReportModal(context);
            }),
          ]),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SMALL HELPERS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _metaChip(IconData icon, String label) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 13),
          const SizedBox(width: 4),
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ],
      );

  Widget _dividerLine() =>
      Container(width: 1, height: 36, color: AppTheme.divider);

  Widget _sectionTitle(String title) => Text(title,
      style: const TextStyle(
          color: AppTheme.brand, fontSize: 17, fontWeight: FontWeight.bold));

  Widget _specialtyChip(String label) => PremiumSelectionButton(
        label: label,
        leadingIcon: Icons.bolt,
        color: AppTheme.brand,
        selected: true,
      );

  Widget _credentialTile(String c) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TnTPremiumCard(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          elevated: false,
          accentColor: AppTheme.brand,
          child: Row(children: [
            const Icon(CupertinoIcons.checkmark_seal_fill,
                color: AppTheme.brand, size: 16),
            const SizedBox(width: 10),
            Expanded(
                child: Text(c,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500))),
          ]),
        ),
      );

  // ─────────────────────────────────────────────────────────────────────────
  // PLACES OF EMPLOYMENT
  // ─────────────────────────────────────────────────────────────────────────
  static const List<Map<String, dynamic>> _mockPlaces = [
    {
      'name': 'Gold\'s Gym Elite',
      'address': '12 Sheikh Zayed Rd, Sheikh Zayed City',
      'city': 'Giza',
      'country': 'Egypt',
      'type': 'Gym',
      'lat': 30.0174,
      'lng': 31.0077,
    },
    {
      'name': 'Platinum Club',
      'address': '45 Corniche El Nile, Downtown',
      'city': 'Cairo',
      'country': 'Egypt',
      'type': 'Fitness Club',
      'lat': 30.0444,
      'lng': 31.2357,
    },
    {
      'name': 'Outdoor Training — Gezira Club',
      'address': 'Gezira Island',
      'city': 'Cairo',
      'country': 'Egypt',
      'type': 'Outdoor',
      'lat': 30.0561,
      'lng': 31.2243,
    },
  ];

  Widget _buildPlacesOfEmployment() {
    final places = (widget.trainer['places'] as List<Map<String, dynamic>>?) ??
        _mockPlaces;

    if (places.isEmpty) {
      return TnTPremiumCard(
        padding: const EdgeInsets.all(20),
        accentColor: AppTheme.textSecondary,
        child: Row(children: [
          const Icon(Icons.location_off,
              color: AppTheme.textSecondary, size: 20),
          const SizedBox(width: 12),
          Text(context.l10n.noLocationsListed,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        ]),
      );
    }

    return Column(
      children: places.asMap().entries.map((e) {
        final p = e.value;
        final IconData icon;
        switch ((p['type'] as String? ?? '').toLowerCase()) {
          case 'gym':
            icon = Icons.fitness_center;
            break;
          case 'fitness club':
            icon = Icons.sports_gymnastics;
            break;
          case 'outdoor':
            icon = Icons.park;
            break;
          case 'studio':
            icon = Icons.self_improvement;
            break;
          case 'pool':
            icon = Icons.pool;
            break;
          default:
            icon = Icons.location_on;
        }

        return TnTPremiumCard(
          onTap: () {
            final lat = p['lat'];
            final lng = p['lng'];
            if (lat != null && lng != null) {
              AppUtils.launchLink(
                  context, 'https://maps.google.com/?q=$lat,$lng');
            }
          },
          margin: const EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.zero,
          radius: 14,
          accentColor: AppTheme.brand,
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: AppTheme.brand.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppTheme.brand.withValues(alpha: 0.2))),
              child: Icon(icon, color: AppTheme.brand, size: 22),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(p['name'] as String,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.open_in_new,
                    color: AppTheme.textSecondary, size: 14),
              ],
            ),
            subtitle:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 3),
              Text(p['address'] as String,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
              const SizedBox(height: 2),
              Text('${p['city']}, ${p['country']}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
            ]),
            trailing: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: AppTheme.brand.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                          color: AppTheme.brand.withValues(alpha: 0.3))),
                  child: Text(p['type'] as String,
                      style: const TextStyle(
                          color: AppTheme.brand,
                          fontSize: 11,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PLANS TAB
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPlansTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        Text(context.l10n.chooseYourJourney,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
            'Prices convert to your local currency securely at checkout.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        // ── Trial CTA banner ─────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.brand.withValues(alpha: 0.12),
                    AppTheme.brand.withValues(alpha: 0.04),
                  ]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.brand.withValues(alpha: 0.3))),
          child: Row(children: [
            const Icon(CupertinoIcons.gift_fill,
                color: AppTheme.brand, size: 28),
            const SizedBox(width: 14),
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('7-Day Free Trial',
                      style: TextStyle(
                          color: AppTheme.brand,
                          fontWeight: FontWeight.bold,
                          fontSize: 14)),
                  SizedBox(height: 3),
                  Text('Try any plan free for 7 days — no card required.',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ])),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: AppTheme.textSecondary, size: 14),
          ]),
        ),
        const SizedBox(height: 20),
        _pricingCard(
            title: context.l10n.membershipStarterTier,
            price: '\$29',
            interval: '/ month',
            popular: false,
            badge: null,
            features: [
              'Access to Premium Posts',
              'General Workout Templates',
              'Community Forum Access',
            ]),
        const SizedBox(height: 15),
        _pricingCard(
            title: context.l10n.membershipProTrainee,
            price: '\$89',
            interval: '/ month',
            popular: true,
            badge: context.l10n.mostPopular,
            features: [
              'Customised Diet Plan',
              'Weekly Check-ins',
              '1-on-1 Chat Access',
              'All Starter Features',
            ]),
        const SizedBox(height: 15),
        _pricingCard(
            title: context.l10n.membershipEliteCoaching,
            price: '\$199',
            interval: '/ month',
            popular: false,
            badge: '⚡ Best Results',
            features: [
              'Daily Accountability',
              'Video Form Analysis',
              'Live Q&A Sessions',
              'All Pro Features',
            ]),
        const SizedBox(height: 24),
        // Money-back guarantee note
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(CupertinoIcons.shield_lefthalf_fill,
              color: AppTheme.textSecondary, size: 15),
          const SizedBox(width: 6),
          Text('30-day money-back guarantee',
              style: TextStyle(
                  color: AppTheme.textSecondary.withValues(alpha: 0.8),
                  fontSize: 12)),
        ]),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _pricingCard({
    required String title,
    required String price,
    required String interval,
    required bool popular,
    required String? badge,
    required List<String> features,
  }) {
    return TnTPremiumCard(
      padding: const EdgeInsets.all(22),
      radius: 20,
      accentColor: popular ? AppTheme.brand : AppTheme.textSecondary,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (badge != null) ...[
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
              decoration: BoxDecoration(
                  color: popular
                      ? AppTheme.brand.withValues(alpha: 0.12)
                      : AppTheme.cardYellow.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20)),
              child: Text(badge,
                  style: TextStyle(
                      color: popular ? AppTheme.brand : AppTheme.cardYellow,
                      fontSize: 11,
                      fontWeight: FontWeight.bold))),
          const SizedBox(height: 14),
        ],
        Text(title,
            style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(price,
              style: const TextStyle(
                  color: AppTheme.brand,
                  fontSize: 38,
                  fontWeight: FontWeight.bold)),
          const SizedBox(width: 6),
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(interval,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 14))),
        ]),
        const SizedBox(height: 18),
        const Divider(color: AppTheme.divider, height: 1),
        const SizedBox(height: 18),
        ...features.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child:
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(CupertinoIcons.checkmark_circle_fill,
                    color: AppTheme.brand, size: 18),
                const SizedBox(width: 10),
                Expanded(
                    child: Text(f,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13))),
              ]),
            )),
        const SizedBox(height: 18),
        SolidConfirmButton(
            label: context.l10n.subscribeNow,
            height: 48,
            onPressed: () {
              HapticFeedback.selectionClick();
              AppUtils.showToast(context, context.l10n.redirectingToCheckout);
            }),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // POSTS TAB
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPostsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        // 1 — Photo post
        _postShell(
          time: '2 hours ago',
          type: 'Photo',
          likes: '1.2K',
          comments: 48,
          saved: 210,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                    'Chest day dump! Feeling stronger every week. Consistency over intensity always. 💪',
                    style:
                        TextStyle(color: AppTheme.textPrimary, fontSize: 14))),
            ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                    'https://images.unsplash.com/photo-1581009146145-b5ef050c2e1e?q=80&w=1000',
                    fit: BoxFit.cover,
                    height: 260,
                    width: double.infinity)),
          ]),
        ),
        const Divider(color: AppTheme.divider, height: 40),

        // 2 — Carousel
        _postShell(
          time: '6 hours ago',
          type: 'Carousel',
          likes: '3.7K',
          comments: 112,
          saved: 540,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                    'Back & bicep progression 📸 — 8 weeks apart. The pump is real.',
                    style:
                        TextStyle(color: AppTheme.textPrimary, fontSize: 14))),
            SizedBox(
                height: 220,
                child: Stack(children: [
                  PageView(children: [
                    ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                            'https://images.unsplash.com/photo-1533681904393-9ab6eee7e408?q=80&w=1000',
                            fit: BoxFit.cover,
                            width: double.infinity)),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                            'https://images.unsplash.com/photo-1598971639058-a05e31c6adf2?q=80&w=1000',
                            fit: BoxFit.cover,
                            width: double.infinity)),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                            'https://images.unsplash.com/photo-1583454110551-21f2fa2afe61?q=80&w=1000',
                            fit: BoxFit.cover,
                            width: double.infinity)),
                  ]),
                  Positioned(
                      top: 12,
                      right: 14,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(12)),
                          child: const Text('1 / 3',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)))),
                ])),
          ]),
        ),
        const Divider(color: AppTheme.divider, height: 40),

        // 3 — Video
        _postShell(
          time: 'Yesterday',
          type: 'Video',
          likes: '5.1K',
          comments: 203,
          saved: 880,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                    '3 deadlift variations to maximise hamstring engagement. Watch till the end! 🔥',
                    style:
                        TextStyle(color: AppTheme.textPrimary, fontSize: 14))),
            Stack(alignment: Alignment.center, children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                      'https://images.unsplash.com/photo-1517836357463-d25dfeac3438?q=80&w=1000',
                      fit: BoxFit.cover,
                      height: 220,
                      width: double.infinity)),
              Container(
                  height: 220,
                  decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(12))),
              const Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
              Positioned(
                  bottom: 10, left: 14, child: _videoBadge('2.4K Views')),
              Positioned(bottom: 10, right: 14, child: _videoBadge('08:42')),
            ]),
          ]),
        ),
        const Divider(color: AppTheme.divider, height: 40),

        // 4 — Poll
        _postShell(
          time: '3 days ago',
          type: 'Poll',
          likes: '892',
          comments: 74,
          saved: 0,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('What should my next YouTube video be about? 🗳️',
                    style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600))),
            _pollOption('Core Strength Routine', 0.65, true),
            _pollOption('Diet Prep for Summer', 0.25, false),
            _pollOption('Injury Recovery Guide', 0.10, false),
            const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text('1,204 votes · Poll closed',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12))),
          ]),
        ),
        const Divider(color: AppTheme.divider, height: 40),

        // 5 — Article
        _postShell(
          time: '1 week ago',
          type: 'Article',
          likes: '2.3K',
          comments: 91,
          saved: 430,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text('Just dropped a deep-dive. Link in bio 📖',
                    style:
                        TextStyle(color: AppTheme.textPrimary, fontSize: 14))),
            Container(
              decoration: BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider)),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        height: 110,
                        decoration: const BoxDecoration(
                            color: AppTheme.cardIndigo,
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12))),
                        child: const Center(
                            child: Icon(Icons.article,
                                color: Colors.white54, size: 48))),
                    Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('ARTICLE',
                                  style: TextStyle(
                                      color: AppTheme.brand,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.0)),
                              const SizedBox(height: 5),
                              const Text(
                                  'Protein Timing: Does the Anabolic Window Actually Exist?',
                                  style: TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              const Text(
                                  'We dive into the latest literature to find out if you really need to chug a shake immediately after your last set.',
                                  style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 12,
                                      height: 1.4),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 12),
                              Row(children: [
                                const Icon(CupertinoIcons.time_solid,
                                    color: AppTheme.textSecondary, size: 13),
                                const SizedBox(width: 4),
                                const Text('8 min read',
                                    style: TextStyle(
                                        color: AppTheme.textSecondary,
                                        fontSize: 11)),
                                const Spacer(),
                                SizedBox(
                                    width: 120,
                                    height: 34,
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                          side: const BorderSide(
                                              color: AppTheme.divider),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8))),
                                      child: const Text('Read Article',
                                          style: TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold)),
                                    )),
                              ]),
                            ])),
                  ]),
            ),
          ]),
        ),
        const Divider(color: AppTheme.divider, height: 40),

        // 6 — Reel
        _postShell(
          time: '2 weeks ago',
          type: 'Reel',
          likes: '8.9K',
          comments: 344,
          saved: 1200,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Text(
                    '60-second mobility drill to fix rounded shoulders 🙌 Save this!',
                    style:
                        TextStyle(color: AppTheme.textPrimary, fontSize: 14))),
            Stack(alignment: Alignment.center, children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                      'https://images.unsplash.com/photo-1576678927484-cc907957088c?q=80&w=800',
                      fit: BoxFit.cover,
                      height: 340,
                      width: double.infinity)),
              Container(
                  height: 340,
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(12))),
              const Icon(Icons.play_circle_outline_rounded,
                  color: Colors.white, size: 72),
              Positioned(top: 12, left: 14, child: _videoBadge('REEL')),
              Positioned(bottom: 10, right: 14, child: _videoBadge('0:59')),
            ]),
          ]),
        ),
      ],
    );
  }

  Widget _videoBadge(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.black54, borderRadius: BorderRadius.circular(8)),
        child: Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4)),
      );

  /// Shared post wrapper with engagement bar
  Widget _postShell({
    required String time,
    required String type,
    required String likes,
    required int comments,
    required int saved,
    required Widget child,
  }) {
    bool liked = false;
    bool bookmarked = false;
    return StatefulBuilder(builder: (_, setSt) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          CircleAvatar(
              radius: 19,
              backgroundImage: NetworkImage(widget.trainer['profileImage'] ??
                  'https://images.unsplash.com/photo-1568602471122-7832951cc4c5?q=80&w=2070')),
          const SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                    '${widget.trainer['firstName']} ${widget.trainer['lastName']}',
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Row(children: [
                  Text(time,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 11)),
                  const SizedBox(width: 8),
                  _postTypeBadge(type),
                ]),
              ])),
          const Icon(Icons.more_horiz_rounded,
              color: AppTheme.textSecondary, size: 22),
        ]),
        child,
        const SizedBox(height: 12),
        // Engagement bar
        Row(children: [
          _engagementBtn(
              icon: liked ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
              label: likes,
              active: liked,
              activeColor: Colors.redAccent,
              onTap: () {
                HapticFeedback.lightImpact();
                setSt(() => liked = !liked);
              }),
          const SizedBox(width: 18),
          _engagementBtn(
              icon: CupertinoIcons.chat_bubble,
              label: '$comments',
              active: false,
              activeColor: AppTheme.brand,
              onTap: () {}),
          if (saved > 0) ...[
            const SizedBox(width: 18),
            Row(children: [
              const Icon(Icons.trending_up_rounded,
                  color: AppTheme.textSecondary, size: 16),
              const SizedBox(width: 4),
              Text(_formatCount(saved),
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
            ]),
          ],
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setSt(() => bookmarked = !bookmarked);
            },
            child: Icon(
                bookmarked
                    ? CupertinoIcons.bookmark_fill
                    : CupertinoIcons.bookmark,
                color: bookmarked ? AppTheme.brand : AppTheme.textSecondary,
                size: 19),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showShareSheet(context);
            },
            child: const Icon(CupertinoIcons.share,
                color: AppTheme.textSecondary, size: 19),
          ),
        ]),
      ]);
    });
  }

  Widget _postTypeBadge(String type) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: AppTheme.divider)),
        child: Text(type,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 9,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5)),
      );

  Widget _engagementBtn({
    required IconData icon,
    required String label,
    required bool active,
    required Color activeColor,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Row(children: [
          Icon(icon,
              color: active ? activeColor : AppTheme.textSecondary, size: 19),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  color: active ? activeColor : AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal)),
        ]),
      );

  String _formatCount(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  Widget _pollOption(String label, double pct, bool selected) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            if (selected)
              const Padding(
                  padding: EdgeInsets.only(right: 6),
                  child: Icon(Icons.check_circle,
                      color: AppTheme.brand, size: 15)),
            Text(label,
                style: TextStyle(
                    color: selected ? AppTheme.brand : AppTheme.textPrimary,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13)),
          ]),
          Text('${(pct * 100).toInt()}%',
              style: const TextStyle(
                  color: AppTheme.brand,
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ]),
        const SizedBox(height: 7),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
              value: pct,
              backgroundColor: AppTheme.divider,
              color: AppTheme.brand,
              minHeight: 7),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // PREMIUM TAB
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPremiumTab() {
    return ListView(
      padding: const EdgeInsets.all(24),
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        // Upgrade nudge
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.amber.withValues(alpha: 0.12),
                    Colors.orange.withValues(alpha: 0.05),
                  ]),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.35))),
          child: Row(children: [
            const Icon(CupertinoIcons.lock_shield_fill,
                color: Colors.amber, size: 26),
            const SizedBox(width: 14),
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Members Only Content',
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 3),
                  Text('Subscribe to any plan to unlock all exclusive posts.',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ])),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _tabController.animateTo(0), // go to Plans tab
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.amber.withValues(alpha: 0.4))),
                child: const Text('View Plans',
                    style: TextStyle(
                        color: Colors.amber,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 24),
        Row(children: [
          const Text('Exclusive Posts & Extras',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold)),
          const Spacer(),
          Text('${4} items',
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        ]),
        const SizedBox(height: 14),
        _premiumCard('Advanced Hypertrophy Program (PDF)', 'Extra / Download',
            'Yesterday', CupertinoIcons.doc_text_fill),
        _premiumCard('Full Diet Grocery List & Macros', 'Article', '1 week ago',
            CupertinoIcons.doc_text_fill),
        _premiumCard('Form Check: Deadlifts Masterclass', 'Exclusive Video',
            '2 weeks ago', CupertinoIcons.play_circle_fill),
        _premiumCard('Supplement Stack Guide', 'PDF Guide', '3 weeks ago',
            CupertinoIcons.doc_text_fill),
      ],
    );
  }

  Widget _premiumCard(String title, String type, String date, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.divider)),
      child: Stack(children: [
        Padding(
            padding: const EdgeInsets.all(16),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                      color: AppTheme.bg,
                      borderRadius: BorderRadius.circular(10)),
                  child: Icon(icon, color: AppTheme.textSecondary, size: 28)),
              const SizedBox(width: 14),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(type,
                        style: const TextStyle(
                            color: AppTheme.brand,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.4)),
                    const SizedBox(height: 4),
                    Text(title,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(date,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                  ])),
            ])),
        Positioned.fill(
            child: ClipRRect(
                child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
              color: AppTheme.bg.withValues(alpha: 0.35),
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: AppTheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.divider)),
                      child: const Icon(CupertinoIcons.lock_fill,
                          color: AppTheme.textPrimary, size: 22),
                    ),
                    const SizedBox(height: 6),
                    const Text('Members Only',
                        style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ]))),
        ))),
      ]),
    );
  }
}

// =============================================================================
// EXPANDABLE BIO WIDGET
// =============================================================================
class _ExpandableBio extends StatefulWidget {
  final String bio;
  const _ExpandableBio({required this.bio});
  @override
  State<_ExpandableBio> createState() => _ExpandableBioState();
}

class _ExpandableBioState extends State<_ExpandableBio> {
  bool _expanded = false;
  static const int _maxLines = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.surface,
              AppTheme.surface.withValues(alpha: 0.5)
            ]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(widget.bio,
            maxLines: _expanded ? null : _maxLines,
            overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 14, height: 1.5)),
        // Only show toggle if text would overflow
        if (widget.bio.length > 150) ...[
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _expanded = !_expanded);
            },
            child: Text(_expanded ? 'Show less' : 'Read more',
                style: const TextStyle(
                    color: AppTheme.brand,
                    fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ]),
    );
  }
}

// =============================================================================
// PRODUCTS AND OFFERS SCREEN  (unchanged, kept for completeness)
// =============================================================================
class ProductsAndOffersScreen extends StatelessWidget {
  final String trainerName;
  const ProductsAndOffersScreen({super.key, required this.trainerName});

  @override
  Widget build(BuildContext context) {
    final fashion = [
      {
        'title': 'Gymshark Training Gear',
        'desc': 'Exclusive 10% off all athletic apparel via my referral link.',
        'icon': Icons.checkroom
      },
      {
        'title': 'Nike Pro Collection',
        'desc': 'Save 15% on performance wear using code TRAINER15.',
        'icon': Icons.shopping_bag
      },
      {
        'title': 'Under Armour Essentials',
        'desc': 'Free shipping on orders over \$50 through my link.',
        'icon': Icons.local_shipping
      },
      {
        'title': 'Adidas Performance Line',
        'desc': '20% off using exclusive code TRAIN20.',
        'icon': Icons.checkroom
      },
    ];
    final supplements = [
      {
        'title': 'Optimum Nutrition Whey',
        'desc': 'Save 15% on your entire cart. Use code COACH15 at checkout.',
        'icon': Icons.local_drink
      },
      {
        'title': 'Pre-Workout Stack',
        'desc': 'Get 20% off premium pre-workout supplements.',
        'icon': Icons.science
      },
      {
        'title': 'Recovery Bundle',
        'desc': 'BCAAs, Glutamine & Creatine — 25% off bundle price.',
        'icon': Icons.healing
      },
      {
        'title': 'Premium Protein Bars',
        'desc': 'Buy 2 boxes get 1 free with code BARS3.',
        'icon': Icons.local_drink
      },
    ];
    final discounts = [
      {
        'title': 'Gold\'s Gym Elite',
        'desc': 'Waived initiation fee + 10% off monthly memberships.',
        'icon': Icons.card_membership
      },
      {
        'title': 'Hyperice Recovery',
        'desc': 'Get \$50 off any massage gun or recovery boots.',
        'icon': Icons.spa
      },
      {
        'title': 'MyFitnessPal Premium',
        'desc': '3 months free when you sign up through my link.',
        'icon': Icons.restaurant_menu
      },
      {
        'title': 'FitBit Tracker',
        'desc': '15% off all models using code FIT15.',
        'icon': Icons.watch
      },
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.bg,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: Text('$trainerName\'s Products',
            style: const TextStyle(color: AppTheme.brand, fontSize: 18)),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          _section(context, 'Fashion', fashion),
          const Divider(color: AppTheme.divider, thickness: 1, height: 1),
          _section(context, 'Supplements', supplements),
          const Divider(color: AppTheme.divider, thickness: 1, height: 1),
          _section(context, 'Discounts', discounts),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _section(
      BuildContext ctx, String title, List<Map<String, dynamic>> products) {
    final visible = products.take(3).toList();
    final hasMore = products.length > 3;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(title,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            if (hasMore)
              TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  AppUtils.showToast(ctx, 'Loading all items in $title...');
                },
                child: const Text('View more',
                    style: TextStyle(
                        color: AppTheme.brand,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ),
          ])),
      GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.65),
        itemCount: visible.length,
        itemBuilder: (_, i) => _productCard(visible[i]),
      ),
      const SizedBox(height: 20),
    ]);
  }

  Widget _productCard(Map<String, dynamic> p) {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Expanded(
            flex: 4,
            child: Container(
              decoration: const BoxDecoration(
                  color: AppTheme.bg,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(12))),
              child: Center(
                  child: Icon(p['icon'] as IconData,
                      color: AppTheme.brand, size: 36)),
            )),
        Expanded(
            flex: 5,
            child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p['title'] as String,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text(p['desc'] as String,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 10),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis),
                    ]))),
      ]),
    );
  }
}

// =============================================================================
// SLIVER TAB BAR DELEGATE
// =============================================================================
class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  const _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: AppTheme.bg, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate old) => false;
}
