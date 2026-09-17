import 'package:audioplayers/audioplayers.dart';
import 'package:cts/features/d2d/helpers/d2d_batch_membership.dart';
import 'package:flutter/foundation.dart';

/// Plays short (same-batch) / long (other-batch) board tones.
///
/// Assets: `assets/sounds/board_same.wav`, `assets/sounds/board_other.wav`.
class D2dBoardBeep {
  D2dBoardBeep({AudioPlayer? player}) : _player = player ?? AudioPlayer();

  final AudioPlayer _player;
  static D2dBoardBeep? _shared;

  static D2dBoardBeep get instance => _shared ??= D2dBoardBeep();

  @visibleForTesting
  static void bindForTest(D2dBoardBeep? beep) => _shared = beep;

  Future<void> play(D2dBoardBeepKind kind) async {
    final asset = kind == D2dBoardBeepKind.otherBatch
        ? 'sounds/board_other.wav'
        : 'sounds/board_same.wav';
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (e, st) {
      debugPrint('D2dBoardBeep: failed to play $asset: $e\n$st');
    }
  }

  Future<void> playForOtherBatch(bool isOtherBatch) =>
      play(d2dBoardBeepKind(isOtherBatch: isOtherBatch));

  Future<void> dispose() async {
    await _player.dispose();
  }
}
