import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_core_utils.dart';
import '../core/c_custom_controls.dart';
import '../core/c_state.dart';
import '../core/animations/app_motion.dart';
import '../core/c_visual_effects.dart';

// =============================================================================
// FORMATTERS
// =============================================================================

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String raw = newValue.text.replaceAll(' ', '');
    if (raw.length > 19) raw = raw.substring(0, 19);

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(raw[i]);
    }

    String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue;

    String raw = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.length > 4) raw = raw.substring(0, 4);

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < raw.length; i++) {
      // Auto-prepend '0' if first digit is > 1 (e.g. '3' â†’ '03/')
      if (i == 0 && int.parse(raw[i]) > 1) {
        buffer.write('0');
        buffer.write(raw[i]);
        buffer.write('/');
        continue;
      }
      // Validate month does not exceed 12
      if (i == 1) {
        int month = int.parse('${raw[0]}${raw[1]}');
        if (month > 12) return oldValue;
      }
      // Insert separator before year digits
      if (i == 2) {
        buffer.write('/');
      }
      buffer.write(raw[i]);
    }

    String formatted = buffer.toString();
    return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length));
  }
}

// =============================================================================
// CARD TYPE DETECTION
// =============================================================================

String _detectCardType(String raw) {
  if (raw.startsWith('4')) return 'VISA';
  if (raw.startsWith('34') || raw.startsWith('37')) return 'AMEX';
  if (raw.startsWith('35')) return 'JCB';
  if (raw.startsWith('6011') || raw.startsWith('64') || raw.startsWith('65')) {
    return 'DISCOVER';
  }
  if (raw.startsWith('5') &&
      raw.length >= 2 &&
      int.tryParse(raw[1]) != null &&
      int.parse(raw[1]) >= 1 &&
      int.parse(raw[1]) <= 5) {
    return 'MASTERCARD';
  }
  if (raw.startsWith('2') &&
      raw.length >= 4 &&
      int.tryParse(raw.substring(0, 4)) != null &&
      int.parse(raw.substring(0, 4)) >= 2221 &&
      int.parse(raw.substring(0, 4)) <= 2720) {
    return 'MASTERCARD';
  }
  return 'VISA'; // Default fallback
}

// =============================================================================
// PAYMENTS SCREEN
// =============================================================================

class PaymentsScreen extends StatefulWidget {
  final String role;
  const PaymentsScreen({super.key, required this.role});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _payoutMethod;
  late String _paypalEmail;
  late Map<String, String> _bankAccount;

  late TextEditingController _paypalEmailCtrl;

  final List<Map<String, dynamic>> _mockCards = [
    {
      'type': 'VISA',
      'number': '4168145967895089',
      'expiry': '06/28',
      'holder': 'Omar bin al-Majd',
      'isDefault': true,
    },
    {
      'type': 'MASTERCARD',
      'number': '5412758493023456',
      'expiry': '11/27',
      'holder': 'Omar bin al-Majd',
      'isDefault': false,
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _payoutMethod = appState.payoutMethod;
    _paypalEmail = appState.paypalEmail;
    _bankAccount = Map<String, String>.from(appState.bankAccount);

    _paypalEmailCtrl = TextEditingController(text: _paypalEmail);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _paypalEmailCtrl.dispose();
    super.dispose();
  }

  void _saveFinancials() {
    _paypalEmail = _paypalEmailCtrl.text.trim();
    appState.saveFinancials(_payoutMethod, _paypalEmail, _bankAccount);
    AppUtils.showToast(context, context.l10n.financialsSavedSuccess);
  }

  // ---------------------------------------------------------------------------
  // PAYOUT METHOD SWITCHER  (Trainer only)
  // ---------------------------------------------------------------------------
  Widget _buildPayoutMethodSwitcher() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.l10n.payoutBankAccount,
            style: const TextStyle(
                color: AppTheme.brand,
                fontSize: AppConstants.kDefaultTitleFontSize,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(context.l10n.managePayoutsTrainerDesc,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppConstants.kDefaultSubtitleFontSize)),
        const SizedBox(height: 20),
        // Segmented switcher: Bank | PayPal
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius),
            border: Border.all(color: AppTheme.divider),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              _buildPayoutSegment('Bank', Icons.account_balance_outlined),
              _buildPayoutSegment('PayPal', Icons.paypal_outlined),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AppAnimatedSwitcher(
          duration: AppDurations.standard,
          child: _payoutMethod == 'Bank'
              ? const EgyptianBankForm(key: ValueKey('bank-form'))
              : KeyedSubtree(
                  key: const ValueKey('paypal-form'),
                  child: _buildPaypalForm(),
                ),
        ),
      ],
    );
  }

  Widget _buildPayoutSegment(String method, IconData icon) {
    bool selected = _payoutMethod == method;
    return Expanded(
      child: TnTPressable(
        onTap: () {
          if (_payoutMethod == method) return;
          setState(() {
            _payoutMethod = method;
          });
        },
        child: AnimatedContainer(
          duration: AppMotion.duration(context, AppDurations.fast),
          curve: AppCurves.entrance,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? AppTheme.brand : Colors.transparent,
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius - 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: selected ? AppTheme.bg : AppTheme.textSecondary),
              const SizedBox(width: 7),
              Text(method,
                  style: TextStyle(
                      color: selected ? AppTheme.bg : AppTheme.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PAYPAL FORM
  // ---------------------------------------------------------------------------
  Widget _buildPaypalForm() {
    return Column(
      key: const ValueKey('paypal_form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF003087).withValues(alpha: 0.08),
            borderRadius:
                BorderRadius.circular(AppConstants.kDefaultBorderRadius),
            border: Border.all(
                color: const Color(0xFF003087).withValues(alpha: 0.25)),
          ),
          child: Row(
            children: [
              const Icon(Icons.paypal_outlined,
                  color: Color(0xFF009CDE), size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Payouts will be sent to your PayPal account within 1-3 business days.',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _paypalEmailCtrl,
          style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppConstants.kDefaultSubtitleFontSize),
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: 'PayPal Email Address',
            prefixIcon: const Icon(Icons.email_outlined,
                color: AppTheme.textSecondary, size: 18),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
            labelStyle: const TextStyle(color: AppTheme.textSecondary),
            floatingLabelStyle: const TextStyle(color: AppTheme.brand),
            enabledBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide: const BorderSide(color: AppTheme.textSecondary)),
            focusedBorder: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.kDefaultBorderRadius),
                borderSide: const BorderSide(color: AppTheme.brand, width: 2)),
          ),
          onChanged: (v) => _paypalEmail = v,
        ),
        const SizedBox(height: 30),
        SolidConfirmButton(
          label: context.l10n.save,
          icon: Icons.check,
          height: AppConstants.kDefaultButtonHeightLarge,
          onPressed: () {
            HapticFeedback.selectionClick();
            _saveFinancials();
          },
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // CARD DIALOG & MANAGEMENT
  // ---------------------------------------------------------------------------
  void _showAddCardDialog({Map<String, dynamic>? existingCard}) {
    HapticFeedback.lightImpact();
    AppMotion.showPremiumDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddCardDialog(initialCard: existingCard),
    ).then((newCard) {
      if (!mounted) return;
      if (newCard != null) {
        setState(() {
          if (existingCard != null) {
            int idx = _mockCards.indexOf(existingCard);
            if (idx != -1) {
              newCard['isDefault'] = existingCard['isDefault'] ?? false;
              _mockCards[idx] = newCard;
            }
          } else {
            newCard['isDefault'] = _mockCards.isEmpty;
            _mockCards.add(newCard);
          }
        });
        AppUtils.showToast(
            context,
            existingCard != null
                ? 'Card updated successfully'
                : 'Card added successfully');
      }
    });
  }

  void _setDefaultCard(Map<String, dynamic> card) {
    HapticFeedback.selectionClick();
    setState(() {
      for (var c in _mockCards) {
        c['isDefault'] = false;
      }
      card['isDefault'] = true;
    });
    AppUtils.showToast(context, 'Default card updated');
  }

  void _confirmRemoveCard(Map<String, dynamic> card) {
    HapticFeedback.lightImpact();
    AppMotion.showPremiumDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: AppTheme.surface,
              titlePadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.kDefaultBorderRadius)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(context.l10n.removeCardPrompt,
                        style: const TextStyle(
                            color: AppTheme.brand,
                            fontWeight: FontWeight.bold,
                            fontSize: AppConstants.kDefaultFormTitleFontSize)),
                  ),
                  const Divider(color: AppTheme.divider, height: 1),
                ],
              ),
              content: Text(
                  'Are you sure you want to remove your ${card['type']} card ending in ${card['number'].toString().substring(card['number'].toString().length - 4)}?',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppConstants.kDefaultSubtitleFontSize)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(context.l10n.cancel,
                      style: const TextStyle(color: AppTheme.textSecondary)),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _mockCards.remove(card));
                    Navigator.pop(context);
                    AppUtils.showToast(context, context.l10n.cardRemovedMsg);
                  },
                  child: Text(context.l10n.remove,
                      style: const TextStyle(
                          color: AppTheme.error, fontWeight: FontWeight.bold)),
                ),
              ],
            ));
  }

  // ---------------------------------------------------------------------------
  // CARD VISUAL COMPONENTS
  // ---------------------------------------------------------------------------
  Widget _getCardLogo(String type) {
    switch (type) {
      case 'VISA':
        return const Text('VISA',
            style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                letterSpacing: 1.0,
                fontFamily: 'Arial'));
      case 'MASTERCARD':
        return Row(mainAxisSize: MainAxisSize.min, children: [
          SizedBox(
              width: 48,
              height: 30,
              child: Stack(children: [
                Positioned(
                    left: 0,
                    child: Icon(Icons.circle,
                        color: Colors.redAccent.withValues(alpha: 0.9),
                        size: 28)),
                Positioned(
                    left: 16,
                    child: Icon(Icons.circle,
                        color: Colors.orangeAccent.withValues(alpha: 0.9),
                        size: 28)),
              ])),
          const SizedBox(width: 4),
          const Text('mastercard',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5))
        ]);
      case 'AMEX':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
              color: const Color(0xFF007BC1),
              borderRadius: BorderRadius.circular(4)),
          child: const Text('AMEX',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic)),
        );
      case 'DISCOVER':
        return const Text('DISCOVER',
            style: TextStyle(
                color: Colors.orange,
                fontSize: 16,
                fontWeight: FontWeight.bold));
      case 'JCB':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(4)),
          child: const Text('JCB',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        );
      default:
        return Text(type,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold));
    }
  }

  Widget _buildCreditCardVisual(Map<String, dynamic> card,
      {bool compact = false}) {
    String rawNum = card['number'];
    String maskedNum = rawNum;
    if (rawNum.length >= 12) {
      String first4 = rawNum.substring(0, 4);
      String last4 = rawNum.substring(rawNum.length - 4);
      maskedNum = '$first4  ••••  ••••  $last4';
    }

    final bool isDefault = card['isDefault'] == true;
    final String holder =
        (card['holder'] as String?)?.toUpperCase() ?? 'CARDHOLDER';

    return Container(
      height: compact ? 160 : 195,
      padding: EdgeInsets.all(compact ? 18 : 22),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: card['type'] == 'VISA'
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : card['type'] == 'MASTERCARD'
                    ? [const Color(0xFF1C1C1C), const Color(0xFF2D2D2D)]
                    : card['type'] == 'AMEX'
                        ? [const Color(0xFF0D1B2A), const Color(0xFF1B3A5A)]
                        : [const Color(0xFF1A1A1A), const Color(0xFF2C2C2C)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isDefault
                  ? AppTheme.brand.withValues(alpha: 0.5)
                  : Colors.white.withValues(alpha: 0.1),
              width: isDefault ? 1.5 : 1),
          boxShadow: const [
            BoxShadow(
                color: Colors.black54, blurRadius: 18, offset: Offset(0, 6))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top row: chip + network logo
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(children: [
                // EMV chip
                Container(
                  width: 36,
                  height: 26,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFD4AF37), Color(0xFFA07800)]),
                  ),
                  child: Stack(children: [
                    Center(
                        child: Container(
                            width: 22,
                            height: 18,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFF8B6914), width: 0.5),
                                borderRadius: BorderRadius.circular(2)))),
                    Center(
                        child: Container(
                            width: 1,
                            height: 18,
                            color: const Color(0xFF8B6914)
                                .withValues(alpha: 0.6))),
                    Center(
                        child: Container(
                            width: 22,
                            height: 1,
                            color: const Color(0xFF8B6914)
                                .withValues(alpha: 0.6))),
                  ]),
                ),
                if (isDefault) ...[
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppTheme.brand.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.brand.withValues(alpha: 0.4))),
                    child: const Text('DEFAULT',
                        style: TextStyle(
                            color: AppTheme.brand,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.8)),
                  ),
                ]
              ]),
              _getCardLogo(card['type']),
            ],
          ),

          // Card number
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(maskedNum,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: compact ? 14 : 16,
                    letterSpacing: 2.0,
                    fontFamily: 'OCR-A')),
          ),

          // Bottom row: holder + expiry
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('CARD HOLDER',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: compact ? 8 : 9,
                        letterSpacing: 1.0,
                        fontFamily: 'OCR-A')),
                const SizedBox(height: 2),
                Text(holder,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 11 : 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text(context.l10n.expiresTitle,
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: compact ? 8 : 9,
                        letterSpacing: 1.0,
                        fontFamily: 'OCR-A')),
                const SizedBox(height: 2),
                Text(card['expiry'],
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                        fontFamily: 'OCR-A')),
              ]),
            ],
          )
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // PAYMENT METHODS TAB
  // ---------------------------------------------------------------------------
  Widget _buildPaymentMethodsTab() {
    bool isTrainer = widget.role == 'Trainer';
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        if (isTrainer) ...[
          _buildPayoutMethodSwitcher(),
          const SizedBox(height: 40),
          const Divider(color: AppTheme.divider),
          const SizedBox(height: 30),
        ],
        Text(context.l10n.paymentMethodsTitle,
            style: const TextStyle(
                color: AppTheme.brand,
                fontSize: AppConstants.kDefaultTitleFontSize,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Text(context.l10n.managePaymentMethodsDesc,
            style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppConstants.kDefaultSubtitleFontSize)),
        const SizedBox(height: 24),
        SolidConfirmButton(
          label: context.l10n.addCardButton,
          icon: Icons.add,
          height: 50,
          onPressed: _showAddCardDialog,
        ),
        const SizedBox(height: 30),
        ..._mockCards.map((card) => Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  _buildCreditCardVisual(card),
                  const SizedBox(height: 14),
                  // Action row: Default | Edit | Remove
                  Row(
                    children: [
                      if (!(card['isDefault'] == true))
                        Expanded(
                          child: OutlineActionButton(
                              label: 'SET DEFAULT',
                              icon: const Icon(Icons.star_border_outlined,
                                  size: 14, color: AppTheme.brand),
                              height: 40,
                              onPressed: () => _setDefaultCard(card)),
                        ),
                      if (!(card['isDefault'] == true))
                        const SizedBox(width: 10),
                      Expanded(
                        child: OutlineActionButton(
                            label: context.l10n.edit.toUpperCase(),
                            icon: const Icon(Icons.edit_outlined,
                                size: 14, color: AppTheme.brand),
                            height: 40,
                            onPressed: () =>
                                _showAddCardDialog(existingCard: card)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlineActionButton(
                            label: context.l10n.remove.toUpperCase(),
                            icon: const Icon(Icons.delete_outline,
                                size: 14, color: AppTheme.error),
                            textColor: AppTheme.error,
                            borderColor: AppTheme.error,
                            height: 40,
                            onPressed: () => _confirmRemoveCard(card)),
                      )
                    ],
                  )
                ],
              ),
            )),
        if (_mockCards.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: TnTEmptyState(
              icon: Icons.credit_card_off_outlined,
              title: 'No cards saved yet',
              message: 'Add a card to pay for sessions and memberships.',
            ),
          ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // MEMBERSHIPS TAB
  // ---------------------------------------------------------------------------
  Widget _buildMembershipsTab() {
    return ListView(
      key: const PageStorageKey<String>('memberships_tab'),
      padding: const EdgeInsets.all(24.0),
      physics:
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      children: [
        // Empty state
        TnTPremiumCard(
          padding: const EdgeInsets.all(24),
          radius: 18,
          accentColor: AppTheme.brand,
          child: Column(children: [
            const Icon(Icons.card_membership_outlined,
                color: AppTheme.textSecondary, size: 48),
            const SizedBox(height: 16),
            Text(context.l10n.noActiveMemberships,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(context.l10n.noActiveMembershipsDesc,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center),
          ]),
        ),
        const SizedBox(height: 30),
        const Divider(color: AppTheme.divider),
        const SizedBox(height: 25),
        const Text('Choose Your Journey',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
            'Prices convert to your local currency securely at checkout.',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 25),
        SizedBox(
          height: 490,
          child: Stack(
            children: [
              ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  SizedBox(
                    width: 310,
                    child: _buildPricingCard(
                      title: context.l10n.membershipStarterTier,
                      monthlyPrice: '\$29',
                      annualPrice: '\$290',
                      isPopular: false,
                      features: [
                        'Access to Premium Posts',
                        'General Workout Templates',
                        'Community Forum Access',
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 310,
                    child: _buildPricingCard(
                      title: context.l10n.membershipProTrainee,
                      monthlyPrice: '\$89',
                      annualPrice: '\$890',
                      isPopular: true,
                      features: [
                        'Customized Diet Plan',
                        'Weekly Check-ins',
                        '1-on-1 Chat Access',
                        'All Starter Features',
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  SizedBox(
                    width: 310,
                    child: _buildPricingCard(
                      title: context.l10n.membershipEliteCoaching,
                      monthlyPrice: '\$199',
                      annualPrice: '\$1,990',
                      isPopular: false,
                      features: [
                        'Daily Accountability',
                        'Video Form Analysis',
                        'Live Q&A Sessions',
                        'All Pro Features',
                      ],
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              // Scroll fade + hint
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    width: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerRight,
                        end: Alignment.centerLeft,
                        colors: [
                          AppTheme.bg.withValues(alpha: 0.95),
                          AppTheme.bg.withValues(alpha: 0.0)
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.chevron_right,
                          color: Colors.white54, size: 28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String monthlyPrice,
    required String annualPrice,
    required bool isPopular,
    required List<String> features,
  }) {
    return StatefulBuilder(builder: (context, setInnerState) {
      bool isAnnual = false;
      return StatefulBuilder(builder: (context, setLocalState) {
        return TnTPremiumCard(
          margin: const EdgeInsets.only(bottom: 20),
          padding: EdgeInsets.zero,
          radius: 16,
          accentColor: isPopular ? AppTheme.brand : AppTheme.textSecondary,
          backgroundColor: isPopular
              ? AppTheme.brand.withValues(alpha: 0.045)
              : AppTheme.surfaceRaised,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isPopular)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: const BoxDecoration(
                    color: AppTheme.brand,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(14)),
                  ),
                  child: const Text('MOST POPULAR',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppTheme.bg,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2)),
                ),
              Padding(
                padding: const EdgeInsets.all(22.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    // Billing toggle
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                          color: AppTheme.bg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.divider)),
                      child: Row(
                        children: [
                          _billingSegment('Monthly', !isAnnual, () {
                            setLocalState(() => isAnnual = false);
                          }),
                          _billingSegment('Annual', isAnnual, () {
                            setLocalState(() => isAnnual = true);
                          }, badge: '2 months free'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(isAnnual ? annualPrice : monthlyPrice,
                            style: const TextStyle(
                                color: AppTheme.brand,
                                fontSize: 34,
                                fontWeight: FontWeight.w900)),
                        const SizedBox(width: 4),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5.0),
                          child: Text(isAnnual ? '/ year' : '/ month',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 13)),
                        ),
                      ],
                    ),
                    if (isAnnual)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('Billed as $annualPrice per year',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 11)),
                      ),
                    const SizedBox(height: 18),
                    const Divider(color: AppTheme.divider, height: 1),
                    const SizedBox(height: 18),
                    ...features.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 11.0),
                          child: Row(children: [
                            const Icon(Icons.check_circle_rounded,
                                color: AppTheme.brand, size: 18),
                            const SizedBox(width: 10),
                            Flexible(
                                child: Text(f,
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize: 13)))
                          ]),
                        )),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isPopular ? AppTheme.brand : AppTheme.surface,
                          side: isPopular
                              ? BorderSide.none
                              : const BorderSide(color: AppTheme.divider),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                        onPressed: () => HapticFeedback.selectionClick(),
                        child: Text('SUBSCRIBE NOW',
                            style: TextStyle(
                                color: isPopular
                                    ? AppTheme.buttonText
                                    : AppTheme.textPrimary,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                letterSpacing: 1.0)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      });
    });
  }

  Widget _billingSegment(String label, bool selected, VoidCallback onTap,
      {String? badge}) {
    return Expanded(
      child: TnTPressable(
        onTap: () {
          onTap();
        },
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
              color: selected ? AppTheme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: selected ? Border.all(color: AppTheme.divider) : null),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: TextStyle(
                      color: selected
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight:
                          selected ? FontWeight.bold : FontWeight.normal),
                  textAlign: TextAlign.center),
              if (badge != null && selected)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(badge,
                      style: const TextStyle(
                          color: AppTheme.cardGreen,
                          fontSize: 9,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: Text(context.l10n.payments,
            style: const TextStyle(color: AppTheme.brand)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.brand,
          indicatorWeight: 3,
          labelColor: AppTheme.brand,
          unselectedLabelColor: AppTheme.textSecondary,
          labelStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          dividerColor: AppTheme.divider,
          tabs: const [
            Tab(text: 'Payment Methods'),
            Tab(text: 'Transactions'),
            Tab(text: 'Memberships'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPaymentMethodsTab(),
          const TransactionsTab(),
          _buildMembershipsTab(),
        ],
      ),
    );
  }
}

// =============================================================================
// ADD / EDIT CARD DIALOG
// =============================================================================
class AddCardDialog extends StatefulWidget {
  final Map<String, dynamic>? initialCard;
  const AddCardDialog({super.key, this.initialCard});

  @override
  State<AddCardDialog> createState() => _AddCardDialogState();
}

class _AddCardDialogState extends State<AddCardDialog> {
  final TextEditingController _numCtrl = TextEditingController();
  final TextEditingController _expCtrl = TextEditingController();
  final TextEditingController _cvvCtrl = TextEditingController();
  final TextEditingController _holderCtrl = TextEditingController();

  String _detectedType = 'VISA';

  @override
  void initState() {
    super.initState();
    if (widget.initialCard != null) {
      String rawNum = widget.initialCard!['number'];
      StringBuffer formatted = StringBuffer();
      for (int i = 0; i < rawNum.length; i++) {
        if (i > 0 && i % 4 == 0) formatted.write(' ');
        formatted.write(rawNum[i]);
      }
      _numCtrl.text = formatted.toString();
      _expCtrl.text = widget.initialCard!['expiry'];
      _cvvCtrl.text = '123';
      _holderCtrl.text = widget.initialCard!['holder'] ?? '';
      _detectedType = widget.initialCard!['type'] ?? 'VISA';
    }
  }

  @override
  void dispose() {
    _numCtrl.dispose();
    _expCtrl.dispose();
    _cvvCtrl.dispose();
    _holderCtrl.dispose();
    super.dispose();
  }

  String? get _numError {
    String raw = _numCtrl.text.replaceAll(' ', '');
    if (raw.isEmpty || raw.length < 12) return '12-19 digits required';
    if (!RegExp(r'^\d+$').hasMatch(raw)) return 'Digits only';
    return null;
  }

  String? get _holderError {
    if (_holderCtrl.text.trim().isEmpty) return 'Cardholder name required';
    if (_holderCtrl.text.trim().length < 2) return 'Name too short';
    return null;
  }

  String? get _expError {
    String val = _expCtrl.text;
    if (val.isEmpty || !RegExp(r'^\d{2}/\d{2}$').hasMatch(val)) {
      return 'Invalid MM/YY';
    }
    List<String> parts = val.split('/');
    int month = int.parse(parts[0]);
    int year = int.parse(parts[1]);
    DateTime now = DateTime.now();
    int currentYear = now.year % 100;
    int currentMonth = now.month;

    if (month < 1 || month > 12) return 'Invalid month';
    if (year < currentYear || (year == currentYear && month < currentMonth)) {
      return 'Card has expired';
    }
    if (year > currentYear + 10) return 'Invalid expiry year';
    return null;
  }

  String? get _cvvError {
    String val = _cvvCtrl.text;
    if (val.isEmpty || val.length < 3) return '3-4 digits required';
    if (!RegExp(r'^\d+$').hasMatch(val)) return 'Digits only';
    return null;
  }

  bool get _isFormValid =>
      _numError == null &&
      _holderError == null &&
      _expError == null &&
      _cvvError == null;

  InputDecoration _fieldDecoration(String label,
      {Widget? prefix, String? errorText}) {
    return InputDecoration(
      labelText: label,
      errorText: errorText,
      errorMaxLines: 2,
      prefixIcon: prefix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      floatingLabelStyle: const TextStyle(color: AppTheme.brand),
      enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.textSecondary)),
      focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.brand, width: 2)),
      errorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.error)),
      focusedErrorBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.error, width: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build a live preview card from current input
    String rawNumPreview = _numCtrl.text.replaceAll(' ', '');
    String maskedPreview = '';
    if (rawNumPreview.length >= 12) {
      String first4 = rawNumPreview.substring(0, 4);
      String last4 = rawNumPreview.substring(rawNumPreview.length - 4);
      maskedPreview = '$first4  ••••  ••••  $last4';
    } else if (rawNumPreview.isNotEmpty) {
      maskedPreview = _numCtrl.text;
    } else {
      maskedPreview = '••••  ••••  ••••  ••••';
    }

    String holderPreview = _holderCtrl.text.trim().isEmpty
        ? 'FULL NAME'
        : _holderCtrl.text.trim().toUpperCase();
    String expPreview = _expCtrl.text.isEmpty ? 'MM/YY' : _expCtrl.text;

    return Dialog(
      backgroundColor: AppTheme.bg,
      shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          side: const BorderSide(color: AppTheme.divider)),
      insetPadding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dialog title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Text(
                  widget.initialCard != null
                      ? '${context.l10n.edit} Card'
                      : 'Add Card',
                  style: const TextStyle(
                      color: AppTheme.brand,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),
            const Divider(color: AppTheme.divider, height: 1),

            Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Live card preview
                      _LiveCardPreview(
                        maskedNumber: maskedPreview,
                        holder: holderPreview,
                        expiry: expPreview,
                        cardType: _detectedType,
                      ),
                      const SizedBox(height: 24),

                      // Card number
                      TextFormField(
                        controller: _numCtrl,
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontFamily: 'OCR-A',
                            letterSpacing: 1.5),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9 ]')),
                          CardNumberFormatter()
                        ],
                        onChanged: (v) {
                          String raw = v.replaceAll(' ', '');
                          setState(() => _detectedType = _detectCardType(raw));
                        },
                        decoration: _fieldDecoration(
                            context.l10n.cardNumberLabel,
                            prefix: const Icon(Icons.credit_card,
                                color: AppTheme.textSecondary, size: 18),
                            errorText:
                                _numCtrl.text.isEmpty ? null : _numError),
                      ),
                      const SizedBox(height: 15),

                      // Cardholder name
                      TextFormField(
                        controller: _holderCtrl,
                        style: const TextStyle(color: AppTheme.textPrimary),
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r"[a-zA-Z '\-]")),
                        ],
                        onChanged: (_) => setState(() {}),
                        decoration: _fieldDecoration('Cardholder Name',
                            prefix: const Icon(Icons.person_outline,
                                color: AppTheme.textSecondary, size: 18),
                            errorText:
                                _holderCtrl.text.isEmpty ? null : _holderError),
                      ),
                      const SizedBox(height: 15),

                      // Expiry + CVV row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: TextFormField(
                                  controller: _expCtrl,
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary),
                                  keyboardType: TextInputType.datetime,
                                  onChanged: (_) => setState(() {}),
                                  inputFormatters: [
                                    ExpiryDateFormatter(),
                                    LengthLimitingTextInputFormatter(5)
                                  ],
                                  decoration: _fieldDecoration(
                                    context.l10n.expiryLabel,
                                    errorText: _expCtrl.text.isEmpty
                                        ? null
                                        : _expError,
                                  ).copyWith(
                                      hintText: context.l10n.expiryHint,
                                      hintStyle: const TextStyle(
                                          color: Colors.white24)))),
                          const SizedBox(width: 15),
                          Expanded(
                              child: TextFormField(
                                  controller: _cvvCtrl,
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary),
                                  obscureText: true,
                                  keyboardType: TextInputType.number,
                                  onChanged: (_) => setState(() {}),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(4)
                                  ],
                                  decoration: _fieldDecoration(
                                    context.l10n.cvvLabel,
                                    prefix: const Icon(Icons.lock_outline,
                                        color: AppTheme.textSecondary,
                                        size: 18),
                                    errorText: _cvvCtrl.text.isEmpty
                                        ? null
                                        : _cvvError,
                                  ))),
                        ],
                      ),
                      const SizedBox(height: 30),

                      SolidConfirmButton(
                          label: context.l10n.saveCard,
                          height: AppConstants.kDefaultButtonHeightLarge,
                          onPressed: _isFormValid
                              ? () {
                                  HapticFeedback.selectionClick();
                                  String raw =
                                      _numCtrl.text.replaceAll(' ', '');
                                  Navigator.pop(context, {
                                    'type': _detectedType,
                                    'number': raw,
                                    'expiry': _expCtrl.text,
                                    'holder': _holderCtrl.text.trim(),
                                  });
                                }
                              : null),
                      const SizedBox(height: 12),
                      OutlineActionButton(
                          label: context.l10n.cancel,
                          height: AppConstants.kDefaultButtonHeightLarge,
                          textColor: AppTheme.textSecondary,
                          borderColor: AppTheme.divider,
                          onPressed: () => Navigator.pop(context)),
                    ]))
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// LIVE CARD PREVIEW (used inside AddCardDialog)
// =============================================================================
class _LiveCardPreview extends StatelessWidget {
  final String maskedNumber;
  final String holder;
  final String expiry;
  final String cardType;

  const _LiveCardPreview({
    required this.maskedNumber,
    required this.holder,
    required this.expiry,
    required this.cardType,
  });

  Widget _logo() {
    switch (cardType) {
      case 'VISA':
        return const Text('VISA',
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                fontFamily: 'Arial'));
      case 'MASTERCARD':
        return SizedBox(
            width: 42,
            height: 26,
            child: Stack(children: [
              Positioned(
                  left: 0,
                  child: Icon(Icons.circle,
                      color: Colors.redAccent.withValues(alpha: 0.9),
                      size: 24)),
              Positioned(
                  left: 14,
                  child: Icon(Icons.circle,
                      color: Colors.orangeAccent.withValues(alpha: 0.9),
                      size: 24)),
            ]));
      case 'AMEX':
        return const Text('AMEX',
            style: TextStyle(
                color: Color(0xFF009CDE),
                fontSize: 16,
                fontWeight: FontWeight.bold));
      default:
        return Text(cardType,
            style: const TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.bold));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 155,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: cardType == 'VISA'
                ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                : cardType == 'MASTERCARD'
                    ? [const Color(0xFF1C1C1C), const Color(0xFF2D2D2D)]
                    : cardType == 'AMEX'
                        ? [const Color(0xFF0D1B2A), const Color(0xFF1B3A5A)]
                        : [const Color(0xFF1A1A1A), const Color(0xFF2C2C2C)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
          boxShadow: const [
            BoxShadow(
                color: Colors.black38, blurRadius: 12, offset: Offset(0, 4))
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Mini chip
              Container(
                width: 28,
                height: 20,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFD4AF37), Color(0xFFA07800)]),
                ),
              ),
              _logo(),
            ],
          ),
          Text(maskedNumber,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  letterSpacing: 1.8,
                  fontFamily: 'OCR-A')),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('CARD HOLDER',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 8,
                        letterSpacing: 0.8,
                        fontFamily: 'OCR-A')),
                const SizedBox(height: 2),
                Text(holder,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ]),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                const Text('EXPIRES',
                    style: TextStyle(
                        color: Colors.white54,
                        fontSize: 8,
                        letterSpacing: 0.8,
                        fontFamily: 'OCR-A')),
                const SizedBox(height: 2),
                Text(expiry,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'OCR-A')),
              ]),
            ],
          )
        ],
      ),
    );
  }
}

// =============================================================================
// TRANSACTIONS TAB
// =============================================================================
class TransactionsTab extends StatefulWidget {
  const TransactionsTab({super.key});

  @override
  State<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends State<TransactionsTab> {
  String _searchQuery = '';
  String _statusFilter = 'All'; // All | Completed | Pending | Failed

  final List<Map<String, dynamic>> _allTransactions = [
    {
      'date': 'July 28, 2023',
      'time': '14:30',
      'title': 'Monthly Membership',
      'type': 'Card Payment',
      'amount': '\$29.00',
      'isPositive': false,
      'initial': 'MM',
      'color': AppTheme.cardPurple,
      'status': 'Completed',
      'ref': '#TX-84931A',
    },
    {
      'date': 'July 20, 2023',
      'time': '09:15',
      'title': '1-on-1 Coaching Session',
      'type': 'Card Payment',
      'amount': '\$50.00',
      'isPositive': false,
      'initial': 'CS',
      'color': AppTheme.cardBlue,
      'status': 'Completed',
      'ref': '#TX-99023C',
    },
    {
      'date': 'July 15, 2023',
      'time': '18:45',
      'title': 'Diet Plan Purchase',
      'type': 'PayPal',
      'amount': '\$19.99',
      'isPositive': false,
      'initial': 'DP',
      'color': AppTheme.cardGreen,
      'status': 'Completed',
      'ref': '#TX-11002B',
    },
    {
      'date': 'July 12, 2023',
      'time': '08:00',
      'title': 'Session Payout',
      'type': 'Bank Transfer',
      'amount': '+\$120.00',
      'isPositive': true,
      'initial': 'SP',
      'color': AppTheme.cardYellow,
      'status': 'Pending',
      'ref': '#TX-30021E',
    },
    {
      'date': 'July 10, 2023',
      'time': '11:00',
      'title': 'Supplement Order',
      'type': 'Card Payment',
      'amount': '\$45.50',
      'isPositive': false,
      'initial': 'SO',
      'color': AppTheme.cardRed,
      'status': 'Failed',
      'ref': '#TX-44021F',
    },
  ];

  List<Map<String, dynamic>> get _filteredTransactions {
    return _allTransactions.where((tx) {
      final matchesSearch = tx['title']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          tx['date']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          tx['ref']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _statusFilter == 'All' || tx['status'] == _statusFilter;
      return matchesSearch && matchesStatus;
    }).toList();
  }

  void _showTransactionDetails(Map<String, dynamic> tx) {
    HapticFeedback.selectionClick();
    AppMotion.showPremiumBottomSheet(
        context: context,
        backgroundColor: AppTheme.surface,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        builder: (context) => Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                      child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: AppTheme.divider,
                              borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 25),

                  // Amount & title
                  Text(tx['title'],
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(tx['amount'],
                      style: TextStyle(
                          color: tx['isPositive']
                              ? AppTheme.cardGreen
                              : tx['status'] == 'Failed'
                                  ? AppTheme.error
                                  : AppTheme.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'OCR-A'),
                      textAlign: TextAlign.center),
                  const SizedBox(height: 25),
                  const Divider(color: AppTheme.divider),
                  const SizedBox(height: 15),

                  _buildDetailRow('Date', '${tx['date']}  ·  ${tx['time']}'),
                  _buildDetailRow('Status', tx['status'],
                      valueColor: _statusColor(tx['status'])),
                  _buildDetailRow('Payment Method', tx['type']),
                  _buildDetailRow('Reference ID', tx['ref']),
                  const SizedBox(height: 20),

                  // Copy ref action
                  OutlineActionButton(
                    label: 'Copy Reference ID',
                    icon: const Icon(Icons.copy_outlined,
                        color: AppTheme.brand, size: 15),
                    height: 42,
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: tx['ref']));
                      Navigator.pop(context);
                      AppUtils.showToast(context, 'Reference ID copied');
                    },
                  ),
                  const SizedBox(height: 12),
                  SolidConfirmButton(
                      label: context.l10n.close,
                      height: AppConstants.kDefaultButtonHeightLarge,
                      onPressed: () => Navigator.pop(context)),
                  const SizedBox(height: 10),
                ],
              ),
            ));
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Completed':
        return AppTheme.cardGreen;
      case 'Pending':
        return AppTheme.cardYellow;
      case 'Failed':
        return AppTheme.error;
      default:
        return AppTheme.textSecondary;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'Completed':
        return Icons.check_circle_rounded;
      case 'Pending':
        return Icons.schedule_rounded;
      case 'Failed':
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline;
    }
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          Text(value,
              style: TextStyle(
                  color: valueColor ?? AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTypeIcon(String type) {
    IconData icon;
    Color color;
    switch (type) {
      case 'PayPal':
        icon = Icons.paypal_outlined;
        color = const Color(0xFF009CDE);
        break;
      case 'Bank Transfer':
        icon = Icons.account_balance_outlined;
        color = AppTheme.cardGreen;
        break;
      default:
        icon = Icons.credit_card_outlined;
        color = AppTheme.textSecondary;
    }
    return Icon(icon, size: 12, color: color);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTransactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Search bar
        Container(
          color: AppTheme.bg,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: TextField(
            style: const TextStyle(color: AppTheme.textPrimary),
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: context.l10n.searchTransactions,
              hintStyle:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              prefixIcon:
                  const Icon(Icons.search, color: AppTheme.textSecondary),
              filled: true,
              fillColor: AppTheme.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),

        // Status filter chips
        Container(
          color: AppTheme.bg,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: ['All', 'Completed', 'Pending', 'Failed']
                  .map((s) => _StatusChip(
                        label: s,
                        selected: _statusFilter == s,
                        color: s == 'All'
                            ? AppTheme.textSecondary
                            : _statusColor(s),
                        onTap: () => setState(() => _statusFilter = s),
                      ))
                  .toList(),
            ),
          ),
        ),

        // Results count + export
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          color: AppTheme.surface,
          child: Row(
            children: [
              Text(context.l10n.showingResultsCount(filtered.length),
                  style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              GestureDetector(
                onTap: () => HapticFeedback.lightImpact(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                      color: AppTheme.bg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.divider)),
                  child: Row(children: [
                    const Icon(Icons.download_outlined,
                        size: 13, color: AppTheme.textSecondary),
                    const SizedBox(width: 5),
                    Text(context.l10n.exportAction,
                        style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              )
            ],
          ),
        ),

        // Transaction list
        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          color: AppTheme.textSecondary, size: 48),
                      const SizedBox(height: 14),
                      const Text('No transactions found',
                          style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text('Try adjusting your search or filters.',
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 13)),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final tx = filtered[index];
                    return InkWell(
                      onTap: () => _showTransactionDetails(tx),
                      child: _buildTransactionTile(tx),
                    );
                  }),
        )
      ],
    );
  }

  Widget _buildTransactionTile(Map<String, dynamic> tx) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.divider))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar circle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
                color: (tx['color'] as Color).withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(
                    color: (tx['color'] as Color).withValues(alpha: 0.4),
                    width: 1)),
            child: Center(
                child: Text(tx['initial'],
                    style: TextStyle(
                        color: tx['color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 13))),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['title'],
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                const SizedBox(height: 3),
                Text(tx['date'],
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
                const SizedBox(height: 3),
                Row(children: [
                  _buildTypeIcon(tx['type']),
                  const SizedBox(width: 4),
                  Text(tx['type'],
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12)),
                ]),
              ],
            ),
          ),

          // Amount + status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(tx['amount'],
                  style: TextStyle(
                      color: tx['isPositive']
                          ? AppTheme.cardGreen
                          : tx['status'] == 'Failed'
                              ? AppTheme.error
                              : AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      fontFamily: 'OCR-A')),
              const SizedBox(height: 5),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_statusIcon(tx['status']),
                      color: _statusColor(tx['status']), size: 13),
                  const SizedBox(width: 4),
                  Text(tx['status'],
                      style: TextStyle(
                          color: _statusColor(tx['status']),
                          fontSize: 11,
                          fontWeight: FontWeight.w600)),
                ],
              )
            ],
          )
        ],
      ),
    );
  }
}

// =============================================================================
// STATUS FILTER CHIP
// =============================================================================
class _StatusChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppTheme.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(label,
            style: TextStyle(
                color: selected ? color : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}

// =============================================================================
// EGYPTIAN BANKS INTEGRATION
// =============================================================================

class EgyptianBankModel extends Equatable {
  final String name;
  final String logoPath;

  const EgyptianBankModel({required this.name, required this.logoPath});

  @override
  List<Object?> get props => [name, logoPath];
}

const List<EgyptianBankModel> egyptianBanksList = [
  EgyptianBankModel(
      name: 'National Bank of Egypt (NBE)',
      logoPath: 'assets/images/banks/National_Bank_of_Egypt_(NBE).svg'),
  EgyptianBankModel(
      name: 'Banque Misr', logoPath: 'assets/images/banks/Banque_Misr.svg'),
  EgyptianBankModel(
      name: 'Banque du Caire',
      logoPath: 'assets/images/banks/Banque_du_Caire.svg'),
  EgyptianBankModel(
      name: 'Commercial International Bank (CIB)',
      logoPath: 'assets/images/banks/Commercial_International_Bank_(CIB).svg'),
  EgyptianBankModel(
      name: 'Bank of Alexandria (ALEXBANK)',
      logoPath: 'assets/images/banks/Bank_of_Alexandria_(ALEXBANK).svg'),
  EgyptianBankModel(
      name: 'QNB Alahli', logoPath: 'assets/images/banks/QNB_Alahli.svg'),
  EgyptianBankModel(
      name: 'First Abu Dhabi Bank Misr (FABMISR)',
      logoPath: 'assets/images/banks/First_Abu_Dhabi_Bank_Misr_(FABMISR).svg'),
  EgyptianBankModel(
      name: 'Arab African International Bank (AAIB)',
      logoPath:
          'assets/images/banks/Arab_African_International_Bank_(AAIB).svg'),
  EgyptianBankModel(
      name: 'Housing and Development Bank (HDB)',
      logoPath: 'assets/images/banks/Housing_and_Development_Bank_(HDB).svg'),
  EgyptianBankModel(
      name: 'Agricultural Bank of Egypt',
      logoPath: 'assets/images/banks/Agricultural_Bank_of_Egypt.svg'),
  EgyptianBankModel(
      name: 'Suez Canal Bank',
      logoPath: 'assets/images/banks/Suez_Canal_Bank.svg'),
  EgyptianBankModel(
      name: 'Export Development Bank of Egypt (EBank)',
      logoPath:
          'assets/images/banks/Export_Development_Bank_of_Egypt_(EBank).svg'),
  EgyptianBankModel(
      name: 'Industrial Development Bank',
      logoPath: 'assets/images/banks/Industrial_Development_Bank.svg'),
  EgyptianBankModel(
      name: 'Egyptian Arab Land Bank',
      logoPath: 'assets/images/banks/Egyptian_Arab_Land_Bank.svg'),
  EgyptianBankModel(
      name: 'The United Bank',
      logoPath: 'assets/images/banks/The_United_Bank.svg'),
  EgyptianBankModel(
      name: 'Arab International Bank (AIB)',
      logoPath: 'assets/images/banks/Arab_International_Bank_(AIB).svg'),
  EgyptianBankModel(
      name: 'Bank NXT (formerly aiBANK)',
      logoPath: 'assets/images/banks/Bank_NXT_(formerly_aiBANK).svg'),
  EgyptianBankModel(
      name: 'Emirates NBD Egypt',
      logoPath: 'assets/images/banks/Emirates_NBD_Egypt.svg'),
  EgyptianBankModel(
      name: 'Abu Dhabi Islamic Bank - Egypt (ADIB)',
      logoPath: 'assets/images/banks/Abu_Dhabi_Islamic_Bank_-Egypt(ADIB).svg'),
  EgyptianBankModel(
      name: 'Abu Dhabi Commercial Bank - Egypt (ADCB)',
      logoPath:
          'assets/images/banks/Abu_Dhabi_Commercial_Bank_-Egypt(ADCB).svg'),
  EgyptianBankModel(
      name: 'Citibank Egypt',
      logoPath: 'assets/images/banks/Citibank_Egypt.svg'),
  EgyptianBankModel(
      name: 'Mashreq Bank Egypt',
      logoPath: 'assets/images/banks/Mashreq_Bank_Egypt.svg'),
  EgyptianBankModel(
      name: 'Al Ahli Bank of Kuwait - Egypt (ABK-Egypt)',
      logoPath:
          'assets/images/banks/Al_Ahli_Bank_of_Kuwait_-Egypt(ABK-Egypt).svg'),
  EgyptianBankModel(
      name: 'Faisal Islamic Bank of Egypt',
      logoPath: 'assets/images/banks/Faisal_Islamic_Bank_of_Egypt.svg'),
  EgyptianBankModel(
      name: 'Al Baraka Bank Egypt',
      logoPath: 'assets/images/banks/Al_Baraka_Bank_Egypt.svg'),
  EgyptianBankModel(
      name: 'Attijariwafa Bank Egypt',
      logoPath: 'assets/images/banks/Attijariwafa_Bank_Egypt.svg'),
  EgyptianBankModel(
      name: 'National Bank of Kuwait - Egypt (NBK)',
      logoPath: 'assets/images/banks/National_Bank_of_Kuwait_-Egypt(NBK).svg'),
  EgyptianBankModel(
      name: 'Ahli United Bank',
      logoPath: 'assets/images/banks/Ahli_United_Bank.svg'),
  EgyptianBankModel(
      name: 'HSBC Bank Egypt S.A.E.',
      logoPath: 'assets/images/banks/HSBC_Bank_Egypt_S.A.E..svg'),
  EgyptianBankModel(
      name: 'Credit Agricole Egypt',
      logoPath: 'assets/images/banks/Credit_Agricole_Egypt.svg'),
  EgyptianBankModel(
      name: 'Arab Banking Corporation (Bank ABC)',
      logoPath: 'assets/images/banks/Arab_Banking_Corporation_(Bank_ABC).svg'),
  EgyptianBankModel(
      name: 'MIDBANK (Misr Iran Development Bank)',
      logoPath: 'assets/images/banks/MIDBANK_(Misr_Iran_Development_Bank).svg'),
  EgyptianBankModel(
      name: 'Egyptian Gulf Bank (EGbank)',
      logoPath: 'assets/images/banks/Egyptian_Gulf_Bank_(EGbank).svg'),
  EgyptianBankModel(
      name: 'Societe Arabe Internationale De Banque (saib)',
      logoPath:
          'assets/images/banks/Societe_Arabe_Internationale_De_Banque_(saib).svg'),
  EgyptianBankModel(
      name: 'Arab Bank', logoPath: 'assets/images/banks/Arab_Bank.svg'),
  EgyptianBankModel(
      name: 'Standard Chartered Bank',
      logoPath: 'assets/images/banks/Standard_Chartered_Bank.svg'),
];

bool isValidEgyptianIban(String iban) {
  String raw = iban.replaceAll(' ', '');
  if (raw.length != 29) return false;
  if (!raw.startsWith('EG')) return false;
  // Characters 3-4: Check Digits (2 digits).
  if (!RegExp(r'^\d{2}$').hasMatch(raw.substring(2, 4))) return false;
  // Characters 5-8: Bank Code (4 alphanumeric characters).
  if (!RegExp(r'^[A-Z0-9]{4}$').hasMatch(raw.substring(4, 8))) return false;
  // Characters 9-12: Branch Code (4 digits).
  if (!RegExp(r'^\d{4}$').hasMatch(raw.substring(8, 12))) return false;
  // Characters 13-29: BBAN (17 digits).
  if (!RegExp(r'^\d{17}$').hasMatch(raw.substring(12, 29))) return false;
  return true;
}

class EgyptianIbanFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String text =
        newValue.text.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
    if (text.isNotEmpty && !text.startsWith('E')) {
      text = 'EG$text';
    } else if (text.length == 1 && text == 'E') {
      text = 'E'; // user typed E, allow them to type G
    } else if (text.length == 2 && text[1] != 'G' && text[0] == 'E') {
      text = 'EG${text.substring(1)}';
    } else if (text.length >= 2 && !text.startsWith('EG')) {
      text = 'EG${text.substring(2)}';
    }
    if (text.length > 29) text = text.substring(0, 29);

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(text[i]);
    }

    String formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

abstract class BankingDetailsEvent extends Equatable {
  const BankingDetailsEvent();
  @override
  List<Object?> get props => [];
}

class BankSelected extends BankingDetailsEvent {
  final EgyptianBankModel bank;
  const BankSelected(this.bank);
  @override
  List<Object?> get props => [bank];
}

class AccountHolderNameChanged extends BankingDetailsEvent {
  final String name;
  const AccountHolderNameChanged(this.name);
  @override
  List<Object?> get props => [name];
}

class IbanChanged extends BankingDetailsEvent {
  final String iban;
  const IbanChanged(this.iban);
  @override
  List<Object?> get props => [iban];
}

class SubmitBankingDetails extends BankingDetailsEvent {
  const SubmitBankingDetails();
}

abstract class BankingDetailsState extends Equatable {
  const BankingDetailsState();
  @override
  List<Object?> get props => [];
}

class BankingDetailsInitial extends BankingDetailsState {}

class BankingDetailsUpdated extends BankingDetailsState {
  final EgyptianBankModel? bank;
  final String accountHolderName;
  final String iban;
  final bool isFormValid;

  const BankingDetailsUpdated({
    this.bank,
    this.accountHolderName = '',
    this.iban = '',
    this.isFormValid = false,
  });

  @override
  List<Object?> get props => [bank, accountHolderName, iban, isFormValid];
}

class BankingDetailsSubmitting extends BankingDetailsState {
  final EgyptianBankModel? bank;
  final String accountHolderName;
  final String iban;
  const BankingDetailsSubmitting(
      {this.bank, required this.accountHolderName, required this.iban});
  @override
  List<Object?> get props => [bank, accountHolderName, iban];
}

class BankingDetailsSuccess extends BankingDetailsState {
  final EgyptianBankModel? bank;
  final String accountHolderName;
  final String iban;
  const BankingDetailsSuccess(
      {this.bank, required this.accountHolderName, required this.iban});
  @override
  List<Object?> get props => [bank, accountHolderName, iban];
}

class BankingDetailsError extends BankingDetailsState {
  final String message;
  final EgyptianBankModel? bank;
  final String accountHolderName;
  final String iban;
  const BankingDetailsError(this.message,
      {this.bank, required this.accountHolderName, required this.iban});
  @override
  List<Object?> get props => [message, bank, accountHolderName, iban];
}

class BankingDetailsBloc
    extends Bloc<BankingDetailsEvent, BankingDetailsState> {
  EgyptianBankModel? _selectedBank;
  String _accountHolderName = '';
  String _iban = '';

  BankingDetailsBloc() : super(BankingDetailsInitial()) {
    on<BankSelected>((event, emit) {
      _selectedBank = event.bank;
      _emitUpdate(emit);
    });
    on<AccountHolderNameChanged>((event, emit) {
      _accountHolderName = event.name;
      _emitUpdate(emit);
    });
    on<IbanChanged>((event, emit) {
      _iban = event.iban;
      _emitUpdate(emit);
    });
    on<SubmitBankingDetails>((event, emit) async {
      emit(BankingDetailsSubmitting(
          bank: _selectedBank,
          accountHolderName: _accountHolderName,
          iban: _iban));
      try {
        await Future.delayed(
            const Duration(milliseconds: 600)); // Simulate API Save
        emit(BankingDetailsSuccess(
            bank: _selectedBank,
            accountHolderName: _accountHolderName,
            iban: _iban));
        _emitUpdate(emit);
      } catch (e) {
        emit(BankingDetailsError("Failed to save banking details.",
            bank: _selectedBank,
            accountHolderName: _accountHolderName,
            iban: _iban));
      }
    });
  }

  void _emitUpdate(Emitter<BankingDetailsState> emit) {
    bool valid = _selectedBank != null &&
        _accountHolderName.trim().isNotEmpty &&
        isValidEgyptianIban(_iban);
    emit(BankingDetailsUpdated(
      bank: _selectedBank,
      accountHolderName: _accountHolderName,
      iban: _iban,
      isFormValid: valid,
    ));
  }
}

class EgyptianBankForm extends StatefulWidget {
  const EgyptianBankForm({super.key});

  @override
  State<EgyptianBankForm> createState() => _EgyptianBankFormState();
}

class _EgyptianBankFormState extends State<EgyptianBankForm> {
  late BankingDetailsBloc _bloc;
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _ibanCtrl = TextEditingController();
  bool _isEditingBank = false;
  String _bankSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _bloc = BankingDetailsBloc();

    final existingBankName = appState.bankAccount['bank'];
    if (existingBankName != null && existingBankName.isNotEmpty) {
      try {
        final existingBank =
            egyptianBanksList.firstWhere((b) => b.name == existingBankName);
        _bloc.add(BankSelected(existingBank));
      } catch (_) {}
    }

    final existingHolder = appState.bankAccount['account'];
    if (existingHolder != null && existingHolder.isNotEmpty) {
      _nameCtrl.text = existingHolder;
      _bloc.add(AccountHolderNameChanged(existingHolder));
    }

    final existingIban = appState.bankAccount['iban'];
    if (existingIban != null && existingIban.isNotEmpty) {
      final formatted = existingIban
          .replaceAllMapped(RegExp(r".{4}"), (match) => "${match.group(0)} ")
          .trim();
      _ibanCtrl.text = formatted;
      _bloc.add(IbanChanged(existingIban));
    }
  }

  @override
  void dispose() {
    _bloc.close();
    _nameCtrl.dispose();
    _ibanCtrl.dispose();
    super.dispose();
  }

  void _showBankBottomSheet() {
    AppMotion.showPremiumBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(builder: (context, setSheetState) {
          return DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              final String search = _bankSearchQuery.toLowerCase();
              final filteredBanks = egyptianBanksList
                  .where((b) => b.name.toLowerCase().contains(search))
                  .toList();

              return Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.divider,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Select Bank',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.brand)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextFormField(
                      onChanged: (v) =>
                          setSheetState(() => _bankSearchQuery = v),
                      style: const TextStyle(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Search bank...',
                        hintStyle:
                            const TextStyle(color: AppTheme.textSecondary),
                        prefixIcon: const Icon(Icons.search,
                            color: AppTheme.textSecondary),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.05),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, color: AppTheme.divider),
                  Expanded(
                    child: filteredBanks.isEmpty
                        ? const Center(
                            child: Text('No banks found',
                                style:
                                    TextStyle(color: AppTheme.textSecondary)))
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: filteredBanks.length,
                            itemBuilder: (ctx, index) {
                              final bank = filteredBanks[index];
                              return ListTile(
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.black12, width: 0.5),
                                  ),
                                  child: SvgPicture.asset(bank.logoPath,
                                      fit: BoxFit.contain),
                                ),
                                title: Text(bank.name,
                                    style: const TextStyle(
                                        color: AppTheme.textPrimary)),
                                onTap: () {
                                  _bloc.add(BankSelected(bank));
                                  _bankSearchQuery = '';
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocConsumer<BankingDetailsBloc, BankingDetailsState>(
        listener: (context, state) {
          if (state is BankingDetailsSuccess) {
            appState.saveFinancials(
              appState.payoutMethod,
              appState.paypalEmail,
              {
                'bank': state.bank?.name ?? '',
                'iban': state.iban.replaceAll(' ', ''),
                'account': state.accountHolderName,
                'swift': '', // Not used
              },
            );
            AppUtils.showToast(context, context.l10n.financialsSavedSuccess);
            setState(() => _isEditingBank = false);
          } else if (state is BankingDetailsError) {
            AppUtils.showToast(context, state.message);
          }
        },
        builder: (context, state) {
          bool isValid = false;
          EgyptianBankModel? bank;
          String ibanVal = _ibanCtrl.text.replaceAll(' ', '');
          bool isSubmitting = state is BankingDetailsSubmitting;

          if (state is BankingDetailsUpdated) {
            isValid = state.isFormValid;
            bank = state.bank;
          } else if (state is BankingDetailsSubmitting) {
            bank = state.bank;
          } else if (state is BankingDetailsError) {
            bank = state.bank;
          } else if (state is BankingDetailsSuccess) {
            bank = state.bank;
          }

          final bool hasIbanError =
              ibanVal.isNotEmpty && !isValidEgyptianIban(ibanVal);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: !_isEditingBank
                    ? null
                    : () {
                        HapticFeedback.selectionClick();
                        _showBankBottomSheet();
                      },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
                  decoration: BoxDecoration(
                    color: _isEditingBank
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(
                        AppConstants.kDefaultBorderRadius),
                    border: Border.all(
                      color: _isEditingBank
                          ? AppTheme.textSecondary
                          : AppTheme.divider,
                    ),
                  ),
                  child: Row(
                    children: [
                      if (bank != null)
                        Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border:
                                Border.all(color: Colors.black12, width: 0.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: SvgPicture.asset(bank.logoPath,
                              fit: BoxFit.contain),
                        )
                      else
                        const Icon(Icons.account_balance_outlined,
                            color: AppTheme.textSecondary, size: 18),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          bank != null ? bank.name : 'Select Bank',
                          style: TextStyle(
                            color: bank == null
                                ? AppTheme.textSecondary
                                : (_isEditingBank
                                    ? AppTheme.textPrimary
                                    : AppTheme.textSecondary),
                            fontSize: AppConstants.kDefaultSubtitleFontSize,
                          ),
                        ),
                      ),
                      if (_isEditingBank)
                        const Icon(Icons.arrow_drop_down,
                            color: AppTheme.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _nameCtrl,
                style: TextStyle(
                    color: _isEditingBank
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: AppConstants.kDefaultSubtitleFontSize),
                readOnly: !_isEditingBank,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Account Holder Name',
                  prefixIcon: Icon(Icons.person_outline,
                      color: _isEditingBank
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      size: 18),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  floatingLabelStyle: const TextStyle(color: AppTheme.brand),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.kDefaultBorderRadius),
                      borderSide: BorderSide(
                          color: _isEditingBank
                              ? AppTheme.textSecondary
                              : AppTheme.divider)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.kDefaultBorderRadius),
                      borderSide:
                          const BorderSide(color: AppTheme.brand, width: 2)),
                  filled: true,
                  fillColor: _isEditingBank
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.02),
                ),
                onChanged: (v) => _bloc.add(AccountHolderNameChanged(v)),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _ibanCtrl,
                style: TextStyle(
                    color: _isEditingBank
                        ? AppTheme.textPrimary
                        : AppTheme.textSecondary,
                    fontSize: AppConstants.kDefaultSubtitleFontSize),
                readOnly: !_isEditingBank,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
                inputFormatters: [EgyptianIbanFormatter()],
                decoration: InputDecoration(
                  labelText: 'Account Number / IBAN',
                  prefixIcon: Icon(Icons.numbers_outlined,
                      color: _isEditingBank
                          ? AppTheme.textPrimary
                          : AppTheme.textSecondary,
                      size: 18),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 18),
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  floatingLabelStyle: const TextStyle(color: AppTheme.brand),
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.kDefaultBorderRadius),
                      borderSide: BorderSide(
                          color: _isEditingBank
                              ? AppTheme.textSecondary
                              : AppTheme.divider)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                          AppConstants.kDefaultBorderRadius),
                      borderSide:
                          const BorderSide(color: AppTheme.brand, width: 2)),
                  filled: true,
                  fillColor: _isEditingBank
                      ? Colors.transparent
                      : Colors.white.withValues(alpha: 0.02),
                ),
                onChanged: (v) => _bloc.add(IbanChanged(v)),
              ),
              if (_isEditingBank && hasIbanError)
                const Padding(
                  padding: EdgeInsets.only(top: 8, left: 12),
                  child: Text('Invalid Egyptian IBAN (Must be EG + 27 digits)',
                      style: TextStyle(color: AppTheme.error, fontSize: 12)),
                ),
              const SizedBox(height: 30),
              SolidConfirmButton(
                label: _isEditingBank
                    ? (isSubmitting ? 'Submitting...' : 'Save Banking Details')
                    : context.l10n.edit,
                icon: _isEditingBank
                    ? (isSubmitting ? Icons.hourglass_empty : Icons.check)
                    : Icons.edit_outlined,
                height: AppConstants.kDefaultButtonHeightLarge,
                onPressed: () {
                  if (_isEditingBank) {
                    if (isValid) {
                      HapticFeedback.selectionClick();
                      _bloc.add(const SubmitBankingDetails());
                    } else {
                      HapticFeedback.heavyImpact();
                      AppUtils.showToast(
                          context, 'Please complete all valid banking details');
                    }
                  } else {
                    HapticFeedback.selectionClick();
                    setState(() => _isEditingBank = true);
                  }
                },
              ),
              if (_isEditingBank) ...[
                const SizedBox(height: 12),
                OutlineActionButton(
                  label: context.l10n.cancel,
                  height: AppConstants.kDefaultButtonHeightLarge,
                  textColor: AppTheme.textSecondary,
                  borderColor: AppTheme.divider,
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    _nameCtrl.text = appState.bankAccount['account'] ?? '';
                    final existingIban = appState.bankAccount['iban'] ?? '';
                    _ibanCtrl.text = existingIban
                        .replaceAllMapped(
                            RegExp(r".{4}"), (match) => "${match.group(0)} ")
                        .trim();
                    _bloc.add(AccountHolderNameChanged(_nameCtrl.text));
                    _bloc.add(IbanChanged(existingIban));
                    final existingBankName = appState.bankAccount['bank'];
                    if (existingBankName != null &&
                        existingBankName.isNotEmpty) {
                      try {
                        final existingBank = egyptianBanksList
                            .firstWhere((b) => b.name == existingBankName);
                        _bloc.add(BankSelected(existingBank));
                      } catch (_) {}
                    }
                    setState(() => _isEditingBank = false);
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
