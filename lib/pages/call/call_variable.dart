import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:unionchat/common/app_prompt.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/call/mini_talk_overlay.dart';
import 'package:unionchat/pages/call/signaling.dart';
import 'package:openapi/api.dart';

class CallVariable {
  static ValueNotifier<int?> msgId = ValueNotifier<int?>(null);
  static String nickname = '';
  static String avatar = '';
  static bool isSender = true;
  static Signaling? signaling;
  static RTCVideoRenderer? localRenderer;
  static RTCVideoRenderer? remoteRenderer;
  static ValueNotifier<RTCVideoView?> remoteView =
      ValueNotifier<RTCVideoView?>(null);
  static ValueNotifier<RTCVideoView?> localView =
      ValueNotifier<RTCVideoView?>(null);

  static Session? session;
  static ValueNotifier<IceState> iceStatus =
      ValueNotifier<IceState>(IceState.none);
  static List<Map<String, String>> iceServers = [];

  // 麦克风是否启用
  static ValueNotifier<bool> micMuted = ValueNotifier<bool>(false);

  // 扬声器是否启用
  static ValueNotifier<bool> loudspeaker = ValueNotifier<bool>(true);

  // 摄像头是否启用
  static ValueNotifier<bool> videoOn = ValueNotifier<bool>(true);
  static BuildContext? callContext;
  static bool isVideoCall = true;

  // 是否是自己画面视频全屏
  static ValueNotifier<bool> isSelfBig = ValueNotifier<bool>(true);
  static ValueNotifier<int> seconds = ValueNotifier<int>(0);
  static Timer? _timer;
  static Timer? _overTimeTimer;

  static Completer<void>? _closeCompleter;

  static init({
    required nickname,
    required avatar,
    required isVideo,
    int? msgId,
    int? toUserId,
  }) async {
    localRenderer = RTCVideoRenderer();
    remoteRenderer = RTCVideoRenderer();
    final List<Future> futures = [];
    isVideoCall = isVideo;
    CallVariable.loudspeaker.value = isVideo;
    CallVariable.nickname = nickname;
    CallVariable.avatar = avatar;
    if (msgId != null && msgId != 0) {
      CallVariable.msgId.value = msgId;
    }
    if (CallVariable.msgId.value == null) {
      isSender = true;
      // 当没有chatId的时候toUserId必须有值
      assert(
        toUserId != null && toUserId != 0,
        'toUserId must not be empty when chatId is empty',
      );
      assert(
        Global.loginUser?.id != null && Global.loginUser?.id != 0,
        'loginUser.id must not be empty',
      );
      assert(
        Global.loginUser!.id != toUserId,
        'loginUser.id must not be equal to toUserId',
      );
      futures.add(() async {
        // 发送消息
        final pairId = generatePairId(Global.loginUser!.id, toUserId!);
        final type =
            isVideo ? GMessageType.VIDEO_CALL : GMessageType.AUDIO_CALL;
        var msg = Message.forSend(toUserId, pairId, type);
        await MessageUtil.send(msg);
        CallVariable.msgId.value = msg.id;
      }());
    } else {
      isSender = false;
    }
    localRenderer = RTCVideoRenderer();
    remoteRenderer = RTCVideoRenderer();
    futures.add(localRenderer!.initialize());
    futures.add(remoteRenderer!.initialize());
    futures.add(_getTurnCredential());
    await Future.wait(futures);
    if (isSender) {
      AppPrompt.startAudio(); // 播放等待接听音乐
      _overTimeTimer?.cancel();
      _overTimeTimer = Timer.periodic(
        const Duration(seconds: 30),
        (timer) {
          if (iceStatus.value == IceState.none) hangUp();
        },
      );
    }
    _connect();
  }

  // 切换前后摄像头
  static switchCamera() {
    signaling?.switchCamera(localRenderer!.srcObject);
  }

  // 切换扬声器
  static Future<void> switchAudioplayers(bool value) async {
    MediaStreamTrack? track =
        remoteRenderer?.srcObject?.getAudioTracks().firstOrNull;
    track?.enableSpeakerphone(value);
    logger.d('-------- switchAudioplayers $value $track');
    loudspeaker.value = value;
  }

  // 打开关闭摄像头
  static switchCameraOn() {
    // 开启本地摄像头
    videoOn.value = signaling?.switchCameraOn(localRenderer!.srcObject) ?? true;
  }

  static Future<void> muteMic() async {
    if (iceStatus.value == IceState.connected) {
      micMuted.value = signaling!.switchMuteMic();
    } else {
      micMuted.value = !micMuted.value;
    }
  }

  // 连接状态
  static void _connect() async {
    signaling ??= Signaling(null, iceServers)..connect();
    signaling?.onIceState = (state) {
      logger.d('-------- onIceState $state');
      if (state == IceState.connected) {
        // 当连接成功的时候设置是否扬声器播放
        switchAudioplayers(CallVariable.loudspeaker.value);
      }
      iceStatus.value = state;
    };

    signaling?.onCallStateChange = (Session? s, CallState state) async {
      logger.d('-------- onCallStateChange $state');
      switch (state) {
        case CallState.callStateInvite:
          session = s;
          break;
        //响铃
        case CallState.callStateRinging:
          session = s;
          accept();
          break;
        case CallState.callStateBye:
          await hangUp(senderBye: false);
          break;
        case CallState.callStateConnected:
          break;
      }
    };
    signaling?.onLocalStream = ((stream) {
      localRenderer!.srcObject = stream;
      localView.value ??= RTCVideoView(
        localRenderer!,
        mirror: true,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      );
    });

    signaling?.onAddRemoteStream = ((_, stream) {
      logger.d('-------- onAddRemoteStream $stream');
      remoteRenderer!.srcObject = stream;
      remoteView.value ??= RTCVideoView(
        remoteRenderer!,
        objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
      );
    });

    signaling?.onRemoveRemoteStream = ((_, stream) {
      logger.d('-------- onRemoveRemoteStream $stream');
      remoteRenderer!.srcObject = null;
    });
    // 开启本地摄像头
    if (isVideoCall) {
      signaling!.createStream(Media.video, false);
    }
    // 打开麦克风
    micMuted.value = signaling!.switchMuteMic();
    if (!isSender) {
      // 发起offer
      signaling!.invite(
        msgId.value!,
        isVideoCall ? Media.video : Media.audio,
        false,
      );
      AppPrompt.stopAll();
      startTimer();
      // isCalling.value = !isCalling.value;
    }
  }

  //接听
  static accept() async {
    if (session != null) {
      signaling?.accept(session!.sessionId, Media.video);
      AppPrompt.stopAll();
      startTimer();
      if (signaling!.muteMic() == micMuted.value) {
        return;
      } else {
        micMuted.value = signaling!.switchMuteMic();
      }
    }
  }

  // 挂断
  static Future<void> hangUp({senderBye = true}) async {
    if (callContext != null && callContext!.mounted) {
      if (callContext != null) Navigator.of(callContext!).pop();
    }
    MiniTalk.close();
    if (senderBye) {
      if (session != null) {
        signaling?.bye(session!.sessionId);
      } else {
        if (msgId.value != null) {
          MessageUtil.signaler(GNegotiation(
            sessionId: msgId.value.toString(),
            type: GSignalertType.BYE,
          ));
        }
      }
    }
    await close();
  }

  // 获取turn服务凭证
  static Future<void> _getTurnCredential() async {
    var api = MessageApi(apiClient());
    final resp = await api.messageTURNCredentials({});
    iceServers.clear();
    for (TURNCredentialsRespIceServers element in resp?.iceServers ?? []) {
      iceServers.add({
        'urls': element.urls ?? '',
        'username': element.username ?? '',
        'credential': element.credential ?? '',
      });
    }
  }

  // 开始计时
  static startTimer() {
    seconds.value = 0;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      seconds.value++;
    });
  }

  static Future<void> close() async {
    if (_closeCompleter != null && !_closeCompleter!.isCompleted) {
      return _closeCompleter!.future;
    }
    _closeCompleter = Completer<void>();
    await signaling?.close();
    signaling = null;
    await localRenderer?.dispose();
    localRenderer = null;
    await remoteRenderer?.dispose();
    remoteRenderer = null;
    signaling = null;
    remoteView.value = null;
    localView.value = null;
    session = null;
    micMuted.value = false;
    loudspeaker.value = true;
    videoOn.value = true;
    isVideoCall = true;
    isSelfBig.value = true;
    seconds.value = 0;
    iceStatus.value = IceState.none;
    msgId.value = null;
    _timer?.cancel();
    _timer = null;
    _overTimeTimer?.cancel();
    _overTimeTimer = null;
    iceServers.clear();
    await AppPrompt.stopAll();
    _closeCompleter!.complete();
    _closeCompleter = null;
  }
}
