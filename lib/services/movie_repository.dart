import '../models/media_item.dart';
import '../models/video_trailer.dart';
import 'tmdb_service.dart';
import 'omdb_service.dart';

// Combines TMDb (primary) and OMDb (backup) with strict fallback rules:
// if primary call fails, or returns items with no image, backfill from OMDb.
class MovieRepository {
  final TmdbService _tmdb = TmdbService();
  final OmdbService _omdb = OmdbService();

  Future<List<MediaItem>> latestMovies() async {
    try {
      final items = await _tmdb.latestMovies();
      return _backfillImages(items);
    } catch (_) {
      return _omdb.search('2024'); // broad backup query if TMDb is fully down
    }
  }

  Future<List<MediaItem>> latestSeries() async {
    try {
      final items = await _tmdb.latestSeries();
      return _backfillImages(items);
    } catch (_) {
      return [];
    }
  }

  Future<List<MediaItem>> search(String query) async {
    try {
      final items = await _tmdb.search(query);
      if (items.isEmpty) throw Exception('empty');
      return _backfillImages(items);
    } catch (_) {
      try {
        return await _omdb.search(query);
      } catch (_) {
        return [];
      }
    }
  }

  Future<MediaItem?> details(String id, MediaType type) async {
    if (id.startsWith('tmdb_')) {
      final rawId = id.replaceFirst('tmdb_', '');
      try {
        return await _tmdb.details(rawId, type);
      } catch (_) {
        return null;
      }
    }
    if (id.startsWith('omdb_')) {
      // OMDb details already fetched via search; nothing extra to load
      return null;
    }
    return null;
  }

  Future<List<String>> images(String id, MediaType type) async {
    if (!id.startsWith('tmdb_')) return [];
    final rawId = id.replaceFirst('tmdb_', '');
    try {
      final imgs = await _tmdb.images(rawId, type);
      return imgs;
    } catch (_) {
      return [];
    }
  }

  Future<List<VideoTrailer>> trailers(String id, MediaType type) async {
    if (!id.startsWith('tmdb_')) return [];
    final rawId = id.replaceFirst('tmdb_', '');
    try {
      return await _tmdb.videos(rawId, type);
    } catch (_) {
      return [];
    }
  }

  // Replaces items missing an image with an OMDb-fetched equivalent by title
  Future<List<MediaItem>> _backfillImages(List<MediaItem> items) async {
    final result = <MediaItem>[];
    for (final item in items) {
      if (item.hasImage) {
        result.add(item);
        continue;
      }
      try {
        final backup = await _omdb.byTitle(item.title);
        result.add(backup ?? item);
      } catch (_) {
        result.add(item);
      }
    }
    return result;
  }
}
