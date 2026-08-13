import 'package:flutter/material.dart';

// A user-created folder holding favorite media items
class FavoriteFolder {
  final String id;
  String name;
  Color color;
  List<String> itemIds; // MediaItem.id references

  FavoriteFolder({
    required this.id,
    required this.name,
    required this.color,
    List<String>? itemIds,
  }) : itemIds = itemIds ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color.toARGB32(),
        'itemIds': itemIds,
      };

  factory FavoriteFolder.fromJson(Map<String, dynamic> json) {
    return FavoriteFolder(
      id: json['id'],
      name: json['name'],
      color: Color(json['color']),
      itemIds: List<String>.from(json['itemIds'] ?? []),
    );
  }
}
