import 'package:flutter/material.dart';
import '../models/media_item.dart';
import 'media_card.dart';

// Horizontal scrollable row of MediaCards under a section title
class MediaSection extends StatelessWidget {
  final String title;
  final List<MediaItem> items;
  final void Function(MediaItem) onItemTap;

  const MediaSection({
    super.key,
    required this.title,
    required this.items,
    required this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) => MediaCard(
              item: items[i],
              onTap: () => onItemTap(items[i]),
            ),
          ),
        ),
      ],
    );
  }
}
