import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_paths.dart';

class RecipeCopilotScreen extends ConsumerStatefulWidget {
  const RecipeCopilotScreen({super.key});

  @override
  ConsumerState<RecipeCopilotScreen> createState() =>
      _RecipeCopilotScreenState();
}

class _RecipeCopilotScreenState extends ConsumerState<RecipeCopilotScreen>
    with SingleTickerProviderStateMixin {
  int _selectedBatchSize = 100;
  bool _isStepsExpanded = false;
  bool _isGenerating = false;
  bool _isGeneratedSuccess = false;
  bool _isSaved = false;

  late AnimationController _pulseController;

  final List<Map<String, dynamic>> _ingredients = [
    {
      'name': 'Tofu',
      'qty': '15kg',
      'icon': Icons.egg_alt_rounded,
      'isExpiring': false,
    },
    {
      'name': 'Carrots',
      'qty': '8kg',
      'icon': Icons.eco_rounded,
      'isExpiring': false,
      'color': Color(0xFFFEA619),
    },
    {
      'name': 'Cabbage',
      'qty': '20kg',
      'icon': Icons.alarm_rounded,
      'isExpiring': true,
      'expiry': 'Expiring 4h',
    },
    {
      'name': 'Brown Rice',
      'qty': '25kg',
      'icon': Icons.grain_rounded,
      'isExpiring': false,
    },
    {
      'name': 'Shiitake',
      'qty': '5kg',
      'icon': Icons.forest_rounded,
      'isExpiring': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleGenerateMenu() {
    setState(() {
      _isGenerating = true;
      _isGeneratedSuccess = false;
    });

    Future.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() {
          _isGenerating = false;
          _isGeneratedSuccess = true;
        });

        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() {
              _isGeneratedSuccess = false;
            });
          }
        });
      }
    });
  }

  void _handleSaveMenu() {
    setState(() {
      _isSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.download_done, color: Colors.white),
            SizedBox(width: 8),
            Text('Checklist Saved & Dispatched to Da Nang Charity Hub #04!'),
          ],
        ),
        backgroundColor: Color(0xFF006B2C),
        duration: Duration(seconds: 2),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isSaved = false;
        });
      }
    });
  }

  void _addNewIngredient() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Thêm Nguyên Liệu Cứu Trợ',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: TextField(
            controller: textController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: Pumpkins 10kg, Bí đỏ 10kg',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006B2C),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final text = textController.text.trim();
                if (text.isNotEmpty) {
                  setState(() {
                    _ingredients.add({
                      'name': text,
                      'qty': '',
                      'icon': Icons.eco_rounded,
                      'isExpiring': false,
                    });
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Thêm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tailwind Design Tokens
    const bgSurface = Color(0xFFFAF8FF);
    const surfaceLowest = Color(0xFFFFFFFF);
    const surfaceLow = Color(0xFFF2F3FF);
    const surfaceContainer = Color(0xFFEAEDFF);
    const surfaceHigh = Color(0xFFE2E7FF);
    const surfaceHighest = Color(0xFFDAE2FD);
    const primary = Color(0xFF006B2C);
    const primaryContainer = Color(0xFF00873A);
    const primaryFixed = Color(0xFF7FFC97);
    const secondary = Color(0xFF855300);
    const secondaryFixed = Color(0xFFFFDDB8);
    const onSecondaryFixed = Color(0xFF2A1700);
    const tertiary = Color(0xFFB61722);
    const tertiaryContainer = Color(0xFFDA3437);
    const onSurface = Color(0xFF131B2E);
    const onSurfaceVariant = Color(0xFF3E4A3D);

    return Scaffold(
      backgroundColor: bgSurface,
      body: Stack(
        children: [
          // Scrollable Page Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(
              top: 110,
              bottom: 140, // space for sticky action dock + bottom bar
              left: 16,
              right: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Meta Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: primaryContainer.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.auto_awesome, size: 14, color: primary),
                          SizedBox(width: 4),
                          Text(
                            'GPT-4O ECO RESCUE ENGINE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: primary,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: surfaceHigh,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.soup_kitchen_rounded,
                              size: 14, color: primary),
                          SizedBox(width: 4),
                          Text(
                            'Hub #04 • Da Nang',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Headline
                const Text(
                  'AI Kitchen Copilot',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Optimizing high-volume charity meals (50–200 pax) with verified zero food waste.',
                  style: TextStyle(
                    fontSize: 13,
                    color: onSurfaceVariant,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 16),

                // Rescued Cold Storage Inventory Module
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surfaceLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: surfaceContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.kitchen_rounded,
                                    color: primary, size: 18),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rescued Cold Storage',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: onSurface,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(
                                          color: primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text(
                                        'Auto-synced from daily drop-offs',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '73kg Total',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Fluid Chip List
                      Wrap(
                        spacing: 6,
                        runSpacing: 8,
                        children: [
                          ..._ingredients.map((item) {
                            final isExpiring = item['isExpiring'] == true;
                            if (isExpiring) {
                              return AnimatedBuilder(
                                animation: _pulseController,
                                builder: (context, child) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: tertiaryContainer.withValues(
                                          alpha: 0.1 +
                                              (_pulseController.value * 0.1)),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(item['icon'] as IconData,
                                            size: 15, color: tertiary),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${item['name']} ',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: tertiary,
                                          ),
                                        ),
                                        Text(
                                          item['qty'] as String,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: tertiary,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: tertiary,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            item['expiry'] as String,
                                            style: const TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }

                            final isCarrot = item['name'] == 'Carrots';
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isCarrot
                                    ? secondaryFixed.withValues(alpha: 0.6)
                                    : surfaceContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    item['icon'] as IconData,
                                    size: 15,
                                    color: isCarrot ? secondary : primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${item['name']} ',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isCarrot
                                          ? onSecondaryFixed
                                          : onSurface,
                                    ),
                                  ),
                                  Text(
                                    item['qty'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isCarrot
                                          ? onSecondaryFixed
                                          : onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                          // Add Item Button
                          InkWell(
                            onTap: _addNewIngredient,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: surfaceHigh,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.add,
                                      size: 15, color: onSurfaceVariant),
                                  SizedBox(width: 4),
                                  Text(
                                    'Add item',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Batch Size Segmented Control
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.group_rounded, color: primary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Target Batch Size',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Optimized for $_selectedBatchSize beneficiaries',
                      style: const TextStyle(
                        fontSize: 11,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: surfaceContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [50, 100, 200].map((servings) {
                      final isSelected = _selectedBatchSize == servings;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedBatchSize = servings;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: primary.withValues(alpha: 0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$servings',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  'Servings',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isSelected
                                        ? Colors.white.withValues(alpha: 0.9)
                                        : onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(Icons.verified, size: 13, color: primary),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Calculates nutrition metrics, prep cadence, and eliminates landfill waste.',
                        style: TextStyle(fontSize: 11, color: onSurfaceVariant),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // AI Generate Action Button
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isGenerating ? null : _handleGenerateMenu,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isGenerating
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Optimizing Rescued Ingredients...',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : _isGeneratedSuccess
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.check_circle,
                                      color: primaryFixed, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Menu Regenerated!',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.auto_awesome, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Generate Zero-Waste Menu ✨',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                  ),
                ),

                const SizedBox(height: 20),

                // Recipe Recommendations Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.restaurant_menu_rounded,
                            color: primary, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'Curated Bulk Menus',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      '2 matches ready',
                      style: TextStyle(fontSize: 12, color: onSurfaceVariant),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // RECIPE CARD 1: BEST ZERO WASTE MATCH
                Container(
                  decoration: BoxDecoration(
                    color: surfaceLowest,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Emerald Ribbon
                      Container(
                        color: primary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.workspace_premium_rounded,
                                    color: secondaryFixed, size: 16),
                                SizedBox(width: 6),
                                Text(
                                  'Best Zero-Waste Match',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                '90% Salvage Rate',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header row: Image + Title
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        color: surfaceContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.soup_kitchen_rounded,
                                        color: primary,
                                        size: 40,
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 4,
                                      right: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4, vertical: 1),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.65),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Rescued',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Braised Tofu with Mixed Vegetables',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: onSurface,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Đậu Hũ Kho Rau Củ Chay',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: primary.withValues(alpha: 0.1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: const [
                                                Icon(Icons.schedule,
                                                    size: 11, color: primary),
                                                SizedBox(width: 2),
                                                Text(
                                                  '45m prep',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: surfaceContainer,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              children: const [
                                                Icon(Icons.savings_rounded,
                                                    size: 11, color: primary),
                                                SizedBox(width: 2),
                                                Text(
                                                  '0 VND cost',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w600,
                                                    color: onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Portion & Nutrition Grid
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: surfaceLow,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Text('Target Yield',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: onSurfaceVariant)),
                                      Text(
                                        '$_selectedBatchSize Portions',
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 24,
                                    color: const Color(0xFFBDCABA)
                                        .withValues(alpha: 0.4),
                                  ),
                                  Column(
                                    children: const [
                                      Text('Protein / Ptn',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: onSurfaceVariant)),
                                      Text(
                                        '18.5g',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    width: 1,
                                    height: 24,
                                    color: const Color(0xFFBDCABA)
                                        .withValues(alpha: 0.4),
                                  ),
                                  Column(
                                    children: const [
                                      Text('Energy',
                                          style: TextStyle(
                                              fontSize: 10,
                                              color: onSurfaceVariant)),
                                      Text(
                                        '450 kcal',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: onSurface,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Cold Storage Utilized
                            const Text(
                              'Cold Storage Utilized:',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                _buildIngredientBadge(
                                    'Tofu ${_selectedBatchSize == 50 ? '8' : _selectedBatchSize == 200 ? '15' : '15'}kg',
                                    surfaceContainer,
                                    onSurface),
                                _buildIngredientBadge(
                                    'Cabbage ${_selectedBatchSize == 50 ? '9' : _selectedBatchSize == 200 ? '20' : '18'}kg (urgent)',
                                    tertiaryContainer.withValues(alpha: 0.15),
                                    tertiary),
                                _buildIngredientBadge(
                                    'Carrots ${_selectedBatchSize == 50 ? '4' : _selectedBatchSize == 200 ? '8' : '7'}kg',
                                    secondaryFixed.withValues(alpha: 0.6),
                                    onSecondaryFixed),
                                _buildIngredientBadge(
                                    'Shiitake ${_selectedBatchSize == 50 ? '2' : _selectedBatchSize == 200 ? '5' : '4'}kg',
                                    surfaceContainer,
                                    onSurface),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // HACCP Prep Schedule Accordion
                            Material(
                              color: surfaceContainer,
                              borderRadius: BorderRadius.circular(8),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _isStepsExpanded = !_isStepsExpanded;
                                  });
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: const [
                                          Icon(Icons.checklist_rounded,
                                              size: 18, color: primary),
                                          SizedBox(width: 6),
                                          Text(
                                            'Prep Schedule & Food Safety (HACCP)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: onSurface,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Icon(
                                        _isStepsExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                                        color: onSurfaceVariant,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            if (_isStepsExpanded) ...[
                              const SizedBox(height: 10),
                              // Step 1
                              _buildHaccpStep(
                                stepNum: '1',
                                title: 'Blanch Cabbage & Dice Tofu',
                                desc:
                                    'Submerge cabbage leaves in sanitizing wash. Cube 15kg tofu into uniform 2-inch portions for fast batch searing.',
                              ),
                              const SizedBox(height: 8),
                              // Step 2
                              _buildHaccpStep(
                                stepNum: '2',
                                title: 'Bulk Simmer with Shiitake Stock',
                                desc:
                                    'Transfer into large 60L charity cooking cauldron. Add braising broth, fermented soy, and slow-cook for 30 minutes.',
                              ),
                              const SizedBox(height: 8),
                              // Step 3 (Critical Temperature Check)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: secondaryFixed.withValues(alpha: 0.35),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: const BoxDecoration(
                                        color: secondary,
                                        shape: BoxShape.circle,
                                      ),
                                      alignment: Alignment.center,
                                      child: const Text(
                                        '3',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Row(
                                            children: [
                                              Icon(Icons.thermostat_rounded,
                                                  size: 15, color: secondary),
                                              SizedBox(width: 4),
                                              Text(
                                                'Critical Temperature Verification',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold,
                                                  color: onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Check core temp exceeds 75°C (167°F) before portioning into insulated self-pickup tubs.',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF684000),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // RECIPE CARD 2: ALTERNATIVE OPTION
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surfaceLowest,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: surfaceContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.lunch_dining_rounded,
                          color: secondary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: surfaceHigh,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Option B',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  '• 75% Salvage',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: secondary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Vegetable Curry (Cà Ri Chay)',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                            ),
                            const Text(
                              'Includes 25kg steamed brown rice side',
                              style: TextStyle(
                                fontSize: 11,
                                color: onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.timer_outlined,
                                        size: 13, color: onSurfaceVariant),
                                    SizedBox(width: 2),
                                    Text(
                                      '55m Prep',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                                InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Đã chuyển sang công thức: Cà Ri Chay!'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  child: Row(
                                    children: const [
                                      Text(
                                        'Select Option',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: primary,
                                        ),
                                      ),
                                      Icon(Icons.chevron_right,
                                          size: 16, color: primary),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Environmental Delta Micro-Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: surfaceHigh.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.compost_rounded,
                            color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Environmental Delta',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                            ),
                            Text(
                              'Diverting 44kg methane emissions today',
                              style: TextStyle(
                                fontSize: 11,
                                color: onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        '-68kg CO₂e',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Sticky Action Dock (above bottom nav)
          Positioned(
            left: 0,
            right: 0,
            bottom: 64, // sits right above fixed bottom nav bar
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: bgSurface.withValues(alpha: 0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSaved ? null : _handleSaveMenu,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(_isSaved ? Icons.download_done : Icons.task_alt,
                          size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _isSaved
                            ? 'Checklist Saved & Dispatched!'
                            : 'Save Menu & Generate Checklist',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Fixed Top Header (Status bar + Logo + Location + Profile)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFixedHeader(context),
          ),

          // Fixed Bottom Navigation Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigationBar(context),
          ),
        ],
      ),
    );
  }

  Widget _buildIngredientBadge(String text, Color bg, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildHaccpStep({
    required String stepNum,
    required String title,
    required String desc,
  }) {
    const primary = Color(0xFF006B2C);
    const onSurface = Color(0xFF131B2E);
    const onSurfaceVariant = Color(0xFF3E4A3D);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNum,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 11,
                  color: onSurfaceVariant,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFixedHeader(BuildContext context) {
    const bgSurface = Color(0xFFFAF8FF);
    const onSurface = Color(0xFF131B2E);
    const onSurfaceVariant = Color(0xFF3E4A3D);
    const primary = Color(0xFF006B2C);
    const tertiaryContainer = Color(0xFFDA3437);

    return Container(
      decoration: BoxDecoration(
        color: bgSurface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Status bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    '9:41',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                  Row(
                    children: const [
                      Icon(Icons.signal_cellular_alt,
                          size: 16, color: onSurface),
                      SizedBox(width: 4),
                      Icon(Icons.wifi, size: 16, color: onSurface),
                      SizedBox(width: 4),
                      Icon(Icons.battery_full, size: 18, color: onSurface),
                    ],
                  ),
                ],
              ),
            ),
            // Brand & Location Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 32,
                        errorBuilder: (context, error, stackTrace) {
                          return const Row(
                            children: [
                              Icon(Icons.eco_rounded,
                                  color: primary, size: 26),
                              SizedBox(width: 4),
                              Text(
                                'OptiMeal',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primary,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {},
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on,
                                  color: primary, size: 18),
                              const SizedBox(width: 4),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Pickup Location',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: onSurfaceVariant,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    'Da Nang, Vietnam',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: onSurface,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(Icons.keyboard_arrow_down,
                                  size: 16, color: onSurfaceVariant),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_none,
                                color: onSurface),
                            onPressed: () {},
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: tertiaryContainer,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 16,
                                minHeight: 16,
                              ),
                              child: const Text(
                                '2',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.push(RoutePaths.profile),
                        child: const CircleAvatar(
                          radius: 16,
                          backgroundColor: Color(0xFFDAE2FD),
                          child: Icon(Icons.person,
                              size: 18, color: Color(0xFF006B2C)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    const bgSurface = Color(0xFFFAF8FF);
    const primary = Color(0xFF006B2C);
    const primaryContainer = Color(0xFF00873A);
    const onSurfaceVariant = Color(0xFF3E4A3D);

    return Container(
      decoration: BoxDecoration(
        color: bgSurface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.eco_rounded,
                    label: 'Home',
                    isActive: false,
                    onTap: () => context.go(RoutePaths.home),
                  ),
                  _buildNavItem(
                    icon: Icons.near_me_rounded,
                    label: 'Food Map',
                    isActive: false,
                    onTap: () => context.go(RoutePaths.mapSearch),
                  ),
                  // Center Add Listing FAB
                  Transform.translate(
                    offset: const Offset(0, -10),
                    child: GestureDetector(
                      onTap: () => context.push(RoutePaths.createListing),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: primaryContainer.withValues(alpha: 0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.add,
                            color: Colors.white, size: 28),
                      ),
                    ),
                  ),
                  _buildNavItem(
                    icon: Icons.auto_awesome_rounded,
                    label: 'AI Copilot',
                    isActive: true,
                    onTap: () {},
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline_rounded,
                    label: 'Profile',
                    isActive: false,
                    onTap: () => context.push(RoutePaths.profile),
                  ),
                ],
              ),
            ),
            // Home indicator pill
            Container(
              width: 120,
              height: 4,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const primary = Color(0xFF006B2C);
    const onSurfaceVariant = Color(0xFF3E4A3D);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isActive ? primary : onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? primary : onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
