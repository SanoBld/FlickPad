import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/api_keys.dart';
import '../models/media_item.dart';
import '../models/video_trailer.dart';
import '../models/review.dart';

// Primary source for movies and series
class TmdbService {
  static const _base = 'https://api.themoviedb.org/3';

  Uri _uri(String path, [Map<String, String>? params]) {
    return Uri.parse('$_base$path').replace(queryParameters: {
      'api_key': ApiKeys.tmdb,
      'language': 'fr-FR',
      ...?params,
    });
  }

  Future<List<MediaItem>> latestMovies() async {
    final res = await http.get(_uri('/movie/now_playing'));
    if (res.statusCode != 200) throw Exception('TMDb movies failed');
    final data = jsonDecode(res.body);
    final results = data['results'] as List;
    return results.map((e) => MediaItem.fromTmdb(e, MediaType.movie)).toList();
  }

  Future<List<MediaItem>> latestSeries() async {
    final res = await http.get(_uri('/tv/on_the_air'));
    if (res.statusCode != 200) throw Exception('TMDb series failed');
    final data = jsonDecode(res.body);
    final results = data['results'] as List;
    return results.map((e) => MediaItem.fromTmdb(e, MediaType.series)).toList();
  }

  Future<List<MediaItem>> search(String query) async {
    final res = await http.get(_uri('/search/multi', {'query': query}));
    if (res.statusCode != 200) throw Exception('TMDb search failed');
    final data = jsonDecode(res.body);
    final results = data['results'] as List;
    return results
        .where((e) => e['media_type'] == 'movie' || e['media_type'] == 'tv')
        .map((e) => MediaItem.fromTmdb(
              e,
              e['media_type'] == 'tv' ? MediaType.series : MediaType.movie,
            ))
        .toList();
  }

  Future<MediaItem> details(String tmdbId, MediaType type) async {
    final path = type == MediaType.series ? '/tv/$tmdbId' : '/movie/$tmdbId';
    final res = await http.get(_uri(path));
    if (res.statusCode != 200) throw Exception('TMDb details failed');
    return MediaItem.fromTmdb(jsonDecode(res.body), type);
  }

  Future<List<String>> images(String tmdbId, MediaType type) async {
    final path = type == MediaType.series ? '/tv/$tmdbId/images' : '/movie/$tmdbId/images';
    final res = await http.get(_uri(path));
    if (res.statusCode != 200) throw Exception('TMDb images failed');
    final data = jsonDecode(res.body);
    final backdrops = (data['backdrops'] as List? ?? []);
    return backdrops
        .map((e) => 'https://image.tmdb.org/t/p/w780${e['file_path']}')
        .toList();
  }

  Future<List<VideoTrailer>> videos(String tmdbId, MediaType type) async {
    final path = type == MediaType.series ? '/tv/$tmdbId/videos' : '/movie/$tmdbId/videos';
    final res = await http.get(_uri(path));
    if (res.statusCode != 200) throw Exception('TMDb videos failed');
    final data = jsonDecode(res.body);
    final results = data['results'] as List? ?? [];
    return results
        .map((e) => VideoTrailer.fromTmdb(e))
        .where((v) => v.isYoutube)
        .toList();
  }

  Future<List<Review>> reviews(String tmdbId, MediaType type) async {
    final path = type == MediaType.series ? '/tv/$tmdbId/reviews' : '/movie/$tmdbId/reviews';
    final res = await http.get(_uri(path));
    if (res.statusCode != 200) throw Exception('TMDb reviews failed');
    final data = jsonDecode(res.body);
    final results = data['results'] as List? ?? [];
    return results.map((e) => Review.fromTmdb(e)).toList();
  }
}
