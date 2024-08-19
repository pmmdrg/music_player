import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import 'package:music_player_app/data/model/song.dart';

abstract interface class DataSource {
  Future<List<Song>?> loadData();
}

class RemoteDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    const String url = 'https://thantrieu.com/resources/braniumapis/songs.json';
    final Uri uri = Uri.parse(url);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final String bodyContent = utf8.decode(response.bodyBytes);

      Map songWrapper = jsonDecode(bodyContent) as Map;
      List songList = songWrapper['songs'] as List;
      List<Song> songs = songList.map((song) => Song.fromJson(song)).toList();

      return songs;
    } else {
      return null;
    }
  }
}

class LocalDataSource implements DataSource {
  @override
  Future<List<Song>?> loadData() async {
    final String response = await rootBundle.loadString('assets/songs.json');
    Map jsonBody = jsonDecode(response) as Map;
    List songList = jsonBody['songs'] as List;
    List<Song> songs = songList.map((song) => Song.fromJson(song)).toList();

    return songs;
  }
}
