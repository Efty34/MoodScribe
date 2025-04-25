import 'package:animations/animations.dart';
import 'package:diary/components/custom_app_drawer.dart';
import 'package:diary/pages/category_page.dart';
import 'package:diary/pages/diary_entry.dart';
import 'package:diary/pages/home_page.dart';
import 'package:diary/pages/profile_page.dart';
import 'package:diary/pages/todo_page.dart';
import 'package:diary/utils/search_state.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  var currentIndex = 2;
  late final SearchState _homeSearchState;
  late final SearchState _todoSearchState;
  late final List<Widget> _pages;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _homeSearchState = SearchState();
    _todoSearchState = SearchState();
    _pages = [
      HomePage(searchState: _homeSearchState),
      const CategoryPage(),
      const DiaryEntry(),
      TodoPage(searchState: _todoSearchState),
      const ProfilePage(),
    ];

    _searchController.addListener(() {
      if (currentIndex == 0) {
        _homeSearchState.updateQuery(_searchController.text);
      } else if (currentIndex == 3) {
        _todoSearchState.updateQuery(_searchController.text);
      }
    });
  }

  // List of titles for each page
  final List<String> _titles = [
    'Home',
    'Discover',
    'New Entry',
    'Todo List',
    'Profile',
  ];

  PreferredSizeWidget _buildAppBar() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_isSearching && (currentIndex == 0 || currentIndex == 3)) {
      return AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: theme.colorScheme.onSurface,
            size: 22,
          ),
          onPressed: _exitSearchMode,
        ),
        title: Container(
          height: 40,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.secondary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.dividerColor,
            ),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            style: GoogleFonts.poppins(
              fontSize: 15,
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.search_rounded,
                color: theme.hintColor,
                size: 22,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? GestureDetector(
                      onTap: _exitSearchMode,
                      child: Icon(
                        Icons.close_rounded,
                        color: theme.hintColor,
                        size: 22,
                      ),
                    )
                  : null,
              hintText: 'Search...',
              hintStyle: GoogleFonts.poppins(
                color: theme.hintColor,
                fontSize: 15,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              if (currentIndex == 0) {
                _todoSearchState.clearQuery();
              } else if (currentIndex == 3) {
                _homeSearchState.clearQuery();
              }
            },
          ),
        ),
      );
    }

    return AppBar(
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: theme.colorScheme.onSurface,
            size: 28,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Text(
        _titles[currentIndex],
        style: GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions: _buildActions(),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      drawer: const CustomAppDrawer(),
      appBar: _buildAppBar(),
      extendBody: true,
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (child, animation, secondaryAnimation) =>
            FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        ),
        child: _pages[currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(20),
        height: size.width * .155,
        decoration: BoxDecoration(
          color: isDark ? theme.colorScheme.surface : theme.cardColor,
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(isDark ? 0.3 : 0.15),
          //     blurRadius: 30,
          //     offset: const Offset(0, 10),
          //   ),
          // ],
          border: Border.all(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black12.withOpacity(0.1),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(50),
        ),
        child: ListView.builder(
          itemCount: 5,
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: size.width * .024),
          itemBuilder: (context, index) => InkWell(
            onTap: () => _onTabChanged(index),
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.fastLinearToSlowEaseIn,
                  margin: EdgeInsets.only(
                    bottom: index == currentIndex ? 0 : size.width * .029,
                    right: size.width * .0422,
                    left: size.width * .0422,
                  ),
                  width: size.width * .085,
                  height: index == currentIndex ? size.width * .014 : 0,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(10),
                    ),
                  ),
                ),
                Icon(
                  listOfIcons[index],
                  size: size.width * .076,
                  color: index == currentIndex
                      ? theme.colorScheme.primary
                      : theme.hintColor,
                ),
                SizedBox(height: size.width * .03),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget>? _buildActions() {
    final theme = Theme.of(context);

    if (currentIndex == 0 || currentIndex == 3) {
      return [
        IconButton(
          icon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurface,
            size: 28,
          ),
          onPressed: () {
            setState(() {
              _isSearching = true;
            });
          },
        ),
        const SizedBox(width: 8),
      ];
    }
    return null;
  }

  List<IconData> listOfIcons = [
    Icons.home_rounded,
    Icons.category_rounded,
    Icons.add_rounded,
    Icons.list_rounded,
    Icons.person_rounded,
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _homeSearchState.dispose();
    _todoSearchState.dispose();
    super.dispose();
  }

  void _exitSearchMode() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
      if (currentIndex == 0) {
        _homeSearchState.clearQuery();
      } else if (currentIndex == 3) {
        _todoSearchState.clearQuery();
      }
    });
  }

  void _onTabChanged(int index) {
    if (_isSearching) {
      _exitSearchMode();
    }
    setState(() {
      currentIndex = index;
    });
  }
}
