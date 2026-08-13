import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/favorite_folder.dart';
import '../models/media_item.dart';

// Manages favorite folders and saved media items, persisted locally
class FavoritesRepository extends ChangeNotifier {
  static const _kFolders = 'favorite_folders';
  static const _kItems = 'favorite_items'; // id -> MediaItem json

  List<FavoriteFolder> folders = [];
  Map<String, MediaItem> items = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final foldersRaw = prefs.getString(_kFolders);
    if (foldersRaw != null) {
      final list = jsonDecode(foldersRaw) as List;
      folders = list.map((e) => FavoriteFolder.fromJson(e)).toList();
    } else {
      // Default folder so users have somewhere to save immediately
      folders = [FavoriteFolder(id: 'default', name: 'Mes favoris', color: Colors.deepPurple)];
    }

    final itemsRaw = prefs.getString(_kItems);
    if (itemsRaw != null) {
      final map = jsonDecode(itemsRaw) as Map<String, dynamic>;
      items = map.map((k, v) => MapEntry(k, MediaItem.fromJson(v)));
    }

    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kFolders, jsonEncode(folders.map((f) => f.toJson()).toList()));
    await prefs.setString(_kItems, jsonEncode(items.map((k, v) => MapEntry(k, v.toJson()))));
  }

  Future<void> createFolder(String name, Color color) async {
    folders.add(FavoriteFolder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
    ));
    notifyListeners();
    await _persist();
  }

  Future<void> renameFolder(String folderId, String newName) async {
    final folder = folders.firstWhere((f) => f.id == folderId);
    folder.name = newName;
    notifyListeners();
    await _persist();
  }

  Future<void> deleteFolder(String folderId) async {
    folders.removeWhere((f) => f.id == folderId);
    notifyListeners();
    await _persist();
  }

  Future<void> addToFolder(String folderId, MediaItem item) async {
    items[item.id] = item;
    final folder = folders.firstWhere((f) => f.id == folderId);
    if (!folder.itemIds.contains(item.id)) folder.itemIds.add(item.id);
    notifyListeners();
    await _persist();
  }

  Future<void> removeFromFolder(String folderId, String itemId) async {
    final folder = folders.firstWhere((f) => f.id == folderId);
    folder.itemIds.remove(itemId);
    // Drop item data entirely if no folder references it anymore
    final stillUsed = folders.any((f) => f.itemIds.contains(itemId));
    if (!stillUsed) items.remove(itemId);
    notifyListeners();
    await _persist();
  }

  Future<void> moveItem(String itemId, String fromFolderId, String toFolderId) async {
    final from = folders.firstWhere((f) => f.id == fromFolderId);
    final to = folders.firstWhere((f) => f.id == toFolderId);
    from.itemIds.remove(itemId);
    if (!to.itemIds.contains(itemId)) to.itemIds.add(itemId);
    notifyListeners();
    await _persist();
  }

  bool isFavorite(String itemId) {
    return folders.any((f) => f.itemIds.contains(itemId));
  }

  List<MediaItem> itemsInFolder(String folderId) {
    final folder = folders.firstWhere((f) => f.id == folderId);
    return folder.itemIds.map((id) => items[id]).whereType<MediaItem>().toList();
  }
}
