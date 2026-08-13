import 'package:flutter/material.dart';
import '../../models/media_item.dart';

// Full details page built in step 5 (hero, gallery, trailers, reviews)
class DetailsScreen extends StatelessWidget {
  final MediaItem item;

  const DetailsScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(item.title)),
      body: Center(child: Text('${item.title} - details placeholder')),
    );
  }
}
