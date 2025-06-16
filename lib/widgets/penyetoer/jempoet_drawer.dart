import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import 'package:moelung_new/models/user_model.dart';
import 'package:moelung_new/models/enums/pickup_status.dart'; // Import PickupStatus
import 'package:moelung_new/services/pickup_service.dart'; // Import PickupService
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/config/app_routes.dart'; // Import AppRoutes

class JempoetDrawer extends StatelessWidget {
  final UserModel currentUser;
  const JempoetDrawer({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.3,
      minChildSize: 0.18,
      maxChildSize: 0.85,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.dark,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Consumer<PickupService>(
            builder: (context, pickupService, child) {
              final currentRequest = pickupService.currentPickupRequest;

              if (currentRequest == null) {
                return CustomScrollView( // Use CustomScrollView for draggable content
                  controller: controller,
                  // Reverted physics to allow dragging
                  slivers: [
                    SliverToBoxAdapter(child: _dragHandle()),
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          const Center(
                            child: Text(
                              'Tidak ada permintaan Jempoet aktif.',
                              style: TextStyle(color: Colors.white70, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.secondary,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              onPressed: () {
                                Navigator.of(context).pop(); // Close drawer
                                Navigator.of(context).pushNamed(AppRoutes.jempoetRequest, arguments: currentUser);
                              },
                              child: const Text(
                                'Ajukan Jempoet Baru',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
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

              return CustomScrollView( // Use CustomScrollView for draggable content
                controller: controller,
                // Reverted physics to allow dragging
                slivers: [
                  SliverToBoxAdapter(child: _dragHandle()),
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Status Permintaan Jempoet:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Kolektoer Profile
                        if (currentRequest.collectorName != null &&
                            currentRequest.status.index >= PickupStatus.collectorAssigned.index)
                          _buildCollectorProfile(currentRequest.collectorName!),
                        const SizedBox(height: 20),
                        // Horizontal Timeline
                        _progressTimelineHorizontal(currentRequest.statusHistory),
                        const SizedBox(height: 16),
                        // Description below timeline
                        Text(
                          currentRequest.status.description,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (currentRequest.status == PickupStatus.onTheWay && currentRequest.collectorName != null)
                          Text(
                            '${currentRequest.collectorName} berjarak ${currentRequest.distanceRemaining?.toStringAsFixed(1) ?? '...'} km dari Anda.',
                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        const SizedBox(height: 20),
                        if (currentRequest.status != PickupStatus.completed &&
                            currentRequest.status != PickupStatus.cancelled)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.errorRed,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              onPressed: () {
                                pickupService.cancelPickupRequest();
                                Navigator.of(context).pop(); // Close drawer
                              },
                              child: const Text(
                                'Batalkan Permintaan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        if (currentRequest.status == PickupStatus.completed ||
                            currentRequest.status == PickupStatus.cancelled)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.infoBlue,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                              ),
                              onPressed: () {
                                pickupService.clearPickupRequest();
                                Navigator.of(context).pop(); // Close drawer
                              },
                              child: const Text(
                                'Selesai / Hapus Permintaan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _dragHandle() => Center(
        child: Container(
          width: 34,
          height: 4,
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      );

  Widget _buildCollectorProfile(String collectorName) {
    return Card(
      color: AppColors.primary, // Use a distinct color for the card
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.accent, width: 2),
              ),
              child: ClipOval(
                child: Image.asset(
                  'lib/assets/avatars/image.png', // Placeholder avatar
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kolektoer Anda:',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  collectorName,
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _progressTimelineHorizontal(List<PickupStatus> statusHistory) {
    final relevantStatuses = PickupStatus.values.where((s) => s != PickupStatus.cancelled).toList(); // Exclude cancelled from main timeline

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(relevantStatuses.length * 2 - 1, (i) {
          if (i % 2 == 0) { // Even index is a node
            final statusIndex = i ~/ 2;
            final status = relevantStatuses[statusIndex];
            final active = statusHistory.contains(status);
            IconData icon;
            switch (status) {
              case PickupStatus.requested:
                icon = CupertinoIcons.doc_text;
                break;
              case PickupStatus.searchingCollector:
                icon = CupertinoIcons.search;
                break;
              case PickupStatus.collectorAssigned:
                icon = CupertinoIcons.person_alt_circle;
                break;
              case PickupStatus.onTheWay:
                icon = CupertinoIcons.car_fill;
                break;
              case PickupStatus.arrived:
                icon = CupertinoIcons.location_solid;
                break;
              case PickupStatus.collecting:
                icon = CupertinoIcons.cube_box_fill;
                break;
              case PickupStatus.validating:
                icon = CupertinoIcons.checkmark_shield_fill;
                break;
              case PickupStatus.completed:
                icon = CupertinoIcons.check_mark_circled_solid;
                break;
              case PickupStatus.cancelled: // Should not be reached in this loop due to where clause
                icon = CupertinoIcons.xmark_circle_fill;
                break;
            }
            return _timelineNodeHorizontal(
              active: active,
              icon: icon,
              label: status.label,
            );
          } else { // Odd index is a connecting line
            final previousStatusIndex = (i - 1) ~/ 2;
            final currentStatusIndex = (i + 1) ~/ 2;
            final previousStatusActive = statusHistory.contains(relevantStatuses[previousStatusIndex]);
            final currentStatusActive = statusHistory.contains(relevantStatuses[currentStatusIndex]);
            final lineActive = previousStatusActive && currentStatusActive;
            return Container(
              width: 40, // Line length
              height: 2,
              color: lineActive ? AppColors.accent : Colors.white24,
              margin: const EdgeInsets.symmetric(horizontal: 4),
            );
          }
        }),
      ),
    );
  }

  Widget _timelineNodeHorizontal({
    required bool active,
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        _circleIcon(active, icon),
        const SizedBox(height: 8),
        SizedBox(
          width: 80, // Fixed width for each node
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? Colors.white : Colors.white60,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _circleIcon(bool active, IconData icon) => Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active ? AppColors.accent : Colors.white10,
          shape: BoxShape.circle,
          border: Border.all(
            color: active ? AppColors.accent : Colors.white30,
            width: 2,
          ),
        ),
        child: Icon(icon, size: 18, color: active ? Colors.black : Colors.white54),
      );
}
