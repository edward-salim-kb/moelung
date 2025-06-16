import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class SwitchTab<T> extends StatelessWidget {
  final List<T> items;
  final T selected;
  final BorderRadius radius;
  final String Function(T) labelBuilder;
  final void Function(T) onChanged;

  const SwitchTab({
    super.key,
    required this.items,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
    this.radius = const BorderRadius.all(Radius.circular(24)),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: radius,
      ),
      child: Row(
        children:
            items.map((item) {
              final bool active = item == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : Colors.transparent,
                      borderRadius: radius,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      labelBuilder(item).toUpperCase(),
                      style: TextStyle(
                        color: active ? Colors.white : AppColors.dark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
