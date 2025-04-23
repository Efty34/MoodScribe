import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController? searchController;
  final Function(String)? onSearchChanged;
  final bool isSearching;
  final VoidCallback? onSearchToggle;
  final String? title;

  const CustomAppBar({
    super.key,
    this.searchController,
    this.onSearchChanged,
    this.isSearching = false,
    this.onSearchToggle,
    this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      title: isSearching && searchController != null
          ? TextField(
              controller: searchController,
              onChanged: onSearchChanged,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search entries...',
                hintStyle: GoogleFonts.poppins(
                  color: theme.hintColor,
                  fontSize: 16,
                ),
                border: InputBorder.none,
              ),
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: theme.colorScheme.onSurface,
              ),
            )
          : Text(
              title ?? 'Mind Journal',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
      actions: [
        if (onSearchToggle != null)
          IconButton(
            icon: Icon(
              isSearching ? Icons.close : Icons.search,
              color: theme.colorScheme.primary,
            ),
            onPressed: onSearchToggle,
          ),
      ],
    );
  }
}
