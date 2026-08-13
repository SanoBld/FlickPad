import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/video_trailer.dart';

// Vertical list of playable YouTube trailers
class TrailerList extends StatelessWidget {
  final List<VideoTrailer> trailers;

  const TrailerList({super.key, required this.trailers});

  @override
  Widget build(BuildContext context) {
    if (trailers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: trailers
          .take(3) // limit to avoid loading too many players
          .map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TrailerPlayer(trailer: t),
              ))
          .toList(),
    );
  }
}

class _TrailerPlayer extends StatefulWidget {
  final VideoTrailer trailer;

  const _TrailerPlayer({required this.trailer});

  @override
  State<_TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<_TrailerPlayer> {
  late final YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.trailer.key,
      autoPlay: false,
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: YoutubePlayer(controller: _controller),
    );
  }
}