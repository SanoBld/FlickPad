import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

// Horizontal scrollable gallery of screenshots/images
class ImageGallery extends StatelessWidget {
  final List<String> images;

  const ImageGallery({super.key, required this.images});

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => _openFullscreen(context, images[i]),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetworkImage(
              imageUrl: images[i],
              width: 260,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                width: 260,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
              ),
              errorWidget: (_, __, ___) => Container(
                width: 260,
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                child: const Icon(Icons.broken_image),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openFullscreen(BuildContext context, String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
          body: Center(child: InteractiveViewer(child: CachedNetworkImage(imageUrl: url))),
        ),
      ),
    );
  }
}
