import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getwidget/getwidget.dart';
import 'package:intl/intl.dart';
import 'package:moelung_new/models/enums/point_catalog.dart';
import 'package:moelung_new/models/point_catalog_item.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/services/point_market_service.dart';
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart';
import 'package:moelung_new/widgets/common/scrollable_switch_tab.dart';

class PointMarketScreen extends StatefulWidget {
  const PointMarketScreen({super.key, required this.currentUser});
  final UserModel currentUser;

  @override
  State<PointMarketScreen> createState() => _PointMarketScreenState();
}

class _PointMarketScreenState extends State<PointMarketScreen> {
  late UserModel _user;
  late Future<List<PointCatalogItem>> _futureCatalog;

  final List<CatalogCategory?> _tabs = [
    null,
    CatalogCategory.voucher,
    CatalogCategory.merchandise,
    CatalogCategory.cash,
  ];
  CatalogCategory? _selectedTab;

  @override
  void initState() {
    super.initState();
    _user = widget.currentUser;
    _selectedTab = _tabs.first;
    _futureCatalog = PointMarketService.fetchCatalog();
  }

  Future<void> _reload() async {
    final list = await PointMarketService.fetchCatalog();
    setState(() => _futureCatalog = Future.value(list));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: 2,
      user: _user,
      body: Column(
        children: [
          PageHeader(
            title: 'Point Market',
            trailing: Row(
              children: [
                const Icon(CupertinoIcons.star_fill, color: AppColors.primary),
                const SizedBox(width: 4),
                Text(
                  NumberFormat.compact().format(_user.points),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: ScrollableSwitchTab<CatalogCategory?>(
              items: _tabs,
              selected: _selectedTab,
              labelBuilder:
                  (cat) => switch (cat) {
                    null => 'All',
                    CatalogCategory.voucher => 'Voucher',
                    CatalogCategory.merchandise => 'Merchandise',
                    CatalogCategory.cash => 'Cash',
                  },
              onChanged: (cat) => setState(() => _selectedTab = cat),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PointCatalogItem>>(
              future: _futureCatalog,
              builder: (_, snap) {
                if (!snap.hasData) {
                  return const Center(child: CupertinoActivityIndicator());
                }

                var items = snap.data!;
                if (_selectedTab != null) {
                  items =
                      items.where((e) => e.category == _selectedTab).toList();
                }

                if (items.isEmpty) {
                  return const Center(child: Text('No items available.'));
                }

                return RefreshIndicator(
                  onRefresh: _reload,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _itemCard(items[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCard(PointCatalogItem item) {
    final canRedeem = _user.points >= item.costPoints && item.quantity > 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.imagePath,
              width: 70,
              height: 70,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      CupertinoIcons.star_fill,
                      size: 14,
                      color: canRedeem ? AppColors.primary : Colors.black38,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${item.costPoints} pts',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: canRedeem ? AppColors.primary : Colors.black45,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Qty: ${item.quantity}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GFButton(
            onPressed:
                canRedeem
                    ? () async {
                      try {
                        final updatedUser = await PointMarketService.redeemItem(
                          user: _user,
                          itemId: item.id,
                          cost: item.costPoints,
                        );
                        setState(() => _user = updatedUser);

                        Fluttertoast.showToast(
                          msg: "Redeemed ${item.name}!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                          fontSize: 14,
                        );

                        _reload();
                      } catch (e) {
                        Fluttertoast.showToast(
                          msg: e.toString().replaceFirst("Exception: ", ""),
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 14,
                        );
                      }
                    }
                    : null,
            text: item.quantity <= 0 ? 'Out of Stock' : 'Redeem',
            size: GFSize.SMALL,
            shape: GFButtonShape.pills,
            color: AppColors.primary,
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
        ],
      ),
    );
  }

  String _labelForCat(CatalogCategory cat) => switch (cat) {
    CatalogCategory.voucher => 'Voucher',
    CatalogCategory.merchandise => 'Merchandise',
    CatalogCategory.cash => 'Cash',
  };
}
