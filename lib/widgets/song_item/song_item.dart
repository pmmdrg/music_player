import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:music_player_app/data/model/song.dart';
import 'package:music_player_app/screens/player_screen/player_screen.dart';

class SongItem extends StatelessWidget {
  final Song song;
  final List<Song> songs;

  const SongItem({
    super.key,
    required this.song,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(
        left: 24,
        right: 8,
      ),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: FadeInImage.assetNetwork(
          placeholder: 'assets/music-placeholder.png',
          image: song.image,
          width: 48,
          height: 48,
          imageErrorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/music-placeholder.png',
              width: 48,
              height: 48,
            );
          },
        ),
      ),
      title: Text(song.title),
      subtitle: Text(song.artist),
      trailing: IconButton(
        icon: const Icon(Icons.more_horiz),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Container(
                  height: 400,
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Bottom Sheet'),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Close Bottom Sheet'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) {
            return PlayerScreen(
              playingSong: song,
              suggestSongs: songs,
              songs: songs,
            );
          }),
        );
      },
    );
  }
}
