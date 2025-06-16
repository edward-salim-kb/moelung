import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/models/trash_item_model.dart';
import 'package:moelung_new/models/enums/trash_type.dart';
import 'package:moelung_new/services/trash_service.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart';
import 'package:moelung_new/widgets/common/scrollable_switch_tab.dart';
import 'package:moelung_new/widgets/common/search_input.dart';
import 'package:moelung_new/utils/app_colors.dart'; // Import AppColors
import 'package:moelung_new/models/kolektoer_trash_entry_model.dart'; // Import KolektoerTrashEntry
import 'package:moelung_new/services/kolektoer_trash_entry_service.dart'; // Import KolektoerTrashEntryService

class _CategoryOption {
  final TrashCategory? category;
  const _CategoryOption._(this.category);
  static const all = _CategoryOption._(null);
  const _CategoryOption(TrashCategory cat) : category = cat;
  String get label => category?.label ?? 'Semua Sampah';
}

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key, required this.currentUser});
  final UserModel currentUser;

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  late final List<_CategoryOption> _availableTabs;
  late _CategoryOption _selected;
  List<TrashItem> _allTrashItems = []; // Stores all trash items
  List<TrashItem> _items = []; // Stores items filtered by category
  List<TrashItem> _filteredItems = []; // Stores items filtered by search query
  bool _isLoading = true;
  String _searchQuery = '';
  late Timer _ticker;
  double _totalMoneyEarned = 0.0;
  Map<TrashCategory, double> _moneyEarnedPerCategory = {};
  List<KolektoerTrashEntry> _kolektoerEntries = [];

  final Map<TrashType, double> _pricingPerKg = {
    TrashType.foodScrap: 500.0,
    TrashType.leaf: 300.0,
    TrashType.bottle: 1500.0,
    TrashType.can: 1200.0,
    TrashType.glass: 800.0,
    TrashType.diaper: 100.0,
    TrashType.sanitaryPad: 100.0,
    TrashType.battery: 5000.0,
    TrashType.lightBulb: 2000.0,
    TrashType.cardboard: 700.0,
    TrashType.officePaper: 900.0,
  };

  @override
  void initState() {
    super.initState();
    _availableTabs = [
      _CategoryOption.all,
      ...TrashCategory.values.map(_CategoryOption.new),
    ];
    _selected = _CategoryOption.all;
    _fetchAllTrashAndInitialize(); // Fetch all trash and initialize calculations
    _fetchKolektoerEntries();
    _ticker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  Future<void> _fetchAllTrashAndInitialize() async {
    setState(() => _isLoading = true);
    final map = await TrashService.fetchAllTrashByUser(widget.currentUser);
    _allTrashItems = map.values.expand((i) => i).toList();
    _allTrashItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _calculateTotalMoney(); // Calculate total money based on all items
    _applyCategoryFilterAndSearch(); // Apply initial category filter and search
    setState(() => _isLoading = false);
  }

  // This method now only applies filters, it doesn't fetch data
  Future<void> _applyCategoryFilterAndSearch() async {
    List<TrashItem> tempItems;
    if (_selected.category == null) {
      tempItems = _allTrashItems;
    } else {
      tempItems = _allTrashItems
          .where((item) => item.category == _selected.category)
          .toList();
    }
    _items = tempItems;
    _filteredItems = _applySearchFilter(_items, _searchQuery);
    setState(() {}); // Trigger rebuild after filtering
  }

  Future<void> _fetchKolektoerEntries() async {
    try {
      final entries = await KolektoerTrashEntryService.fetchKolektoerTrashEntries(widget.currentUser.id);
      setState(() {
        _kolektoerEntries = entries;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat entri Kolektoer: $e'),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0),
        ),
      );
    }
  }

  List<TrashItem> _applySearchFilter(List<TrashItem> items, String q) {
    if (q.isEmpty) return items;
    final l = q.toLowerCase();
    return items
        .where(
          (it) =>
              it.name.toLowerCase().contains(l) ||
              it.category.label.toLowerCase().contains(l) ||
              it.type.label.toLowerCase().contains(l),
        )
        .toList();
  }

  void _calculateTotalMoney() {
    double calculatedMoney = 0.0;
    final Map<TrashCategory, double> moneyPerCategory = {};

    for (var item in _allTrashItems) { // Calculate based on all items
      final itemPrice = item.weight * (_pricingPerKg[item.type] ?? 0.0);
      calculatedMoney += itemPrice;
      moneyPerCategory.update(item.category, (value) => value + itemPrice, ifAbsent: () => itemPrice);
    }

    setState(() {
      _totalMoneyEarned = calculatedMoney;
      _moneyEarnedPerCategory = moneyPerCategory;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: 1,
      user: widget.currentUser,
      body: CustomScrollView( // Use CustomScrollView for flexible layout
        slivers: [
          SliverToBoxAdapter( // PageHeader as a fixed-height sliver
            child: const PageHeader(title: 'Sampahku', showBackButton: false),
          ),
          SliverToBoxAdapter(child: _buildTotalMoneyCard()), // Total money card
          SliverToBoxAdapter(child: _buildKolektoerEntriesCard()), // Kolektoer entries card
          SliverToBoxAdapter(child: _buildPricelistCard()), // New: Pricelist card
          if (_availableTabs.length > 1)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: ScrollableSwitchTab<_CategoryOption>(
                  items: _availableTabs,
                  selected: _selected,
                  labelBuilder: (c) => c.label,
                  onChanged: (c) async {
                    setState(() => _selected = c);
                    await _applyCategoryFilterAndSearch(); // Call the new method
                  },
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SearchInput(
                hintText: 'Cari sampah...',
                initialValue: _searchQuery,
                onChanged: (q) {
                  _searchQuery = q;
                  _applyCategoryFilterAndSearch(); // Call the new method
                },
              ),
            ),
          ),
          _buildAggregatedListSliver(), // Aggregated list as a sliver
        ],
      ),
    );
  }

  Widget _buildTotalMoneyCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.primary,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: Colors.white, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Uang dari Sampah:',
                    style: TextStyle(fontSize: 16, color: Colors.white70),
                  ),
                  Text(
                    'Rp${_totalMoneyEarned.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Rincian per Jenis Sampah:',
                    style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  if (_moneyEarnedPerCategory.isEmpty)
                    Text(
                      'Belum ada pendapatan.',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                    )
                  else
                    ..._moneyEarnedPerCategory.entries.map((entry) => Text(
                          '  - ${entry.key.label}: Rp${entry.value.toStringAsFixed(0)}',
                          style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.8)),
                        )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKolektoerEntriesCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell( // Make the card tappable
        onTap: () => _showKolektoerEntriesDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.history, color: AppColors.dark, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Log Sampah Ditambahkan Kolektoer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _kolektoerEntries.isEmpty
                          ? 'Belum ada log.'
                          : 'Lihat ${_kolektoerEntries.length} entri terbaru.',
                      style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showKolektoerEntriesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Sampah Ditambahkan Kolektoer'),
          content: _kolektoerEntries.isEmpty
              ? const Text('Tidak ada log sampah dari Kolektoer.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _kolektoerEntries.length,
                    itemBuilder: (context, index) {
                      final entry = _kolektoerEntries[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.kolektoerName} menambahkan ${entry.weight.toStringAsFixed(1)} kg ${entry.trashType.label}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Text(
                                'Pada: ${entry.dateAdded.toLocal().toString().split('.')[0]}',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                              Text(
                                'Anda mendapatkan: Rp${entry.priceEarned.toStringAsFixed(0)}',
                                style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildPricelistCard() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell( // Make the card tappable
        onTap: () => _showPricelistDialog(context),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              const Icon(Icons.attach_money, color: AppColors.dark, size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Daftar Harga Sampah',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.dark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lihat harga per kilogram untuk setiap jenis sampah.',
                      style: const TextStyle(fontSize: 14, color: AppColors.secondary),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  void _showPricelistDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Daftar Harga Sampah (per kg)'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _pricingPerKg.length,
              itemBuilder: (context, index) {
                final entry = _pricingPerKg.entries.elementAt(index);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.eco, color: AppColors.secondary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${entry.key.label}: Rp${entry.value.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Tutup'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  SliverList _buildAggregatedListSliver() {
    if (_isLoading) { // Show loading indicator only for this section
      return SliverList(
        delegate: SliverChildListDelegate(
          [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      );
    }

    if (_filteredItems.isEmpty) {
      return SliverList(
        delegate: SliverChildListDelegate(
          [const Center(child: Text('Tidak ada data sampah.'))],
        ),
      );
    }

    final Map<TrashType, List<TrashItem>> aggregatedMap = {};

    for (final it in _filteredItems) {
      aggregatedMap.putIfAbsent(it.type, () => []).add(it);
    }

    final tiles = <Widget>[];

    for (final t in _sortedTypes(aggregatedMap.keys)) {
      final list = aggregatedMap[t]!;
      final meanWeight = list.fold<double>(0, (s, e) => s + e.weight) / list.length;
      tiles.add(
        _aggregatedTile(
          type: t,
          qty: list.length,
          meanKg: meanWeight,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, i) => tiles[i],
        childCount: tiles.length,
      ),
    );
  }

  List<TrashType> _sortedTypes(Iterable<TrashType> types) =>
      types.toList()..sort((a, b) => a.label.compareTo(b.label));

  Widget _aggregatedTile({
    required TrashType type,
    required int qty,
    required double meanKg,
  }) {
    String imagePath = _imagePathForType(type);

    // Calculate estimated monetary value
    final estimatedValue = meanKg * (_pricingPerKg[type] ?? 0.0);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: imagePath.isNotEmpty
                  ? Image.asset(
                      imagePath,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : Icon(
                      Icons.recycling,
                      size: 50,
                      color: AppColors.primary.withOpacity(0.7),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.label,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.dark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$qty item • ${meanKg.toStringAsFixed(2)} kg rata-rata',
                    style: TextStyle(fontSize: 14, color: AppColors.dark.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0, // gap between adjacent chips
                    runSpacing: 4.0, // gap between lines
                    children: <Widget>[
                      _pill(type.category.label, AppColors.primary.withOpacity(0.1), AppColors.primary),
                      if (estimatedValue > 0)
                        _pill(
                          'Rp${estimatedValue.toStringAsFixed(0)}',
                          AppColors.accent.withOpacity(0.1),
                          AppColors.accent,
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

  String _imagePathForType(TrashType t) {
    switch (t) {
      case TrashType.foodScrap:
        return 'lib/assets/trash/foodwaste.png';
      case TrashType.bottle:
        return 'lib/assets/trash/bottle.png';
      case TrashType.can:
        return 'lib/assets/trash/can.png';
      case TrashType.cardboard:
        return 'lib/assets/trash/cardboard.png';
      case TrashType.diaper:
        return 'lib/assets/trash/diaper.png';
      case TrashType.leaf:
        return 'lib/assets/trash/foodwaste.png'; // Using foodwaste for leaf as well
      case TrashType.glass:
        return 'lib/assets/trash/glass.png';
      case TrashType.battery:
        return 'lib/assets/trash/battery.png'; // Assuming you have this asset
      case TrashType.lightBulb:
        return 'lib/assets/trash/lightbulb.png'; // Assuming you have this asset
      case TrashType.officePaper:
        return 'lib/assets/trash/officepaper.png'; // Assuming you have this asset
      case TrashType.sanitaryPad:
        return 'lib/assets/trash/sanitarypad.png'; // Assuming you have this asset
      default:
        return ''; // Return empty string for types without specific images
    }
  }

  Widget _pill(String text, Color backgroundColor, Color textColor) => GFButton(
    onPressed: null,
    text: text,
    size: GFSize.SMALL,
    type: GFButtonType.solid,
    shape: GFButtonShape.pills,
    color: backgroundColor,
    textStyle: TextStyle(
      color: textColor,
      fontWeight: FontWeight.w600,
      fontSize: 11,
    ),
  );
}
