import 'package:flutter/material.dart';

class HomeSearchBar extends StatefulWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final VoidCallback? onFilterTap;
  final String initialQuery;

  const HomeSearchBar({
    super.key,
    this.onChanged,
    this.onTap,
    this.onFilterTap,
    this.initialQuery = '',
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    _controller = TextEditingController(
      text: widget.initialQuery,
    );

    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();

    widget.onChanged?.call('');

    setState(() {});
    _focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;

    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 14,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 15),

          const Icon(
            Icons.search_rounded,
            size: 22,
            color: Color(0xFF6B7280),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textInputAction: TextInputAction.search,
              onTap: widget.onTap,
              onChanged: (value) {
                widget.onChanged?.call(value);
                setState(() {});
              },
              decoration: const InputDecoration(
                hintText: 'Search cars, bikes & SUVs',
                hintStyle: TextStyle(
                  color: Color(0xFF9CA3AF),
                  fontSize: 13,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(
                color: Color(0xFF111827),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          if (hasText)
            IconButton(
              onPressed: _clearSearch,
              splashRadius: 20,
              icon: const Icon(
                Icons.close_rounded,
                size: 19,
                color: Color(0xFF6B7280),
              ),
            ),

          Container(
            height: 30,
            width: 1,
            color: const Color(0xFFE5E7EB),
          ),

          const SizedBox(width: 4),

          IconButton(
            onPressed: widget.onFilterTap,
            splashRadius: 22,
            tooltip: 'Filters',
            icon: const Icon(
              Icons.tune_rounded,
              size: 21,
              color: Color(0xFF1565C0),
            ),
          ),

          const SizedBox(width: 4),
        ],
      ),
    );
  }
}