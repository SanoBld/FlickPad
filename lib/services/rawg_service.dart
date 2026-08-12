import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_keys.dart';
import '../models/media_item.dart';

// Primary source for video games
class RawgService {
  static const _base = 'https://api.rawg.io/api';

  Uri _uri(String path, [Map<String, String>? params]) {
    return Uri.parse('$_base$path').replace(queryParameters: {
      'key': ApiKeys.rawg,
      ...?params,
    });
  }

  Future<List<MediaItem>> latestGames() async {
    final now = DateTime.now();
    final threeMonthsAgo = now.subtract(const Duration(days: 90));
    final dates = '${threeMonthsAgo.toIso8601String().split('T')[0]},'
        '${now.toIso8601String().split('T')[0]}';
    final res = await http.get(_uri('/games', {
      'dates': dates,
      'ordering': '-released',
      'page_size': '20',
    }));
    if (res.statusCode != 200) throw Exception('RAWG latest failed');
    final data = jsonDecode(res.body);
    final results = data['results'] as List;
    return results.map((e) => MediaItem.fromRawg(e)).toList();
  }

  Future<List<MediaItem>> search(String query) async {
    final res = await http.get(_uri('/games', {'search': query}));
    if (res.statusCode != 200) throw Exception('RAWG search failed');
    final data = jsonDecode(res.body);
    final results = data['results'] as List;
    return results.map((e) => MediaItem.fromRawg(e)).toList();
  }

  Future<MediaItem> details(String rawgId) async {
    final res = await http.get(_uri('/games/$rawgId'));
    if (res.statusCode != 200) throw Exception('RAWG details failed');
    return MediaItem.fromRawg(jsonDecode(res.body));
  }

  Future<List<String>> screenshots(String rawgId) async {
    final res = await http.get(_uri('/games/$rawgId/screenshots'));
    if (res.statusCode != 200) throw Exception('RAWG screenshots failed');
    final data = jsonDecode(res.body);
    final results = data['results'] as List;
    return results.map((e) => e['image'] as String).toList();
  }
}
