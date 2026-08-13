// Simple community review model (TMDb review data)
class Review {
  final String author;
  final String content;
  final double? rating;

  Review({required this.author, required this.content, this.rating});

  factory Review.fromTmdb(Map<String, dynamic> json) {
    final authorDetails = json['author_details'] as Map<String, dynamic>?;
    return Review(
      author: json['author'] ?? 'Anonymous',
      content: json['content'] ?? '',
      rating: (authorDetails?['rating'] as num?)?.toDouble(),
    );
  }
}
