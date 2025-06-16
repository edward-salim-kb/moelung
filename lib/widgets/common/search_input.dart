import 'package:flutter/material.dart';
import 'package:moelung_new/utils/app_colors.dart';

class SearchInput extends StatefulWidget {
  final String hintText;
  final String initialValue;
  final void Function(String query) onChanged;

  const SearchInput({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.initialValue = '',
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(() {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: widget.hintText,
        filled: true,
        fillColor: AppColors.background, // Light green background for input
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0), // Rounded corners
          borderSide: BorderSide.none, // No border line initially
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: AppColors.accent.withOpacity(0.5)), // Light green border when enabled
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: AppColors.primary), // Primary green border when focused
        ),
        prefixIcon: const Icon(Icons.search, color: AppColors.dark), // Dark green search icon
        suffixIcon:
            _controller.text.isNotEmpty
                ? IconButton(
                  icon: const Icon(Icons.clear, color: AppColors.dark), // Dark green clear icon
                  onPressed: () => _controller.clear(),
                )
                : null,
      ),
    );
  }
}
