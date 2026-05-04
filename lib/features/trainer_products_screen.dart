import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/c_ui_theme.dart';
import '../core/c_constants.dart';
import '../core/c_core_utils.dart';
import '../core/c_custom_controls.dart';

// =============================================================================
// PRODUCT MODEL
// =============================================================================
class _Product {
  String category;
  String name;
  double price;
  double? oldPrice;
  String icon;
  int stock;

  _Product({
    required this.category,
    required this.name,
    required this.price,
    this.oldPrice,
    required this.icon,
    required this.stock,
  });

  Map<String, dynamic> toMap() => {
        'category': category,
        'name': name,
        'price': price,
        if (oldPrice != null) 'oldPrice': oldPrice,
        'icon': icon,
        'stock': stock,
      };
}

// =============================================================================
// PRODUCTS SCREEN
// =============================================================================
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchCtrl = TextEditingController();
  bool _searchActive = false;
  String _query = '';

  // ---- catalogue ----
  final List<String> _categories = ['Fashion', 'Supplements', 'Discounts'];
  final List<_Product> _products = [
    _Product(
        category: 'Fashion',
        name: 'Compression Tee',
        price: 29.99,
        icon: 'checkroom',
        stock: 14),
    _Product(
        category: 'Fashion',
        name: 'Gym Shorts V2',
        price: 34.50,
        icon: 'dry_cleaning',
        stock: 8),
    _Product(
        category: 'Fashion',
        name: 'Lifting Belt',
        price: 45.00,
        icon: 'fitness_center',
        stock: 3),
    _Product(
        category: 'Fashion',
        name: 'Wrist Wraps',
        price: 15.00,
        icon: 'back_hand',
        stock: 22),
    _Product(
        category: 'Supplements',
        name: 'Whey Isolate',
        price: 49.99,
        icon: 'local_drink',
        stock: 6),
    _Product(
        category: 'Supplements',
        name: 'Pre-Workout',
        price: 39.99,
        icon: 'bolt',
        stock: 4),
    _Product(
        category: 'Supplements',
        name: 'Creatine Mono',
        price: 24.99,
        icon: 'science',
        stock: 18),
    _Product(
        category: 'Supplements',
        name: 'BCAA Plus',
        price: 29.99,
        icon: 'opacity',
        stock: 11),
    _Product(
        category: 'Supplements',
        name: 'Fish Oil',
        price: 19.99,
        icon: 'water_drop',
        stock: 30),
    _Product(
        category: 'Discounts',
        name: 'Coaching Month',
        price: 89.00,
        oldPrice: 120.00,
        icon: 'card_giftcard',
        stock: 99),
    _Product(
        category: 'Discounts',
        name: 'Diet Plan PDF',
        price: 14.99,
        oldPrice: 30.00,
        icon: 'picture_as_pdf',
        stock: 99),
  ];

  static const Map<String, Color> _categoryColors = {
    'Fashion': AppTheme.cardBlue,
    'Supplements': AppTheme.cardGreen,
    'Discounts': AppTheme.cardRed,
  };

  static const Map<String, IconData> _categoryIcons = {
    'Fashion': Icons.checkroom_outlined,
    'Supplements': Icons.science_outlined,
    'Discounts': Icons.local_offer_outlined,
  };

  static IconData _icon(String name) {
    const map = {
      'checkroom': Icons.checkroom,
      'dry_cleaning': Icons.dry_cleaning,
      'fitness_center': Icons.fitness_center,
      'back_hand': Icons.back_hand,
      'local_drink': Icons.local_drink,
      'bolt': Icons.bolt,
      'science': Icons.science,
      'opacity': Icons.opacity,
      'water_drop': Icons.water_drop,
      'card_giftcard': Icons.card_giftcard,
      'picture_as_pdf': Icons.picture_as_pdf,
    };
    return map[name] ?? Icons.shopping_bag;
  }

  // ---- computed ----
  List<_Product> get _filtered {
    if (_query.isEmpty) return _products;
    final q = _query.toLowerCase();
    return _products
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.category.toLowerCase().contains(q))
        .toList();
  }

  List<_Product> _categoryProducts(String cat) =>
      _products.where((p) => p.category == cat).toList();

  int get _totalStock => _products.fold(0, (s, p) => s + p.stock);
  int get _totalListings => _products.length;
  double get _totalValue =>
      _products.fold(0.0, (s, p) => s + p.price * p.stock);
  List<_Product> get _lowStockProducts =>
      _products.where((p) => p.stock > 0 && p.stock <= 5).toList();
  List<_Product> get _outOfStockProducts =>
      _products.where((p) => p.stock == 0).toList();

  int _discountPercent(_Product p) {
    if (p.oldPrice == null) return 0;
    return ((1 - p.price / p.oldPrice!) * 100).round();
  }

  // ---- add / edit sheet ----
  void _showProductForm({_Product? editing}) {
    HapticFeedback.lightImpact();

    final nameCtrl = TextEditingController(text: editing?.name ?? '');
    final priceCtrl = TextEditingController(
        text: editing != null ? editing.price.toStringAsFixed(2) : '');
    final oldPriceCtrl = TextEditingController(
        text: editing?.oldPrice?.toStringAsFixed(2) ?? '');
    final stockCtrl =
        TextEditingController(text: editing?.stock.toString() ?? '');
    String selectedCategory = editing?.category ?? _categories.first;
    String selectedIcon = editing?.icon ?? 'shopping_bag';

    const icons = [
      'checkroom',
      'dry_cleaning',
      'fitness_center',
      'back_hand',
      'local_drink',
      'bolt',
      'science',
      'opacity',
      'water_drop',
      'card_giftcard',
      'picture_as_pdf',
      'shopping_bag',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          bool isValid() =>
              nameCtrl.text.trim().isNotEmpty &&
              (double.tryParse(priceCtrl.text) ?? -1) > 0 &&
              (int.tryParse(stockCtrl.text) ?? -1) >= 0;

          return Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.divider,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Text(
                        editing == null ? 'Add Product' : 'Edit Product',
                        style: const TextStyle(
                            color: AppTheme.brand,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (editing != null)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: AppTheme.error),
                          tooltip: 'Delete product',
                          onPressed: () {
                            HapticFeedback.heavyImpact();
                            showDialog(
                              context: ctx,
                              builder: (dCtx) => AlertDialog(
                                backgroundColor: AppTheme.surface,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.kDefaultBorderRadius)),
                                title: const Text('Delete product?',
                                    style: TextStyle(
                                        color: AppTheme.textPrimary,
                                        fontSize:
                                            AppConstants.kDefaultTitleFontSize,
                                        fontWeight: FontWeight.bold)),
                                content: Text(
                                  'This will permanently remove "${editing.name}" from your catalogue.',
                                  style: const TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: AppConstants
                                          .kDefaultSubtitleFontSize),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dCtx),
                                    child: const Text('Cancel',
                                        style: TextStyle(
                                            color: AppTheme.textSecondary)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      HapticFeedback.selectionClick();
                                      setState(() => _products.remove(editing));
                                      Navigator.pop(dCtx);
                                      Navigator.pop(ctx);
                                      AppUtils.showToast(
                                          context, '${editing.name} removed.');
                                    },
                                    child: const Text('Delete',
                                        style: TextStyle(
                                            color: AppTheme.error,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Category picker
                  const Text('Category',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((cat) {
                        final sel = selectedCategory == cat;
                        final color = _categoryColors[cat] ?? AppTheme.brand;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setModal(() => selectedCategory = cat);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: sel
                                  ? color.withValues(alpha: 0.15)
                                  : Colors.white.withValues(alpha: 0.03),
                              border: Border.all(
                                  color: sel ? color : AppTheme.divider,
                                  width: sel ? 1.5 : 1),
                              borderRadius: BorderRadius.circular(
                                  AppConstants.kDefaultBorderRadius),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_categoryIcons[cat] ?? Icons.category,
                                    size: 15,
                                    color:
                                        sel ? color : AppTheme.textSecondary),
                                const SizedBox(width: 6),
                                Text(cat,
                                    style: TextStyle(
                                        color: sel
                                            ? color
                                            : AppTheme.textSecondary,
                                        fontWeight: sel
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 13)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Icon picker
                  const Text('Icon',
                      style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: icons.map((ic) {
                      final sel = selectedIcon == ic;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setModal(() => selectedIcon = ic);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: sel
                                ? AppTheme.brand.withValues(alpha: 0.12)
                                : Colors.white.withValues(alpha: 0.03),
                            border: Border.all(
                                color: sel ? AppTheme.brand : AppTheme.divider,
                                width: sel ? 1.5 : 1),
                            borderRadius: BorderRadius.circular(
                                AppConstants.kDefaultBorderRadius),
                          ),
                          child: Icon(_icon(ic),
                              size: 20,
                              color: sel
                                  ? AppTheme.brand
                                  : AppTheme.textSecondary),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Name
                  _FormField(
                      label: 'Product Name',
                      child: TextField(
                        controller: nameCtrl,
                        onChanged: (_) => setModal(() {}),
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppConstants.kDefaultSubtitleFontSize),
                        decoration: _inputDeco('e.g. Whey Protein'),
                      )),
                  const SizedBox(height: 14),

                  // Price + Old Price row
                  Row(
                    children: [
                      Expanded(
                          child: _FormField(
                              label: 'Price (USD)',
                              child: TextField(
                                controller: priceCtrl,
                                onChanged: (_) => setModal(() {}),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  NumberBoundsFormatter(
                                      maxWholeDigits: 6, maxDecimalDigits: 2)
                                ],
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize:
                                        AppConstants.kDefaultSubtitleFontSize),
                                decoration: _inputDeco('0.00'),
                              ))),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _FormField(
                              label: 'Original Price (optional)',
                              child: TextField(
                                controller: oldPriceCtrl,
                                onChanged: (_) => setModal(() {}),
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                        decimal: true),
                                inputFormatters: [
                                  NumberBoundsFormatter(
                                      maxWholeDigits: 6, maxDecimalDigits: 2)
                                ],
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontSize:
                                        AppConstants.kDefaultSubtitleFontSize),
                                decoration: _inputDeco('for discount badge'),
                              ))),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Stock
                  _FormField(
                      label: 'Stock Quantity',
                      child: TextField(
                        controller: stockCtrl,
                        onChanged: (_) => setModal(() {}),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          NumberBoundsFormatter(
                              maxWholeDigits: 5, maxDecimalDigits: 0)
                        ],
                        style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppConstants.kDefaultSubtitleFontSize),
                        decoration: _inputDeco('e.g. 50'),
                      )),
                  const SizedBox(height: 28),

                  SolidConfirmButton(
                    label:
                        editing == null ? 'Add to Catalogue' : 'Save Changes',
                    height: AppConstants.kDefaultButtonHeightLarge,
                    onPressed: isValid()
                        ? () {
                            HapticFeedback.selectionClick();
                            final name = nameCtrl.text.trim();
                            final price = double.parse(priceCtrl.text);
                            final oldPriceRaw =
                                double.tryParse(oldPriceCtrl.text);
                            final oldPrice =
                                (oldPriceRaw != null && oldPriceRaw > price)
                                    ? oldPriceRaw
                                    : null;
                            final stock = int.parse(stockCtrl.text);

                            setState(() {
                              if (editing == null) {
                                _products.add(_Product(
                                  category: selectedCategory,
                                  name: name,
                                  price: price,
                                  oldPrice: oldPrice,
                                  icon: selectedIcon,
                                  stock: stock,
                                ));
                              } else {
                                editing.category = selectedCategory;
                                editing.name = name;
                                editing.price = price;
                                editing.oldPrice = oldPrice;
                                editing.icon = selectedIcon;
                                editing.stock = stock;
                              }
                            });
                            Navigator.pop(ctx);
                            AppUtils.showToast(
                                context,
                                editing == null
                                    ? '$name added.'
                                    : '$name updated.');
                          }
                        : null,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---- product detail / manage sheet ----
  void _showProductDetail(_Product product) {
    HapticFeedback.lightImpact();
    final color = _categoryColors[product.category] ?? AppTheme.brand;
    final discount = _discountPercent(product);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) {
          final stock = product.stock;

          return Padding(
            padding:
                EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: AppTheme.divider,
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Icon hero
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(_icon(product.icon), color: color, size: 44),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Category pill
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(product.category,
                        style: TextStyle(
                            color: color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 8),
                  Text(product.name,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('\$${product.price.toStringAsFixed(2)}',
                          style: TextStyle(
                              color: color,
                              fontSize: 26,
                              fontWeight: FontWeight.bold)),
                      if (product.oldPrice != null) ...[
                        const SizedBox(width: 10),
                        Text('\$${product.oldPrice!.toStringAsFixed(2)}',
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 16,
                                decoration: TextDecoration.lineThrough)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                              color: AppTheme.cardRed.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6)),
                          child: Text('$discount% OFF',
                              style: const TextStyle(
                                  color: AppTheme.cardRed,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: AppTheme.divider, height: 1),
                  const SizedBox(height: 16),

                  // Stock info + inline adjuster
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Stock',
                              style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8)),
                          const SizedBox(height: 6),
                          _StockBadge(stock: stock),
                        ],
                      ),
                      const Spacer(),
                      // Quick stock adjuster
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.divider),
                            borderRadius: BorderRadius.circular(
                                AppConstants.kDefaultBorderRadius)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _StepperBtn(
                              icon: Icons.remove,
                              onTap: product.stock <= 0
                                  ? null
                                  : () {
                                      setState(() => product.stock--);
                                      setModal(() {});
                                    },
                            ),
                            SizedBox(
                              width: 42,
                              child: Text('${product.stock}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                            _StepperBtn(
                              icon: Icons.add,
                              onTap: () {
                                setState(() => product.stock++);
                                setModal(() {});
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: AppTheme.divider, height: 1),
                  const SizedBox(height: 20),

                  // Revenue estimate row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.03),
                      border: Border.all(color: AppTheme.divider),
                      borderRadius: BorderRadius.circular(
                          AppConstants.kDefaultBorderRadius),
                    ),
                    child: Row(
                      children: [
                        _StatMini(
                            label: 'Unit Price',
                            value: '\$${product.price.toStringAsFixed(2)}'),
                        _dividerV(),
                        _StatMini(
                            label: 'Stock', value: '${product.stock} units'),
                        _dividerV(),
                        _StatMini(
                            label: 'Potential Revenue',
                            value:
                                '\$${(product.price * product.stock).toStringAsFixed(2)}',
                            highlight: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlineActionButton(
                          label: 'Edit Product',
                          icon: const Icon(Icons.edit_outlined,
                              color: AppTheme.brand, size: 18),
                          height: AppConstants.kDefaultButtonHeightLarge,
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showProductForm(editing: product);
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SolidConfirmButton(
                          label: 'Close',
                          height: AppConstants.kDefaultButtonHeightLarge,
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ---- all products sheet ----
  void _showAllProducts(String category) {
    final color = _categoryColors[category]!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scroll) => StatefulBuilder(
          builder: (ctx, setModal) {
            final products = _categoryProducts(category);
            return ListView(
              controller: scroll,
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: AppTheme.divider,
                            borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(10)),
                      child: Icon(_categoryIcons[category] ?? Icons.category,
                          color: color, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category,
                              style: const TextStyle(
                                  color: AppTheme.brand,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold)),
                          Text('${products.length} products',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary, fontSize: 12)),
                        ]),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline,
                          color: AppTheme.brand),
                      tooltip: 'Add to $category',
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showProductForm();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(color: AppTheme.divider, height: 1),
                const SizedBox(height: 8),
                ...products.map((p) {
                  final outOfStock = p.stock == 0;
                  final discount = _discountPercent(p);
                  return Column(children: [
                    InkWell(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(ctx);
                        _showProductDetail(p);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: outOfStock
                                  ? AppTheme.divider
                                  : color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(_icon(p.icon),
                                color:
                                    outOfStock ? AppTheme.textSecondary : color,
                                size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(p.name,
                                    style: TextStyle(
                                        color: outOfStock
                                            ? AppTheme.textSecondary
                                            : AppTheme.textPrimary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                const SizedBox(height: 4),
                                _StockBadge(stock: p.stock, compact: true),
                              ])),
                          Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(mainAxisSize: MainAxisSize.min, children: [
                                  if (discount > 0) ...[
                                    Container(
                                      margin: const EdgeInsets.only(right: 6),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: AppTheme.cardRed
                                              .withValues(alpha: 0.12),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Text('-$discount%',
                                          style: const TextStyle(
                                              color: AppTheme.cardRed,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                  Text('\$${p.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                          color: outOfStock
                                              ? AppTheme.textSecondary
                                              : color,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15)),
                                ]),
                                if (p.oldPrice != null)
                                  Text('\$${p.oldPrice!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 11,
                                          decoration:
                                              TextDecoration.lineThrough)),
                              ]),
                          const SizedBox(width: 8),
                          const Icon(Icons.chevron_right,
                              color: AppTheme.textSecondary, size: 18),
                        ]),
                      ),
                    ),
                    const Divider(color: AppTheme.divider, height: 1),
                  ]);
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  // ---- alerts sheet ----
  void _showAlertsSheet() {
    HapticFeedback.lightImpact();
    final lowStock = _lowStockProducts;
    final outOfStock = _outOfStockProducts;
    if (lowStock.isEmpty && outOfStock.isEmpty) {
      AppUtils.showToast(context, 'All products are well stocked.');
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.35,
        maxChildSize: 0.85,
        expand: false,
        builder: (_, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.divider,
                        borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            const Text('Stock Alerts',
                style: TextStyle(
                    color: AppTheme.brand,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
                '${lowStock.length + outOfStock.length} products need attention',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
            const SizedBox(height: 20),
            const Divider(color: AppTheme.divider, height: 1),
            if (outOfStock.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Out of Stock',
                  style: TextStyle(
                      color: AppTheme.error,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
              const SizedBox(height: 10),
              ...outOfStock.map((p) => _AlertTile(
                  product: p,
                  color: AppTheme.error,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showProductDetail(p);
                  })),
            ],
            if (lowStock.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Low Stock',
                  style: TextStyle(
                      color: AppTheme.cardYellow,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8)),
              const SizedBox(height: 10),
              ...lowStock.map((p) => _AlertTile(
                  product: p,
                  color: AppTheme.cardYellow,
                  onTap: () {
                    Navigator.pop(ctx);
                    _showProductDetail(p);
                  })),
            ],
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _searchCtrl
        .addListener(() => setState(() => _query = _searchCtrl.text.trim()));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertCount = _lowStockProducts.length + _outOfStockProducts.length;
    final filteredProducts = _filtered;
    final Map<String, List<_Product>> filteredByCategory = {
      for (final cat in _categories)
        if (filteredProducts.any((p) => p.category == cat))
          cat: filteredProducts.where((p) => p.category == cat).toList(),
    };

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        title: _searchActive
            ? TextField(
                controller: _searchCtrl,
                autofocus: true,
                style:
                    const TextStyle(color: AppTheme.textPrimary, fontSize: 16),
                cursorColor: AppTheme.brand,
                decoration: InputDecoration(
                  hintText: 'Search products…',
                  hintStyle: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 16),
                  border: InputBorder.none,
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppTheme.textSecondary, size: 20),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                ),
              )
            : Text(context.l10n.productsAndOffers,
                style: const TextStyle(color: AppTheme.brand)),
        actions: [
          if (!_searchActive) ...[
            IconButton(
              icon: const Icon(Icons.search, color: AppTheme.textPrimary),
              onPressed: () {
                HapticFeedback.lightImpact();
                setState(() => _searchActive = true);
              },
            ),
            // Stock alert bell
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: AppTheme.textPrimary),
                  tooltip: 'Stock alerts',
                  onPressed: _showAlertsSheet,
                ),
                if (alertCount > 0)
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      width: 18,
                      height: 18,
                      decoration: const BoxDecoration(
                          color: AppTheme.error, shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(alertCount > 99 ? '99+' : '$alertCount',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.brand),
              tooltip: 'Add Product',
              onPressed: () => _showProductForm(),
            ),
          ],
          if (_searchActive)
            TextButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                _searchCtrl.clear();
                setState(() {
                  _searchActive = false;
                  _query = '';
                });
              },
              child: const Text('Cancel',
                  style: TextStyle(color: AppTheme.brand, fontSize: 14)),
            ),
        ],
      ),
      body: Column(
        children: [
          // ---- Summary header (hidden during search) ----
          if (!_searchActive)
            _InventorySummaryBar(
              totalListings: _totalListings,
              totalStock: _totalStock,
              totalValue: _totalValue,
              alertCount: alertCount,
              onAlertTap: _showAlertsSheet,
            ),

          // ---- Product list ----
          Expanded(
            child: _products.isEmpty
                ? _EmptyState(onAdd: () => _showProductForm())
                : filteredByCategory.isEmpty
                    ? _SearchEmptyState(
                        query: _query,
                        onClear: () {
                          _searchCtrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 8, bottom: 32),
                        children: filteredByCategory.entries.map((entry) {
                          final cat = entry.key;
                          final catProducts = entry.value;
                          final color = _categoryColors[cat]!;
                          final display = catProducts.take(3).toList();
                          final totalInCat = _categoryProducts(cat).length;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Category header
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(20, 20, 20, 14),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                            color:
                                                color.withValues(alpha: 0.12),
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        child: Icon(
                                            _categoryIcons[cat] ??
                                                Icons.category,
                                            color: color,
                                            size: 16),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(cat,
                                          style: const TextStyle(
                                              color: AppTheme.textPrimary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.3)),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Text('$totalInCat',
                                            style: TextStyle(
                                                color: color,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ]),
                                    if (totalInCat > 3)
                                      TextButton(
                                        onPressed: () {
                                          HapticFeedback.lightImpact();
                                          _showAllProducts(cat);
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          minimumSize: Size.zero,
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text(
                                          context.l10n.viewAllCount(
                                              totalInCat.toString()),
                                          style: TextStyle(
                                              color: color,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              // Grid
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.85,
                                  ),
                                  itemCount: display.length,
                                  itemBuilder: (ctx, i) => _ProductCard(
                                    product: display[i],
                                    accentColor: color,
                                    iconData: _icon(display[i].icon),
                                    discountPercent:
                                        _discountPercent(display[i]),
                                    onTap: () => _showProductDetail(display[i]),
                                  ),
                                ),
                              ),
                              // Add to category CTA (only when showing < all)
                              if (totalInCat <= 3)
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 0),
                                  child: InkWell(
                                    onTap: () {
                                      HapticFeedback.lightImpact();
                                      _showProductForm();
                                    },
                                    borderRadius: BorderRadius.circular(
                                        AppConstants.kDefaultBorderRadius),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 14),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color:
                                                color.withValues(alpha: 0.25),
                                            width: 1.5),
                                        borderRadius: BorderRadius.circular(
                                            AppConstants.kDefaultBorderRadius),
                                        color: color.withValues(alpha: 0.04),
                                      ),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.add,
                                                color: color, size: 18),
                                            const SizedBox(width: 8),
                                            Text('Add to $cat',
                                                style: TextStyle(
                                                    color: color,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13)),
                                          ]),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 16),
                              const Divider(color: AppTheme.divider, height: 1),
                            ],
                          );
                        }).toList(),
                      ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: AppConstants.kDefaultSubtitleFontSize),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.02),
        enabledBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide:
              const BorderSide(color: AppTheme.textSecondary, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
          borderSide: const BorderSide(color: AppTheme.brand, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      );
}

// =============================================================================
// INVENTORY SUMMARY BAR
// =============================================================================
class _InventorySummaryBar extends StatelessWidget {
  final int totalListings;
  final int totalStock;
  final double totalValue;
  final int alertCount;
  final VoidCallback onAlertTap;

  const _InventorySummaryBar({
    required this.totalListings,
    required this.totalStock,
    required this.totalValue,
    required this.alertCount,
    required this.onAlertTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        border: Border.all(color: AppTheme.divider),
        borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
      ),
      child: Row(
        children: [
          Expanded(
              child: _StatMini(label: 'Listings', value: '$totalListings')),
          _dividerV(),
          Expanded(
              child: _StatMini(label: 'Total Units', value: '$totalStock')),
          _dividerV(),
          Expanded(
              child: _StatMini(
                  label: 'Stock Value',
                  value: '\$${totalValue.toStringAsFixed(0)}',
                  highlight: true)),
          if (alertCount > 0) ...[
            _dividerV(),
            Expanded(
              child: GestureDetector(
                onTap: onAlertTap,
                child: Column(children: [
                  Text('$alertCount',
                      style: const TextStyle(
                          color: AppTheme.error,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  const Text('Alerts',
                      style: TextStyle(color: AppTheme.error, fontSize: 11)),
                ]),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// =============================================================================
// PRODUCT CARD  (2-column grid)
// =============================================================================
class _ProductCard extends StatelessWidget {
  final _Product product;
  final Color accentColor;
  final IconData iconData;
  final int discountPercent;
  final VoidCallback onTap;

  const _ProductCard({
    required this.product,
    required this.accentColor,
    required this.iconData,
    required this.discountPercent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final outOfStock = product.stock == 0;
    final lowStock = product.stock > 0 && product.stock <= 5;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: outOfStock
                  ? AppTheme.error.withValues(alpha: 0.3)
                  : AppTheme.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon area
            Expanded(
              flex: 5,
              child: Stack(children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: outOfStock
                        ? AppTheme.bg
                        : accentColor.withValues(alpha: 0.07),
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  child: Center(
                      child: Icon(iconData,
                          size: 36,
                          color: outOfStock
                              ? AppTheme.textSecondary
                              : accentColor)),
                ),
                if (discountPercent > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                          color: AppTheme.cardRed,
                          borderRadius: BorderRadius.circular(5)),
                      child: Text('-$discountPercent%',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                if (outOfStock)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.bg.withValues(alpha: 0.6),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(12)),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(
                                color: AppTheme.error.withValues(alpha: 0.4))),
                        child: const Text('SOLD OUT',
                            style: TextStyle(
                                color: AppTheme.error,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5)),
                      ),
                    ),
                  ),
                // Edit shortcut
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                        color: AppTheme.surface.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppTheme.divider)),
                    child: const Icon(Icons.edit_outlined,
                        size: 14, color: AppTheme.textSecondary),
                  ),
                ),
              ]),
            ),
            // Info
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(product.name,
                        style: TextStyle(
                            color: outOfStock
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('\$${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                        color: outOfStock
                                            ? AppTheme.textSecondary
                                            : accentColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold)),
                                if (product.oldPrice != null) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                      '\$${product.oldPrice!.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                          color: AppTheme.textSecondary,
                                          fontSize: 10,
                                          decoration:
                                              TextDecoration.lineThrough)),
                                ],
                              ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 11,
                                color: lowStock
                                    ? AppTheme.cardYellow
                                    : (outOfStock
                                        ? AppTheme.error
                                        : AppTheme.textSecondary)),
                            const SizedBox(width: 4),
                            Text('${product.stock} units',
                                style: TextStyle(
                                  color: lowStock
                                      ? AppTheme.cardYellow
                                      : (outOfStock
                                          ? AppTheme.error
                                          : AppTheme.textSecondary),
                                  fontSize: 11,
                                  fontWeight: (lowStock || outOfStock)
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                )),
                          ]),
                        ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// HELPERS & SMALL WIDGETS
// =============================================================================

class _FormField extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.toUpperCase(),
          style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8)),
      const SizedBox(height: 8),
      child,
    ]);
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  const _StatMini(
      {required this.label, required this.value, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              color: highlight ? AppTheme.brand : AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
    ]);
  }
}

Widget _dividerV() => Container(
    width: 1,
    height: 36,
    color: AppTheme.divider,
    margin: const EdgeInsets.symmetric(horizontal: 8));

class _AlertTile extends StatelessWidget {
  final _Product product;
  final Color color;
  final VoidCallback onTap;
  const _AlertTile(
      {required this.product, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(AppConstants.kDefaultBorderRadius),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          border: Border.all(color: color.withValues(alpha: 0.25)),
          borderRadius:
              BorderRadius.circular(AppConstants.kDefaultBorderRadius),
        ),
        child: Row(children: [
          Icon(Icons.warning_amber_rounded, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(product.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
                Text('${product.stock} units remaining · ${product.category}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ])),
          const Icon(Icons.chevron_right,
              color: AppTheme.textSecondary, size: 18),
        ]),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.shopping_bag_outlined,
              color: AppTheme.textSecondary, size: 56),
          const SizedBox(height: 16),
          const Text('No products yet',
              style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Add your first product to start selling.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppTheme.textSecondary, fontSize: 14, height: 1.5)),
          const SizedBox(height: 24),
          SolidConfirmButton(
              label: 'Add First Product',
              icon: Icons.add,
              height: AppConstants.kDefaultButtonHeightLarge,
              onPressed: onAdd),
        ]),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  final String query;
  final VoidCallback onClear;
  const _SearchEmptyState({required this.query, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.search_off_rounded,
              color: AppTheme.textSecondary, size: 48),
          const SizedBox(height: 16),
          Text('No results for "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Try a different product name or category.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 24),
          OutlineActionButton(
              label: 'Clear Search',
              height: AppConstants.kDefaultButtonHeightLarge,
              onPressed: onClear),
        ]),
      ),
    );
  }
}

class _StepperBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const size = 22.0;
    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.selectionClick();
              onTap!();
            }
          : null,
      child: SizedBox(
        width: size + 12,
        height: size + 12,
        child: Icon(icon,
            size: size - 4,
            color: onTap == null ? AppTheme.divider : AppTheme.textPrimary),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  final int stock;
  final bool compact;

  const _StockBadge({required this.stock, this.compact = false});

  @override
  Widget build(BuildContext context) {
    if (stock == 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: AppTheme.cardRed.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4)),
        child: const Text('Out of stock',
            style: TextStyle(
                color: AppTheme.cardRed,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
    }
    if (stock <= 5) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
            color: AppTheme.cardYellow.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4)),
        child: Text('Low · $stock left',
            style: const TextStyle(
                color: AppTheme.cardYellow,
                fontSize: 11,
                fontWeight: FontWeight.bold)),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: AppTheme.cardGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4)),
      child: Text(compact ? 'In stock · $stock' : 'In stock · $stock units',
          style: const TextStyle(
              color: AppTheme.cardGreen,
              fontSize: 11,
              fontWeight: FontWeight.bold)),
    );
  }
}
