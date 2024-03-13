import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

enum VibrationMethod {
  single,
  call,
}

enum AudioType {
  call,
  receive,
}

// 提示，声音，震动
class AppPrompt {
  static Timer? _timerVibration;
  static AudioPlayer? _audioPlayer;

  // 打开震动
  static startVibration({
    VibrationMethod method = VibrationMethod.single,
  }) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
    final hasVibrator = (await Vibration.hasVibrator()) ?? false;
    if (!hasVibrator) {
      // 不支持震动
      return;
    }
    switch (method) {
      case VibrationMethod.single:
        Vibration.vibrate(duration: 1000);
        break;
      case VibrationMethod.call:
        Vibration.vibrate(duration: 1000);
        _timerVibration?.cancel();
        _timerVibration =
            Timer.periodic(const Duration(milliseconds: 2000), (timer) {
          Vibration.vibrate(duration: 1000);
        });
        break;
    }
  }

  // 关闭震动
  static stopVibration() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }
    _timerVibration?.cancel();
    Vibration.cancel();
  }

  // 播放声音
  static Future<void> startAudio({
    AudioType type = AudioType.call,
  }) async {
    String filename = 'mp3/call.mp3';
    if (type == AudioType.receive) {
      filename = 'mp3/receive.mp3';
    }
    stopAudio();
    _audioPlayer = AudioPlayer();
    _audioPlayer!.setReleaseMode(ReleaseMode.loop);
    _audioPlayer?.play(AssetSource(filename));
  }

  // 关闭声音
  static Future<void> stopAudio() async {
    _audioPlayer?.pause();
    _audioPlayer?.dispose();
    _audioPlayer = null;
  }

  // 关闭所有
  static Future<void> stopAll() async {
    stopVibration();
    stopAudio();
  }
}
