import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController _searchController = TextEditingController();

  CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
          color: Colors.blue,
          size: 24,
        ),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: Container(
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(
              color: Colors.brown.shade300,
              fontSize: 14,
            ),
            border: InputBorder.none,
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey.shade500,
              size: 20,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
          ),
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: GestureDetector(
            onTap: () {},
            child: CircleAvatar(
              radius: 20,
              backgroundImage: const NetworkImage(
                'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
              ),
              backgroundColor: Colors.grey.shade300,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
