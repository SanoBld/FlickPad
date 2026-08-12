import '../models/media_item.dart';
import 'rawg_service.dart';
import 'cheapshark_service.dart';

// Combines RAWG (primary) and CheapShark (backup) with strict fallback rules:
// if primary call fails, or returns items with no image, backfill from CheapShark.
class GameRepository {
  final RawgService _rawg = RawgService();
  final CheapSharkService _cheapShark = CheapSharkService();

  Future<List<MediaItem>> latestGames() async {
    try {
      final items = await _rawg.latestGames();
      return items;
    } catch (_) {
      return [];
    }
  }

  Future<List<MediaItem>> search(String query) async {
    try {
      final items = await _rawg.search(query);
      if (items.isEmpty) throw Exception('empty');
      return _backfillImages(items, query);
    } catch (_) {
      try {
        return await _cheapShark.search(query);
      } catch (_) {
        return [];
      }
    }
  }

  Future<MediaItem?> details(String id) async {
    if (!id.startsWith('rawg_')) return null;
    final rawId = id.replaceFirst('rawg_', '');
    try {
      return await _rawg.details(rawId);
    } catch (_) {
      return null;
    }
  }

  Future<List<String>> screenshots(String id) async {
    if (!id.startsWith('rawg_')) return [];
    final rawId = id.replaceFirst('rawg_', '');
    try {
      return await _rawg.screenshots(rawId);
    } catch (_) {
      return [];
    }
  }

  // Replaces items missing an image with a CheapShark-fetched equivalent
  Future<List<MediaItem>> _backfillImages(List<MediaItem> items, String query) async {
    final anyMissing = items.any((e) => !e.hasImage);
    if (!anyMissing) return items;
    try {
      final backups = await _cheapShark.search(query);
      return items.map((item) {
        if (item.hasImage) return item;
        final match = backups.where(
          (b) => b.title.toLowerCase() == item.title.toLowerCase(),
        );
        return match.isNotEmpty ? match.first : item;
      }).toList();
    } catch (_) {
      return items;
    }
  }
}
