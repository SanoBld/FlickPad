import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_keys.dart';
import '../models/media_item.dart';

// Backup source for games, used when RAWG fails or has no image
class CheapSharkService {
  Future<List<MediaItem>> search(String query) async {
    final uri = Uri.parse('${ApiKeys.cheapSharkBase}/games').replace(
      queryParameters: {'title': query, 'limit': '20'},
    );
    final res = await http.get(uri);
    if (res.statusCode != 200) throw Exception('CheapShark search failed');
    final results = jsonDecode(res.body) as List;
    return results.map((e) => MediaItem.fromCheapShark(e)).toList();
  }
}
