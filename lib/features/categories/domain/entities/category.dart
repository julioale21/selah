import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Category extends Equatable {
  final String id;
  final String? userId;
  final String name;
  final String iconName;
  final String colorHex;
  final int sortOrder;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    this.userId,
    required this.name,
    required this.iconName,
    required this.colorHex,
    this.sortOrder = 0,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Color get color => Color(int.parse(colorHex.replaceFirst('#', '0xFF')));

  IconData get icon => iconMap[iconName] ?? Icons.folder;

  bool get isCustom => userId != null;
  bool get canDelete => !isDefault;
  bool get canEdit => !isDefault;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        iconName,
        colorHex,
        sortOrder,
        isDefault,
        createdAt,
        updatedAt,
      ];

  static const Map<String, IconData> iconMap = {
    'family_restroom': Icons.family_restroom,
    'church': Icons.church,
    'work': Icons.work,
    'health_and_safety': Icons.health_and_safety,
    'person': Icons.person,
    'flag': Icons.flag,
    'school': Icons.school,
    'favorite': Icons.favorite,
    'star': Icons.star,
    'home': Icons.home,
    'groups': Icons.groups,
    'public': Icons.public,
    'volunteer_activism': Icons.volunteer_activism,
    'psychology': Icons.psychology,
    'savings': Icons.savings,
    'flight': Icons.flight,
    'pets': Icons.pets,
    'child_care': Icons.child_care,
    'elderly': Icons.elderly,
    'diversity_3': Icons.diversity_3,
    'auto_stories': Icons.auto_stories,
    'music_note': Icons.music_note,
    'restaurant': Icons.restaurant,
    'sports': Icons.sports,
    'directions_car': Icons.directions_car,
    'beach_access': Icons.beach_access,
    'nightlife': Icons.nightlife,
    'local_hospital': Icons.local_hospital,
    'account_balance': Icons.account_balance,
    'handshake': Icons.handshake,
  };

  static List<String> get availableIcons => iconMap.keys.toList();

  static const List<String> suggestedColors = [
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#2196F3', // Blue
    '#03A9F4', // Light Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#FF5722', // Deep Orange
    '#795548', // Brown
    '#607D8B', // Blue Grey
  ];
}
