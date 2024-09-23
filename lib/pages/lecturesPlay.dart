import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class LecturePlay extends StatefulWidget {
  final String videoId;
  const LecturePlay({super.key, required this.videoId});

  @override
  State<LecturePlay> createState() => _LecturePlayState();
}

class _LecturePlayState extends State<LecturePlay> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      params: const YoutubePlayerParams(
          showControls: false, showFullscreenButton: true),
    );
    _controller.toggleFullScreen(lock: true);
    _controller.loadVideoById(
      videoId: widget.videoId,
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            // title: const Text('Lecture Play'),
            ),
        body: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: YoutubePlayer(
            controller: _controller,
          ),
        ));
  }
}
