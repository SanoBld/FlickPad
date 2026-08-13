// Media type discriminator
enum MediaType { movie, series, game }

// Unified model used across UI regardless of source API
class MediaItem {
  final String id; // source-specific id, prefixed with source
  final MediaType type;
  final String title;
  final String? overview;
  final String? posterUrl;
  final String? backdropUrl;
  final double? rating; // normalized 0-10
  final String? releaseDate;
  final String source; // 'tmdb', 'omdb', 'rawg', 'cheapshark'

  MediaItem({
    required this.id,
    required this.type,
    required this.title,
    required this.source,
    this.overview,
    this.posterUrl,
    this.backdropUrl,
    this.rating,
    this.releaseDate,
  });

  // Factory for TMDb movie/series JSON
  factory MediaItem.fromTmdb(Map<String, dynamic> json, MediaType type) {
    const imgBase = 'https://image.tmdb.org/t/p/w780';
    return MediaItem(
      id: 'tmdb_${json['id']}',
      type: type,
      title: json['title'] ?? json['name'] ?? 'Unknown',
      overview: json['overview'],
      posterUrl: json['poster_path'] != null ? '$imgBase${json['poster_path']}' : null,
      backdropUrl: json['backdrop_path'] != null ? '$imgBase${json['backdrop_path']}' : null,
      rating: (json['vote_average'] as num?)?.toDouble(),
      releaseDate: json['release_date'] ?? json['first_air_date'],
      source: 'tmdb',
    );
  }

  // Factory for OMDb fallback JSON
  factory MediaItem.fromOmdb(Map<String, dynamic> json) {
    final poster = json['Poster'];
    return MediaItem(
      id: 'omdb_${json['imdbID']}',
      type: json['Type'] == 'series' ? MediaType.series : MediaType.movie,
      title: json['Title'] ?? 'Unknown',
      overview: json['Plot'],
      posterUrl: (poster != null && poster != 'N/A') ? poster : null,
      backdropUrl: null,
      rating: double.tryParse(json['imdbRating']?.toString() ?? ''),
      releaseDate: json['Released'],
      source: 'omdb',
    );
  }

  // Factory for RAWG game JSON
  factory MediaItem.fromRawg(Map<String, dynamic> json) {
    return MediaItem(
      id: 'rawg_${json['id']}',
      type: MediaType.game,
      title: json['name'] ?? 'Unknown',
      overview: json['description_raw'],
      posterUrl: json['background_image'],
      backdropUrl: json['background_image'],
      rating: (json['rating'] as num?)?.toDouble() != null
          ? (json['rating'] as num).toDouble() * 2 // RAWG is 0-5, normalize to 0-10
          : null,
      releaseDate: json['released'],
      source: 'rawg',
    );
  }

  // Factory for CheapShark fallback JSON (basic deal/game info)
  factory MediaItem.fromCheapShark(Map<String, dynamic> json) {
    return MediaItem(
      id: 'cheapshark_${json['gameID'] ?? json['cheapestDealID']}',
      type: MediaType.game,
      title: json['external'] ?? json['title'] ?? 'Unknown',
      overview: null,
      posterUrl: json['thumb'],
      backdropUrl: json['thumb'],
      rating: null,
      releaseDate: null,
      source: 'cheapshark',
    );
  }

  bool get hasImage => posterUrl != null || backdropUrl != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'title': title,
        'overview': overview,
        'posterUrl': posterUrl,
        'backdropUrl': backdropUrl,
        'rating': rating,
        'releaseDate': releaseDate,
        'source': source,
      };

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      type: MediaType.values.byName(json['type']),
      title: json['title'],
      overview: json['overview'],
      posterUrl: json['posterUrl'],
      backdropUrl: json['backdropUrl'],
      rating: (json['rating'] as num?)?.toDouble(),
      releaseDate: json['releaseDate'],
      source: json['source'],
    );
  }
}
