import 'package:flutter/material.dart';

class CategoryModel {
  final int id;
  final String name;
  final Color backgroundColor;
  final IconData icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.backgroundColor,
    required this.icon,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json, int index) {
    final rawName = json['name'] as String? ?? 'General Knowledge';
    // Clean name: e.g. "Entertainment: Japanese Anime & Manga" -> "Japanese Anime & Manga"
    final cleanName = rawName.contains(': ')
        ? rawName.substring(rawName.indexOf(': ') + 2)
        : rawName;

    final colors = [
      const Color(0xFFE8F5E9), // Light Green
      const Color(0xFFE3F2FD), // Light Blue
      const Color(0xFFFFF3E0), // Light Orange
      const Color(0xFFF3E5F5), // Light Purple
      const Color(0xFFFFEBEE), // Light Pink
      const Color(0xFFE0F7FA), // Light Cyan
      const Color(0xFFFFFDE7), // Light Yellow
      const Color(0xFFEDE7F6), // Deep Purple 50
      const Color(0xFFF1F8E9), // Light Lime
      const Color(0xFFFBE9E7), // Light Coral
    ];

    final icons = [
      Icons.auto_stories_rounded,
      Icons.movie_creation_rounded,
      Icons.music_note_rounded,
      Icons.sports_esports_rounded,
      Icons.science_rounded,
      Icons.sports_soccer_rounded,
      Icons.travel_explore_rounded,
      Icons.history_edu_rounded,
      Icons.palette_rounded,
      Icons.psychology_rounded,
      Icons.devices_rounded,
      Icons.pets_rounded,
      Icons.calculate_rounded,
      Icons.public_rounded,
      Icons.menu_book_rounded,
    ];

    return CategoryModel(
      id: json['id'] as int? ?? 0,
      name: cleanName,
      backgroundColor: colors[index % colors.length],
      icon: icons[index % icons.length],
    );
  }
}
