import 'package:flutter/material.dart';
import 'package:moelung_new/utils/app_colors.dart';

typedef LabelBuilder<T> = String Function(T value);
typedef OnChanged<T> = void Function(T value);

class ScrollableSwitchTab<T> extends StatelessWidget {
  const ScrollableSwitchTab({
    super.key,
    required this.items,
    required this.selected,
    required this.labelBuilder,
    required this.onChanged,
    this.radius = const BorderRadius.all(Radius.circular(18)),
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  });

  final List<T> items;
  final T selected;
  final LabelBuilder<T> labelBuilder;
  final OnChanged<T> onChanged;
  final BorderRadius radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children:
            items.map((item) {
              final bool isActive = item == selected;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  borderRadius: radius,
                  onTap: () => onChanged(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: padding,
                    decoration: BoxDecoration(
                      color:
                          isActive ? AppColors.primary.withOpacity(.12) : null,
                      borderRadius: radius,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          labelBuilder(item),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color:
                                isActive
                                    ? AppColors.primary
                                    : Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 2,
                          width: isActive ? 24 : 0,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
