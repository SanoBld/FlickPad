import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/media_item.dart';
import '../../services/movie_repository.dart';
import '../../services/game_repository.dart';
import '../../widgets/media_card.dart';
import '../details/details_screen.dart';

// Unified search across movies/series and games APIs simultaneously
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _movieRepo = MovieRepository();
  final _gameRepo = GameRepository();
  final _controller = TextEditingController();
  Timer? _debounce;

  List<MediaItem> _results = [];
  bool _loading = false;
  String _query = '';

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () => _runSearch(value));
  }

  Future<void> _runSearch(String value) async {
    final query = value.trim();
    setState(() => _query = query);
    if (query.isEmpty) {
      setState(() => _results = []);
      return;
    }

    setState(() => _loading = true);
    try {
      // Query both APIs simultaneously
      final results = await Future.wait([
        _movieRepo.search(query),
        _gameRepo.search(query),
      ]);
      if (!mounted || _query != query) return;
      setState(() {
        _results = [...results[0], ...results[1]];
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _openDetails(MediaItem item) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetailsScreen(item: item)),
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          onChanged: _onChanged,
          autofocus: false,
          decoration: const InputDecoration(
            hintText: 'Films, séries, jeux...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_query.isEmpty) {
      return const Center(child: Text('Recherchez un film, une série ou un jeu'));
    }
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_results.isEmpty) {
      return const Center(child: Text('Aucun résultat'));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: _results.length,
      itemBuilder: (context, i) => MediaCard(
        item: _results[i],
        width: double.infinity,
        onTap: () => _openDetails(_results[i]),
      ),
    );
  }
}
