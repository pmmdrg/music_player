import 'package:rxdart/rxdart.dart';
import 'package:just_audio/just_audio.dart';

class DurationState {
  final Duration progress;
  final Duration? total;
  final Duration buffer;

  const DurationState({
    required this.progress,
    required this.buffer,
    this.total,
  });
}

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  final player = AudioPlayer();
  Stream<DurationState>? durationState;
  String url = "";

  AudioManager._internal();

  factory AudioManager() {
    return _instance;
  }

  void init(String songUrl, {bool isNewSong = false}) {
    durationState = Rx.combineLatest2(
      player.positionStream,
      player.playbackEventStream,
      (position, playbackEvent) => DurationState(
        progress: position,
        buffer: playbackEvent.bufferedPosition,
        total: playbackEvent.duration,
      ),
    );
    if (isNewSong) {
      url = songUrl;
      player.setUrl(songUrl);
    }
  }

  void dispose() {
    player.dispose();
  }
}
