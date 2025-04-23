import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/category/recommendation_card.dart';
import 'package:diary/components/profilepage/horizontal_item_card.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExpandableCategory extends StatelessWidget {
  final String title;
  final IconData icon;
  final MaterialColor color;
  final List<QueryDocumentSnapshot> items;
  final int itemCount;

  const ExpandableCategory({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.itemCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine if this category should use horizontal scrolling
    final bool useHorizontalScroll = title == 'Movies' ||
        title == 'Books' ||
        title == 'Music' ||
        title == 'Exercise';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Theme(
        data: ThemeData().copyWith(
          dividerColor: Colors.transparent, // Removes the divider
          colorScheme: ColorScheme.light(
            primary: color,
          ),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          childrenPadding: const EdgeInsets.only(bottom: 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          leading: _buildLeadingIcon(),
          title: _buildTitle(),
          subtitle: _buildSubtitle(),
          trailing: _buildTrailingIcon(),
          children: [
            const Divider(height: 0, thickness: 0.8, indent: 20, endIndent: 20),

            // Choose between horizontal or vertical display based on category
            if (useHorizontalScroll)
              _buildHorizontalItemsList()
            else
              _buildVerticalItemsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: color[600],
        size: 20,
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: Colors.grey[800],
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(
        '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
        style: GoogleFonts.poppins(
          fontSize: 13,
          color: Colors.grey[500],
          letterSpacing: 0.1,
        ),
      ),
    );
  }

  Widget _buildTrailingIcon() {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: color[400],
        size: 22,
      ),
    );
  }

  Widget _buildHorizontalItemsList() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 280, // Fixed height for horizontal scrolling
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          physics: const BouncingScrollPhysics(),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final favorite = items[index].data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: SizedBox(
                width: 160,
                child: HorizontalItemCard(
                  itemData: favorite,
                  itemId: items[index].id,
                  color: color,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVerticalItemsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final favorite = items[index].data() as Map<String, dynamic>;
          return RecommendationCard(
            title: favorite['title'],
            imageUrl: favorite['imageUrl'],
            category: favorite['category'],
            isFavorite: true,
            favoriteId: items[index].id,
            genres: favorite['genres'] ?? favorite['categories'],
          );
        },
      ),
    );
  }
}
