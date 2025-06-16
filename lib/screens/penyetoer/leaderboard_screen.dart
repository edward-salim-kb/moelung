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
import 'package:moelung_new/widgets/common/scrollable_switch_tab.dart';

class _RegionOption {
  final String id;
  final String label;
  final Region? region;

  const _RegionOption({required this.id, required this.label, this.region});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _RegionOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
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

    final nationalOption = const _RegionOption(
      id: 'national',
      label: 'Nasional (Indonesia)',
      region: null,
    );

    // For testing purposes, always include a regional option.
    // TODO: Revert this to only show if widget.currentUser.region is not null.
    final regionalOption = const _RegionOption(
      id: 'regional',
      label: 'DKI Jakarta', // Hardcoded for testing
      region: Region.dkiJakarta, // Hardcoded for testing
    );

    _availableRegions = [
      nationalOption,
      regionalOption, // Always include for testing
    ];

    _selectedRegion = nationalOption; // Default to national

    print(
      'Available Regions: ${_availableRegions.map((e) => e.label).toList()}',
    );
    print('Selected Region: ${_selectedRegion.label}');

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
    print(
      'Loaded entries for region: ${_selectedRegion.label}, count: ${_entries.length}',
    );
  }

  void _loadLeaderboardEvent() async {
    final event = await LeaderboardService.fetchLeaderboardEvent();
    setState(() => _event = event);
    print(
      'Loaded event: ${_event?.name}, remaining: ${_event?.remainingLabel}',
    );
  }

  @override
  void dispose() {
    _ticker.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      navIndex: 3,
      user: widget.currentUser,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PageHeader(
                title: _event?.name ?? 'Leaderboard',
                showBackButton: false,
                trailing: _event != null
                    ? Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.white,
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
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Add a white background
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ScrollableSwitchTab<_RegionOption>(
                    items: _availableRegions,
                    selected: _selectedRegion,
                    labelBuilder: (option) => option.label,
                    onChanged: (option) {
                      setState(() {
                        _selectedRegion = option;
                        _loadEntries();
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _buildTopThree(),
              const SizedBox(height: 20),
              _eventCard(), // Moved event card here
              const SizedBox(height: 12), // Add spacing after event card
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _eventCard() {
    if (_event == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: Text(
              'Tidak ada event aktif saat ini.',
              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final myRank = _entries
        .firstWhere((e) => e.isYou, orElse: () => _entries.last)
        .rank;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: InkWell(
        onTap: () => _showEventDetailModal(context, _event!),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
                      'Semangat terus, ${widget.currentUser.name.split(' ').first}!',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _event!.description,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 4),
              Text(
                '${_event!.startDateLabel} - ${_event!.endDateLabel}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetailModal(BuildContext context, EventModel event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(event.name),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (event.imageUrl != null)
                  SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Hero(
                      tag: 'event-banner-${event.id}',
                      child: Image.network(event.imageUrl!, fit: BoxFit.cover),
                    ),
                  ),
                const SizedBox(height: 10),
                Text(event.description),
                const SizedBox(height: 10),
                Text('Tanggal Mulai: ${event.startDateLabel}'),
                Text('Tanggal Selesai: ${event.endDateLabel}'),
                Text('Sisa Waktu: ${event.remainingLabel}'),
              ],
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
                    backgroundImage: e.avatarUrl.startsWith('lib/assets/')
                        ? AssetImage(e.avatarUrl) as ImageProvider
                        : NetworkImage(e.avatarUrl),
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
              '${e.quantity} kg',
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
    return Column(
      children: List.generate(rest.length, (i) {
        final e = rest[i];
        return Column(
          children: [
            ListTile(
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
                  GFAvatar(
                    radius: 16,
                    backgroundImage: e.avatarUrl.startsWith('lib/assets/')
                        ? AssetImage(e.avatarUrl) as ImageProvider
                        : NetworkImage(e.avatarUrl),
                  ),
                ],
              ),
              title: Text(
                e.name,
                style: TextStyle(
                  fontWeight: e.isYou ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
              subtitle: Text('${e.quantity} kg'),
              trailing: e.isYou
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
                        'Kamu',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    )
                  : null,
            ),
            if (i < rest.length - 1) const Divider(height: 1),
          ],
        );
      }),
    );
  }
}
