import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:moelung_new/models/enums/jempoet_stage.dart';
import 'package:moelung_new/models/index.dart';
import 'package:moelung_new/utils/app_colors.dart';
import 'package:moelung_new/models/user_model.dart'; // Add this import for UserModel

class JempoetDrawer extends StatefulWidget {
  final UserModel currentUser;
  const JempoetDrawer({super.key, required this.currentUser});

  @override
  State<JempoetDrawer> createState() => _JempoetDrawerState();
}

class _JempoetDrawerState extends State<JempoetDrawer> {
  JempoetStage _stage = JempoetStage.idle;

  @override
  void initState() {
    super.initState();
    _restoreStage();
  }

  Future<void> _persistStage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('jempoetStage', _stage.index);
  }

  Future<void> _restoreStage() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt('jempoetStage') ?? JempoetStage.idle.index;
    setState(() => _stage = JempoetStage.values[idx]);
  }

  void _onContinuePressed() {
    setState(() {
      switch (_stage) {
        case JempoetStage.idle:
          _stage = JempoetStage.informed;
          break;
        case JempoetStage.informed:
          _stage = JempoetStage.onTheWay;
          break;
        case JempoetStage.onTheWay:
          _stage = JempoetStage.collected;
          break;
        case JempoetStage.collected:
          _stage = JempoetStage.sorting;
          break;
        case JempoetStage.sorting:
        case JempoetStage.done:
          break;
      }
    });

    _persistStage();
  }

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
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _dragHandle(),
                if (_stage == JempoetStage.idle) _continueButton(),
                if (_stage != JempoetStage.idle) _progressTimeline(),
              ],
            ),
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

  Widget _continueButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      onPressed: _onContinuePressed,
      child: const Text(
        'Continue',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          color: Colors.black,
        ),
      ),
    ),
  );

  Widget _progressTimeline() {
    const steps = [
      (JempoetStage.informed, 'Kolektoer informed', CupertinoIcons.bell),
      (JempoetStage.onTheWay, 'Kolektoer on the way', CupertinoIcons.car),
      (JempoetStage.collected, 'Item picked up', CupertinoIcons.cube_box),
      (JempoetStage.sorting, 'Waiting pemilahan', CupertinoIcons.time),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (i) {
        final active = _stage.index >= steps[i].$1.index;
        return _timelineNode(
          active: active,
          icon: steps[i].$3,
          label: steps[i].$2,
          isLast: i == steps.length - 1,
        );
      }),
    );
  }

  Widget _timelineNode({
    required bool active,
    required IconData icon,
    required String label,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            _circleIcon(active, icon),
            if (!isLast)
              Container(
                width: 2,
                height: 28,
                color: active ? AppColors.accent : Colors.white24,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              label,
              style: TextStyle(
                color: active ? Colors.white : Colors.white60,
                fontWeight: FontWeight.w600,
              ),
            ),
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
