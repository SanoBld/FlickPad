// Represents a playable trailer, normalized to a YouTube key
class VideoTrailer {
  final String key; // YouTube video id
  final String name;
  final String site;

  VideoTrailer({required this.key, required this.name, required this.site});

  factory VideoTrailer.fromTmdb(Map<String, dynamic> json) {
    return VideoTrailer(
      key: json['key'] ?? '',
      name: json['name'] ?? 'Trailer',
      site: json['site'] ?? 'YouTube',
    );
  }

  bool get isYoutube => site == 'YouTube' && key.isNotEmpty;
}
