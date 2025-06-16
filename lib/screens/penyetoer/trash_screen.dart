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

class _CategoryOption {
  final TrashCategory? category;
  const _CategoryOption._(this.category);
  static const all = _CategoryOption._(null);
  const _CategoryOption(TrashCategory cat) : category = cat;
  String get label => category?.label ?? 'All Trash';
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
  List<TrashItem> _items = [];
  List<TrashItem> _filteredItems = [];
  bool _isLoading = true;
  String _searchQuery = '';
  late Timer _ticker;

  @override
  void initState() {
    super.initState();
    _availableTabs = [
      _CategoryOption.all,
      ...TrashCategory.values.map(_CategoryOption.new),
    ];
    _selected = _CategoryOption.all;
    _fetchTrashForSelected();
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

  Future<void> _fetchTrashForSelected() async {
    setState(() => _isLoading = true);

    if (_selected.category == null) {
      final map = await TrashService.fetchAllTrashByUser(widget.currentUser);
      _items = map.values.expand((i) => i).toList();
    } else {
      _items = await TrashService.fetchTrashByCategoryForUser(
        userId: widget.currentUser.id,
        category: _selected.category!,
      );
    }

    _items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _filteredItems = _applySearchFilter(_items, _searchQuery);
    setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: 1,
      user: widget.currentUser,
      body: Column(
        children: [
          const PageHeader(title: 'My Trash'),
          if (_availableTabs.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: ScrollableSwitchTab<_CategoryOption>(
                items: _availableTabs,
                selected: _selected,
                labelBuilder: (c) => c.label,
                onChanged: (c) async {
                  setState(() => _selected = c);
                  await _fetchTrashForSelected();
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchInput(
              hintText: 'Search trash...',
              initialValue: _searchQuery,
              onChanged: (q) {
                _searchQuery = q;
                setState(() => _filteredItems = _applySearchFilter(_items, q));
              },
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildAggregatedList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAggregatedList() {
    if (_filteredItems.isEmpty) {
      return const Center(child: Text('No trash data.'));
    }

    final todayStart = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    final Map<TrashType, List<TrashItem>> todayMap = {};
    final Map<TrashType, List<TrashItem>> historyMap = {};

    for (final it in _filteredItems) {
      final map = it.createdAt.isAfter(todayStart) ? todayMap : historyMap;
      map.putIfAbsent(it.type, () => []).add(it);
    }

    final Map<TrashType, int> plusOlder = {};
    for (final t in todayMap.keys) {
      if (historyMap.containsKey(t)) {
        plusOlder[t] = historyMap[t]!.length;
        historyMap.remove(t);
      }
    }

    final tiles = <Widget>[];

    if (todayMap.isNotEmpty) {
      tiles.add(_sectionHeader('Today'));
      for (final t in _sortedTypes(todayMap.keys)) {
        final todayList = todayMap[t]!;
        final extra = plusOlder[t] ?? 0;
        final all = [
          ...todayList,
          if (plusOlder.containsKey(t)) ...?historyMap[t],
        ];
        final meanWeight =
            all.fold<double>(0, (s, e) => s + e.weight) / all.length;
        tiles.add(
          _aggregatedTile(
            type: t,
            qty: todayList.length,
            meanKg: meanWeight,
            plus: extra,
          ),
        );
      }
    }

    if (historyMap.isNotEmpty) {
      tiles.add(const Divider(thickness: 1, height: 1));
      tiles.add(_sectionHeader('History'));
      for (final t in _sortedTypes(historyMap.keys)) {
        final list = historyMap[t]!;
        final mean = list.fold<double>(0, (s, e) => s + e.weight) / list.length;
        tiles.add(_aggregatedTile(type: t, qty: list.length, meanKg: mean));
      }
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: tiles.length,
      itemBuilder: (_, i) => tiles[i],
      separatorBuilder: (_, __) => const Divider(height: 1),
    );
  }

  Widget _sectionHeader(String text) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    ),
  );

  List<TrashType> _sortedTypes(Iterable<TrashType> types) =>
      types.toList()..sort((a, b) => a.label.compareTo(b.label));

  Widget _aggregatedTile({
    required TrashType type,
    required int qty,
    required double meanKg,
    int plus = 0,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      leading: SizedBox( // Use SizedBox to control size of leading content
        width: 60, // Adjust width as needed
        height: 60, // Adjust height as needed
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'lib/assets/trash.png', // Use trash.png as background
              width: 50,
              height: 50,
              fit: BoxFit.contain,
              color: AppColors.primary.withOpacity(0.7), // Tint with primary color
            ),
            Icon(
              _iconForType(type), // Overlay specific trash type icon
              size: 28, // Smaller icon size
              color: AppColors.background, // White color for contrast on tinted trash.png
            ),
          ],
        ),
      ),
      title: Text(
        type.label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600), // Make title bolder
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
          Text(
            '$qty item${qty > 1 ? 's' : ''}', // Quantity on its own line
            style: TextStyle(fontSize: 13, color: AppColors.dark.withOpacity(0.7)),
          ),
          Text(
            '${meanKg.toStringAsFixed(2)} kg avg', // Average weight on its own line
            style: TextStyle(fontSize: 13, color: AppColors.dark.withOpacity(0.7)),
          ),
        ],
      ),
      trailing:
          plus > 0
              ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.2), // Themed background
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '+$plus',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    color: AppColors.primary, // Themed text color
                  ),
                ),
              )
              : null,
    );
  }

  Widget _pill(String text, Color color) => GFButton(
    onPressed: null,
    text: text,
    size: GFSize.SMALL,
    type: GFButtonType.solid,
    shape: GFButtonShape.pills,
    color: color,
    textStyle: const TextStyle(
      color: Colors.black87,
      fontWeight: FontWeight.w500,
      fontSize: 12,
    ),
  );

  IconData _iconForType(TrashType t) => switch (t) {
    TrashType.foodScrap => CupertinoIcons.leaf_arrow_circlepath,
    TrashType.leaf => CupertinoIcons.tree,
    TrashType.bottle => CupertinoIcons.drop,
    TrashType.can => CupertinoIcons.cube_box,
    TrashType.glass => CupertinoIcons.square_stack_3d_up,
    TrashType.diaper => CupertinoIcons.bed_double,
    TrashType.sanitaryPad => CupertinoIcons.bandage,
    TrashType.battery => CupertinoIcons.bolt_horizontal,
    TrashType.lightBulb => CupertinoIcons.lightbulb,
    TrashType.cardboard => CupertinoIcons.cube,
    TrashType.officePaper => CupertinoIcons.doc_text,
  };
}
