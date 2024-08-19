import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

import 'package:music_player_app/data/model/song.dart';
import 'package:music_player_app/screens/player_screen/audio_manager.dart';
import 'package:music_player_app/widgets/loading_indicator/loading_indicator.dart';
import 'package:music_player_app/widgets/media_controller/media_controller.dart';

class PlayerScreen extends StatefulWidget {
  final Song playingSong;
  final List<Song> suggestSongs;
  final List<Song> songs;

  const PlayerScreen({
    super.key,
    required this.playingSong,
    required this.suggestSongs,
    required this.songs,
  });

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen>
    with SingleTickerProviderStateMixin {
  AnimationController? animationController;
  AudioManager? audioManager;
  int? selectedIndex;
  Song? currentSong;
  double? currentAnimPosition;
  bool isShuffle = false;
  LoopMode? loopMode;

  void handleRotateDisk(double position) {
    animationController!.forward(from: position);
    animationController!.repeat();
  }

  void handleNextSong() {
    setState(() {
      if (isShuffle) {
        var random = Random();
        selectedIndex = random.nextInt(widget.songs.length);
      } else if (loopMode == LoopMode.all &&
          selectedIndex == widget.songs.length - 1) {
        selectedIndex = 0;
      } else {
        selectedIndex = selectedIndex! + 1;
      }

      if (selectedIndex! >= widget.songs.length) {
        selectedIndex = selectedIndex! % widget.songs.length;
      }

      currentSong = widget.songs[selectedIndex!];

      audioManager!.init(currentSong!.source, isNewSong: true);
      audioManager!.player.play();

      currentAnimPosition = 0.0;
      handleRotateDisk(currentAnimPosition!);
    });
  }

  void handlePrevSong() {
    setState(() {
      if (isShuffle) {
        var random = Random();
        selectedIndex = random.nextInt(widget.songs.length);
      } else if (loopMode == LoopMode.all && selectedIndex == 0) {
        selectedIndex = widget.songs.length - 1;
      } else {
        selectedIndex = selectedIndex! - 1;
      }

      if (selectedIndex! < 0) {
        selectedIndex = (-1 * selectedIndex!) % widget.songs.length;
      }

      currentSong = widget.songs[selectedIndex!];

      audioManager!.init(currentSong!.source, isNewSong: true);
      audioManager!.player.play();

      currentAnimPosition = 0.0;
      handleRotateDisk(currentAnimPosition!);
    });
  }

  @override
  void initState() {
    super.initState();

    currentAnimPosition = 0.0;
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 12000),
    );
    handleRotateDisk(currentAnimPosition!);

    selectedIndex = widget.songs.indexOf(widget.playingSong);
    currentSong = widget.playingSong;

    audioManager = AudioManager();
    if (audioManager!.url.compareTo(currentSong!.source) != 0) {
      audioManager!.init(currentSong!.source, isNewSong: true);
      audioManager!.player.play();
    } else {
      audioManager!.init(currentSong!.source);
      audioManager!.player.play();
    }

    loopMode = LoopMode.off;
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const delta = 64;
    final screenWidth = MediaQuery.of(context).size.width;
    final radius = (screenWidth - delta) / 2;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Now Playing'),
        trailing: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.more_horiz),
        ),
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                currentSong!.album,
              ),
              const SizedBox(
                height: 16,
              ),
              const Text(
                '_ ___ _',
              ),
              const SizedBox(
                height: 48,
              ),
              RotationTransition(
                turns:
                    Tween(begin: 0.0, end: 1.0).animate(animationController!),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/music-placeholder.png',
                    image: currentSong!.image,
                    width: screenWidth - delta,
                    height: screenWidth - delta,
                    imageErrorBuilder: (context, error, stackTrace) {
                      return Image.asset(
                        'assets/music-placeholder.png',
                        width: screenWidth - delta,
                        height: screenWidth - delta,
                      );
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 64, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.share_outlined),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Column(
                      children: [
                        Text(currentSong!.title),
                        const SizedBox(
                          height: 8,
                        ),
                        Text(currentSong!.artist),
                      ],
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite_outline),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 32,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                child: StreamBuilder(
                  stream: audioManager!.durationState,
                  builder: (context, snapshot) {
                    final durationState = snapshot.data;
                    final progress = durationState?.progress ?? Duration.zero;
                    final buffer = durationState?.buffer ?? Duration.zero;
                    final total = durationState?.total ?? Duration.zero;

                    return ProgressBar(
                      progress: progress,
                      total: total,
                      buffered: buffer,
                      onSeek: audioManager?.player.seek,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 0,
                  left: 24,
                  right: 24,
                  bottom: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    MediaController(
                      action: () {
                        setState(() {
                          isShuffle = !isShuffle;
                        });
                      },
                      icon: Icons.shuffle,
                      color: isShuffle ? Colors.deepPurple : Colors.grey,
                      size: 24,
                    ),
                    MediaController(
                      action: handlePrevSong,
                      icon: Icons.skip_previous,
                      color: Colors.deepPurple,
                      size: 36,
                    ),
                    StreamBuilder(
                      stream: audioManager?.player.playerStateStream,
                      builder: (context, snapshot) {
                        final playState = snapshot.data;
                        final processState = playState?.processingState;
                        final playing = playState?.playing;

                        if (processState == ProcessingState.loading ||
                            processState == ProcessingState.buffering) {
                          return Container(
                            margin: const EdgeInsets.all(8),
                            width: 48,
                            height: 48,
                            child: const LoadingIndicator(),
                          );
                        } else if (playing == false) {
                          return MediaController(
                            action: () {
                              audioManager?.player.play();
                              handleRotateDisk(currentAnimPosition!);
                            },
                            icon: Icons.play_arrow,
                            color: Colors.deepPurple,
                            size: 48,
                          );
                        } else if (processState != ProcessingState.completed) {
                          return MediaController(
                            action: () {
                              audioManager?.player.pause();
                              animationController!.stop();
                              currentAnimPosition = animationController!.value;
                            },
                            icon: Icons.pause,
                            color: Colors.deepPurple,
                            size: 48,
                          );
                        } else {
                          if (processState == ProcessingState.completed) {
                            animationController!.stop();
                          }
                          return MediaController(
                            action: () {
                              audioManager?.player.seek(Duration.zero);
                              handleRotateDisk(currentAnimPosition!);
                            },
                            icon: Icons.replay,
                            color: Colors.deepPurple,
                            size: 48,
                          );
                        }
                      },
                    ),
                    MediaController(
                      action: handleNextSong,
                      icon: Icons.skip_next,
                      color: Colors.deepPurple,
                      size: 36,
                    ),
                    MediaController(
                      action: () {
                        if (loopMode == LoopMode.all) {
                          loopMode = LoopMode.one;
                        } else if (loopMode == LoopMode.one) {
                          loopMode = LoopMode.off;
                        } else {
                          loopMode = LoopMode.all;
                        }

                        setState(() {
                          audioManager?.player.setLoopMode(loopMode!);
                        });
                      },
                      icon: loopMode == LoopMode.one
                          ? Icons.repeat_one
                          : Icons.repeat,
                      color: loopMode != LoopMode.off
                          ? Colors.deepPurple
                          : Colors.grey,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
