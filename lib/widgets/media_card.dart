import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_settings.dart';
import '../models/media_item.dart';

// Compact poster card used in horizontal lists and grids
class MediaCard extends StatelessWidget {
  final MediaItem item;
  final VoidCallback onTap;
  final double width;

  const MediaCard({super.key, required this.item, required this.onTap, this.width = 140});

  @override
  Widget build(BuildContext context) {
    final dataSaver = context.watch<AppSettings>().dataSaverEnabled;
    final imageUrl = item.posterUrl ?? item.backdropUrl;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: imageUrl != null
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: dataSaver ? 200 : null,
                        placeholder: (_, __) => Container(color: Theme.of(context).colorScheme.surfaceContainerHigh),
                        errorWidget: (_, __, ___) => _fallbackIcon(context),
                      )
                    : _fallbackIcon(context),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (item.rating != null)
              Row(
                children: [
                  const Icon(Icons.star, size: 14, color: Colors.amber),
                  const SizedBox(width: 2),
                  Text(item.rating!.toStringAsFixed(1), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackIcon(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Icon(
        item.type == MediaType.game ? Icons.sports_esports : Icons.movie,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
