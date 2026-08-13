import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/media_item.dart';
import '../../models/review.dart';
import '../../models/video_trailer.dart';
import '../../services/movie_repository.dart';
import '../../services/game_repository.dart';
import '../../services/favorites_repository.dart';
import '../../widgets/image_gallery.dart';
import '../../widgets/trailer_list.dart';

// Full details page: hero image, reviews, gallery, trailers, synopsis
class DetailsScreen extends StatefulWidget {
  final MediaItem item;

  const DetailsScreen({super.key, required this.item});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  final _movieRepo = MovieRepository();
  final _gameRepo = GameRepository();

  List<String> _images = [];
  List<VideoTrailer> _trailers = [];
  List<Review> _reviews = [];
  bool _loading = true;

  bool get _isGame => widget.item.type == MediaType.game;

  @override
  void initState() {
    super.initState();
    _loadExtras();
  }

  Future<void> _loadExtras() async {
    if (_isGame) {
      final screenshots = await _gameRepo.screenshots(widget.item.id);
      if (!mounted) return;
      setState(() {
        _images = screenshots;
        _loading = false;
      });
    } else {
      final results = await Future.wait([
        _movieRepo.images(widget.item.id, widget.item.type),
        _movieRepo.trailers(widget.item.id, widget.item.type),
        _movieRepo.reviews(widget.item.id, widget.item.type),
      ]);
      if (!mounted) return;
      setState(() {
        _images = results[0] as List<String>;
        _trailers = results[1] as List<VideoTrailer>;
        _reviews = results[2] as List<Review>;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final heroUrl = widget.item.backdropUrl ?? widget.item.posterUrl;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFolderPicker(context),
        child: const Icon(Icons.favorite_border),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (heroUrl != null)
                    CachedNetworkImage(imageUrl: heroUrl, fit: BoxFit.cover)
                  else
                    Container(color: Theme.of(context).colorScheme.surfaceContainerHigh),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: Text(
                      widget.item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              if (_loading) const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ) else ...[
                const SizedBox(height: 16),
                _buildMeta(context),
                const SizedBox(height: 20),
                if (_reviews.isNotEmpty) ...[
                  _sectionTitle(context, 'Avis de la communauté'),
                  ..._reviews.take(5).map((r) => _ReviewTile(review: r)),
                  const SizedBox(height: 12),
                ],
                if (_images.isNotEmpty) ...[
                  _sectionTitle(context, 'Galerie'),
                  const SizedBox(height: 8),
                  ImageGallery(images: _images),
                  const SizedBox(height: 20),
                ],
                if (_trailers.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _sectionTitle(context, 'Bandes-annonces'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TrailerList(trailers: _trailers),
                  ),
                ],
                if (widget.item.overview != null && widget.item.overview!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _sectionTitle(context, 'Synopsis'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                    child: Text(widget.item.overview!, style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ],
            ]),
          ),
        ],
      ),
    );
  }

  void _showFolderPicker(BuildContext context) {
    final repo = context.read<FavoritesRepository>();
    showDialog(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: const Text('Ajouter à un dossier'),
        children: repo.folders
            .map((f) => SimpleDialogOption(
                  onPressed: () async {
                    Navigator.pop(dialogContext);
                    await repo.addToFolder(f.id, widget.item);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ajouté à "${f.name}"')),
                      );
                    }
                  },
                  child: Row(
                    children: [
                      CircleAvatar(radius: 8, backgroundColor: f.color),
                      const SizedBox(width: 10),
                      Text(f.name),
                    ],
                  ),
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMeta(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (widget.item.rating != null) ...[
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            Text(widget.item.rating!.toStringAsFixed(1), style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(width: 16),
          ],
          if (widget.item.releaseDate != null)
            Text(widget.item.releaseDate!, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  final Review review;

  const _ReviewTile({required this.review});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(review.author, style: Theme.of(context).textTheme.titleSmall),
                  if (review.rating != null) ...[
                    const Spacer(),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    Text(review.rating!.toStringAsFixed(1)),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                review.content,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
