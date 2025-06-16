import 'dart:async';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

import 'package:moelung_new/models/event_model.dart';
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/models/enums/region.dart';
import 'package:moelung_new/models/leaderboard_entry_model.dart';

import 'package:moelung_new/services/leaderboard_service.dart';
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/widgets/common/app_shell.dart';
import 'package:moelung_new/widgets/common/page_header.dart';
import 'package:moelung_new/widgets/common/switch_tab.dart';

class _RegionOption {
  final Region? region;
  const _RegionOption._(this.region);

  static const global = _RegionOption._(null);
  const _RegionOption(Region this.region);

  String get label => region?.label ?? 'Global';
}

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key, required this.currentUser});
  final UserModel currentUser;

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late List<_RegionOption> _availableRegions;
  late _RegionOption _selectedRegion;
  late List<LeaderboardEntry> _entries;
  EventModel? _event;
  late final Timer _ticker;

  @override
  void initState() {
    super.initState();

    _availableRegions =
        widget.currentUser.region != null
            ? [_RegionOption.global, _RegionOption(widget.currentUser.region!)]
            : [_RegionOption.global];

    _selectedRegion = _RegionOption.global;

    _loadEntries();
    _loadLeaderboardEvent();

    _ticker = Timer.periodic(
      const Duration(minutes: 1),
      (_) => setState(() {}),
    );
  }

  void _loadEntries() {
    _entries = LeaderboardService.loadEntries(
      currentUser: widget.currentUser,
      region: _selectedRegion.region,
    );
  }

  void _loadLeaderboardEvent() async {
    final event = await LeaderboardService.fetchLeaderboardEvent();
    setState(() => _event = event);
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const headerHeight = 340.0;

    return AppShell(
      navIndex: 3,
      user: widget.currentUser,
      body: Column(
        children: [
          PageHeader(
            title: 'Leaderboard',
            trailing:
                _event != null
                    ? Row(
                      children: [
                        const Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _event!.remainingLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    )
                    : const SizedBox.shrink(),
          ),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: headerHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.accent],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      if (_availableRegions.length > 1)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: SwitchTab<_RegionOption>(
                            items: _availableRegions,
                            selected: _selectedRegion,
                            labelBuilder: (r) => r.label,
                            onChanged: (r) {
                              setState(() {
                                _selectedRegion = r;
                                _loadEntries();
                              });
                            },
                            radius: BorderRadius.circular(20),
                          ),
                        ),
                      const SizedBox(height: 12),
                      _eventCard(),
                      const SizedBox(height: 12),
                      _buildTopThree(),
                    ],
                  ),
                ),
                Positioned(
                  top: headerHeight - 20,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, -2),
                        ),
                      ],
                    ),
                    child: _buildRestList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventCard() {
    final myRank =
        _entries.firstWhere((e) => e.isYou, orElse: () => _entries.last).rank;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '#$myRank',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Keep it up, ${widget.currentUser.name.split(' ').first}!',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopThree() {
    final sorted = List<LeaderboardEntry>.from(_entries)
      ..sort((a, b) => a.rank.compareTo(b.rank));
    if (sorted.length < 3) return const SizedBox.shrink();
    final topThree = sorted.take(3).toList();
    final reordered = [topThree[1], topThree[0], topThree[2]];
    final medalColors = [
      const Color(0xFFC0C0C0),
      const Color(0xFFFFD700),
      const Color(0xFFCD7F32),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (i) {
        final e = reordered[i];
        final isCenter = e.rank == 1;
        return Column(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: medalColors[i], width: 3),
                  ),
                  child: GFAvatar(
                    radius: isCenter ? 40 : 32,
                    backgroundImage: NetworkImage(e.avatarUrl),
                  ),
                ),
                Positioned(
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Text(
                      '${e.rank}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: isCenter ? 14 : 10,
                        color: medalColors[i],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              e.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${e.quantity} qty',
              style: TextStyle(
                color: Colors.white.withOpacity(.9),
                fontSize: 12,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildRestList() {
    final rest = _entries.where((e) => e.rank > 3).toList();
    return ListView.separated(
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 16),
      itemCount: rest.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final e = rest[i];
        return ListTile(
          leading: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${e.rank}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: e.isYou ? AppColors.primary : Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              GFAvatar(radius: 16, backgroundImage: NetworkImage(e.avatarUrl)),
            ],
          ),
          title: Text(
            e.name,
            style: TextStyle(
              fontWeight: e.isYou ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          subtitle: Text('${e.quantity} qty'),
          trailing:
              e.isYou
                  ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'You',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  )
                  : null,
        );
      },
    );
  }
}
