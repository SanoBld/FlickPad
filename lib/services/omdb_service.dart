import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_keys.dart';
import '../models/media_item.dart';

// Backup source for movies and series, used when TMDb fails or has no image
class OmdbService {
  static const _base = 'https://www.omdbapi.com/';

  Future<List<MediaItem>> search(String query) async {
    final uri = Uri.parse(_base).replace(queryParameters: {
      'apikey': ApiKeys.omdb,
      's': query,
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('OMDb search failed');
    final data = jsonDecode(res.body);
    if (data['Response'] == 'False') return [];
    final results = data['Search'] as List;
    return results.map((e) => MediaItem.fromOmdb(e)).toList();
  }

  Future<MediaItem?> byTitle(String title) async {
    final uri = Uri.parse(_base).replace(queryParameters: {
      'apikey': ApiKeys.omdb,
      't': title,
    });
    final res = await http.get(uri);
    if (res.statusCode != 200) return null;
    final data = jsonDecode(res.body);
    if (data['Response'] == 'False') return null;
    return MediaItem.fromOmdb(data);
  }
}
