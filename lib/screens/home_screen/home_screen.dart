import 'dart:async';

import 'package:flutter/material.dart';

import 'package:music_player_app/data/model/song.dart';
import 'package:music_player_app/data/repository/repository.dart';
import 'package:music_player_app/screens/player_screen/audio_manager.dart';
import 'package:music_player_app/widgets/loading_indicator/loading_indicator.dart';
import 'package:music_player_app/widgets/song_item/song_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Song> songs = [];
  StreamController<List<Song>> songStream = StreamController();

  void loadSongs() {
    final repository = DefaultRepository();
    repository.loadData().then((song) => songStream.add(song!));
  }

  @override
  void initState() {
    loadSongs();
    observeData();
    super.initState();
  }

  void observeData() {
    songStream.stream.listen((songList) {
      setState(() {
        songs.addAll(songList);
      });
    });
  }

  @override
  void dispose() {
    songStream.close();
    AudioManager().dispose();
    super.dispose();
  }

  ListView listSong() {
    return ListView.separated(
      itemBuilder: (context, index) {
        return SongItem(
          song: songs[index],
          songs: songs,
        );
      },
      separatorBuilder: (context, index) {
        return const Divider(
          color: Colors.grey,
          thickness: 1,
          indent: 24,
          endIndent: 24,
        );
      },
      itemCount: songs.length,
      shrinkWrap: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: songs.isEmpty ? const LoadingIndicator() : listSong(),
    );
  }
}
