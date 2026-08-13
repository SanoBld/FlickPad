import 'package:flutter/material.dart';
import '../../models/media_item.dart';
import '../../services/movie_repository.dart';
import '../../services/game_repository.dart';
import '../../widgets/media_section.dart';
import '../details/details_screen.dart';

// Dynamic feed: latest movies, latest series, latest games
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _movieRepo = MovieRepository();
  final _gameRepo = GameRepository();

  List<MediaItem> _movies = [];
  List<MediaItem> _series = [];
  List<MediaItem> _games = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFeed();
  }

  Future<void> _loadFeed() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _movieRepo.latestMovies(),
        _movieRepo.latestSeries(),
        _gameRepo.latestGames(),
      ]);
      setState(() {
        _movies = results[0];
        _series = results[1];
        _games = results[2];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load feed';
        _loading = false;
      });
    }
  }

  void _openDetails(MediaItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailsScreen(item: item)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('FlickPad')),
      body: RefreshIndicator(
        onRefresh: _loadFeed,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? _buildError()
                : ListView(
                    children: [
                      MediaSection(title: 'Derniers films', items: _movies, onItemTap: _openDetails),
                      MediaSection(title: 'Dernières séries', items: _series, onItemTap: _openDetails),
                      MediaSection(title: 'Derniers jeux', items: _games, onItemTap: _openDetails),
                      const SizedBox(height: 24),
                    ],
                  ),
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      children: [
        const SizedBox(height: 80),
        Icon(Icons.wifi_off, size: 48, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 12),
        Center(child: Text(_error!)),
        const SizedBox(height: 12),
        Center(
          child: FilledButton(onPressed: _loadFeed, child: const Text('Réessayer')),
        ),
      ],
    );
  }
}
