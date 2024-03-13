import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/screen_select_dialog.dart';
import 'package:unionchat/message/sse_stream.dart';
import 'package:unionchat/pages/call/call_variable.dart';
import 'package:openapi/api.dart';

enum Media {
  audio,
  video,
  data,
}

enum IceState {
  none,
  checking,
  connected,
  close,
}

extension MediaExtension on Media {
  String get name => toString().split('.').last;

  static Media fromString(String name) {
    return Media.values.firstWhere((e) => e.name == name);
  }
}

enum CallState {
  callStateRinging,
  callStateInvite,
  callStateConnected,
  callStateBye,
}

enum VideoSource {
  camera,
  screen,
}

// 一个通话session
class Session {
  Session({required this.sessionId});
  String sessionId;
  RTCPeerConnection? pc;
  RTCDataChannel? dc;
  List<RTCIceCandidate> remoteCandidates = [];
  final StreamController<RTCIceCandidate> _candidateConsole =
      StreamController<RTCIceCandidate>();
}

// 信令
class Signaling {
  final List<Map<String, String>> iceServers;

  Signaling(this.context, this.iceServers);
  final BuildContext? context;
  final Map<String, Session> _sessions = {};
  MediaStream? _localStream;
  final List<MediaStream> _remoteStreams = <MediaStream>[];
  final List<RTCRtpSender> _senders = <RTCRtpSender>[];
  VideoSource _videoSource = VideoSource.camera;

  Function(IceState state)? onIceState;
  Function(Session? session, CallState state)? onCallStateChange;
  Function(MediaStream stream)? onLocalStream;
  Function(Session session, MediaStream stream)? onAddRemoteStream;
  Function(Session session, MediaStream stream)? onRemoveRemoteStream;
  Function(Session session, RTCDataChannel dc, RTCDataChannelMessage data)?
      onDataChannelMessage;
  Function(Session session, RTCDataChannel dc)? onDataChannel;

  String get sdpSemantics => 'unified-plan';

  StreamSubscription<GNegotiation>? _negotiationSubscription;

  final Map<String, dynamic> _config = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ]
  };

  final Map<String, dynamic> _dcConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': false,
      'OfferToReceiveVideo': false,
    },
    'optional': [],
  };

  connect() {
    _negotiationSubscription?.cancel();
    _negotiationSubscription =
        SSEStream.signalerController.stream.listen((event) {
      onMessage(event);
    });
  }

  close() async {
    await _negotiationSubscription?.cancel();
    await _cleanSessions();
  }

  // 切换摄像头
  void switchCamera(MediaStream? activeStream) {
    _localStream ??= activeStream;
    if (_localStream != null) {
      if (_videoSource != VideoSource.camera) {
        for (var sender in _senders) {
          if (sender.track!.kind == 'video') {
            sender.replaceTrack(_localStream!.getVideoTracks()[0]);
          }
        }
        _videoSource = VideoSource.camera;
        onLocalStream?.call(_localStream!);
      } else {
        Helper.switchCamera(_localStream!.getVideoTracks()[0]);
      }
    }
  }

  // 打开关闭摄像头
  bool switchCameraOn(MediaStream? activeStream) {
    _localStream ??= activeStream;

    //    _localStream!.getVideoTracks()[0].enabled = false;
    if (_localStream != null) {
      bool enabled = _localStream!.getVideoTracks()[0].enabled;
      _localStream!.getVideoTracks()[0].enabled = !enabled;
    }

    return _localStream!.getVideoTracks()[0].enabled;
  }

  // 分享屏幕
  void switchToScreenSharing(MediaStream stream) {
    if (_localStream != null && _videoSource != VideoSource.screen) {
      for (var sender in _senders) {
        if (sender.track!.kind == 'video') {
          sender.replaceTrack(stream.getVideoTracks()[0]);
        }
      }
      onLocalStream?.call(stream);
      _videoSource = VideoSource.screen;
    }
  }

  // 开启关闭麦克风
  bool muteMic() {
    if (_localStream != null) {
      bool enabled = _localStream!.getAudioTracks()[0].enabled;
      return enabled;
    }
    return true;
  }

  bool switchMuteMic() {
    if (_localStream != null) {
      bool enabled = _localStream!.getAudioTracks()[0].enabled;
      _localStream!.getAudioTracks()[0].enabled = !enabled;
      return !enabled;
    }
    return true;
  }

  // 开启关闭扬声器
  bool volume() {
    if (_localStream != null) {
      bool enabled = _localStream!.getAudioTracks()[0].enabled;
      _localStream!.getAudioTracks()[0].enabled = !enabled;
      return !enabled;
    }
    return true;
  }

  // 邀请通话
  // @to 另一个用户id
  // @media video
  Future<void> invite(int msgId, Media media, bool useScreen) async {
    Session session = await _createSession(
      null,
      sessionId: msgId.toString(),
      media: media,
      screenSharing: useScreen,
    );
    _sessions['$msgId'] = session;
    if (media == Media.data) {
      _createDataChannel(session);
    }
    await _createOffer(session, media);
    onCallStateChange?.call(session, CallState.callStateInvite);
  }

  void bye(String sessinId) {
    MessageUtil.signaler(
      GNegotiation(type: GSignalertType.BYE, sessionId: sessinId),
    );
    // await _cleanSessions();
  }

  void accept(String sessionId, Media media) {
    var session = _sessions[sessionId];
    if (session == null) {
      return;
    }
    _createAnswer(session, media);
  }

  void reject(String sessionId) {
    var session = _sessions[sessionId];
    if (session == null) {
      return;
    }
    bye(session.sessionId);
  }

  void onMessage(GNegotiation negotiation) async {
    var session = _sessions[negotiation.sessionId];
    switch (negotiation.type) {
      case GSignalertType.OFFER:
        {
          var newSession = await _createSession(
            session,
            sessionId: negotiation.sessionId!,
            media: MediaExtension.fromString(negotiation.media!),
            screenSharing: false,
          );
          _sessions[newSession.sessionId] = newSession;
          await newSession.pc?.setRemoteDescription(RTCSessionDescription(
            negotiation.description!.sdp!,
            negotiation.description!.type!,
          ));
          if (newSession.remoteCandidates.isNotEmpty) {
            for (var candidate in newSession.remoteCandidates) {
              await newSession.pc?.addCandidate(candidate);
            }
            newSession.remoteCandidates.clear();
          }
          _signalerCandidate(newSession);
          onCallStateChange?.call(newSession, CallState.callStateRinging);
        }
        break;
      case GSignalertType.ANSWER:
        session?.pc?.setRemoteDescription(RTCSessionDescription(
          negotiation.description!.sdp!,
          negotiation.description!.type!,
        ));
        if (session != null) {
          _signalerCandidate(session);
          onCallStateChange?.call(session, CallState.callStateConnected);
        }
        break;
      case GSignalertType.CANDIDATE:
        {
          var session = _sessions[negotiation.sessionId];
          RTCIceCandidate candidate = RTCIceCandidate(
            negotiation.candidate!.candidate,
            negotiation.candidate!.sdpMid,
            negotiation.candidate!.sdpMlineIndex,
          );
          if (session != null) {
            if (session.pc != null) {
              await session.pc?.addCandidate(candidate);
            } else {
              session.remoteCandidates.add(candidate);
            }
          } else {
            _sessions[negotiation.sessionId!] =
                Session(sessionId: negotiation.sessionId!)
                  ..remoteCandidates.add(candidate);
          }
        }
        break;
      case GSignalertType.BYE:
        onCallStateChange?.call(session, CallState.callStateBye);
        break;
      case GSignalertType.KEEPALIVE:
        {
          logger.d('keep-alive response!');
        }
        break;
      default:
        break;
    }
  }

  Completer<void>? _completer;

  Future<void> createStream(
    Media media,
    bool userScreen, {
    BuildContext? context,
  }) {
    if (_completer == null || _completer!.isCompleted) {
      _completer = Completer<void>();
      dynamic video = true;
      if (userScreen) {
        video = true;
      } else if (media == Media.video) {
        video = {
          'mandatory': {
            'minWidth':
                '640', // Provide your own width, height and frame rate here
            'minHeight': '480',
            'minFrameRate': '30',
          },
          'facingMode': 'user',
          'optional': [],
        };
      } else {
        video = false;
      }
      final Map<String, dynamic> mediaConstraints = {
        'audio': userScreen ? false : true,
        'video': video
      };
      late MediaStream stream;
      if (userScreen) {
        logger.d('getUserMediauserScreen: $mediaConstraints');
        if (WebRTC.platformIsDesktop) {
          showDialog<DesktopCapturerSource>(
            context: context!,
            builder: (context) => ScreenSelectDialog(),
          ).then((source) async {
            stream =
                await navigator.mediaDevices.getDisplayMedia(<String, dynamic>{
              'video': source == null
                  ? true
                  : {
                      'deviceId': {'exact': source.id},
                      'mandatory': {'frameRate': 30.0}
                    }
            });
            _localStream = stream;
            onLocalStream?.call(stream);
            _completer!.complete();
          });
        } else {
          navigator.mediaDevices
              .getDisplayMedia(mediaConstraints)
              .then((MediaStream strm) {
            stream = strm;
            _localStream = stream;
            onLocalStream?.call(stream);
            _completer!.complete();
          });
        }
      } else {
        navigator.mediaDevices
            .getUserMedia(mediaConstraints)
            .then((MediaStream strm) {
          stream = strm;
          _localStream = stream;
          onLocalStream?.call(stream);
          _completer!.complete();
        });
      }
    }

    return _completer!.future;
  }

  Future<Session> _createSession(
    Session? s, {
    required String sessionId,
    required Media media,
    required bool screenSharing,
  }) async {
    var session = s ?? Session(sessionId: sessionId);
    if (media != Media.data) {
      if (_localStream == null) {
        await createStream(media, screenSharing);
      }
    }
    RTCPeerConnection pc = await createPeerConnection(
      {
        ...{
          'iceServers': iceServers,
        },
        ...{
          'sdpSemantics': sdpSemantics,
        }
      },
      _config,
    );
    if (media != Media.data) {
      switch (sdpSemantics) {
        case 'plan-b':
          pc.onAddStream = (MediaStream stream) {
            logger.d('onTrack: remote stream0');
            onAddRemoteStream?.call(session, stream);
            _remoteStreams.add(stream);
          };
          await pc.addStream(_localStream!);
          break;
        case 'unified-plan':
          // Unified-Plan
          pc.onTrack = (event) {
            MediaStreamTrack? track =
                event.streams[0].getAudioTracks().firstOrNull;
            if (event.track.kind == 'video') {
              logger.d(
                  'onTrack: remote stream1: ${CallVariable.loudspeaker.value} $track ');
              onAddRemoteStream?.call(session, event.streams[0]);
              // 视频默认打开扬声器
              track?.enableSpeakerphone(CallVariable.loudspeaker.value);
            } else {
              logger.d(
                  'onTrack: remote stream2: ${CallVariable.loudspeaker.value} $track ');
              onAddRemoteStream?.call(session, event.streams[0]);
              // 语音关闭扬声器
              track?.enableSpeakerphone(CallVariable.loudspeaker.value);
            }
          };
          _localStream!.getTracks().forEach((track) async {
            _senders.add(await pc.addTrack(track, _localStream!));
          });
          break;
      }
    }

    pc.onIceCandidate = (candidate) async {
      session._candidateConsole.add(candidate);
    };

    pc.onIceConnectionState = (state) async {
      switch (state) {
        case RTCIceConnectionState.RTCIceConnectionStateNew:
          onIceState?.call(IceState.checking);
          break;
        case RTCIceConnectionState.RTCIceConnectionStateChecking:
          onIceState?.call(IceState.checking);
          break;
        case RTCIceConnectionState.RTCIceConnectionStateCompleted:
          onIceState?.call(IceState.connected);
          break;
        case RTCIceConnectionState.RTCIceConnectionStateConnected:
          onIceState?.call(IceState.connected);
          break;
        case RTCIceConnectionState.RTCIceConnectionStateCount:
          break;
        case RTCIceConnectionState.RTCIceConnectionStateFailed:
          onIceState?.call(IceState.close);
          break;
        case RTCIceConnectionState.RTCIceConnectionStateDisconnected:
          onIceState?.call(IceState.close);
          break;
        case RTCIceConnectionState.RTCIceConnectionStateClosed:
          onIceState?.call(IceState.close);
          break;
      }
    };

    pc.onRemoveStream = (stream) {
      onRemoveRemoteStream?.call(session, stream);
      _remoteStreams.removeWhere((it) {
        return (it.id == stream.id);
      });
    };
    pc.onDataChannel = (channel) {
      _addDataChannel(session, channel);
    };
    session.pc = pc;
    return session;
  }

  _signalerCandidate(Session session) {
    session._candidateConsole.stream.listen((candidate) async {
      await Future.delayed(const Duration(seconds: 1));
      MessageUtil.signaler(GNegotiation(
        type: GSignalertType.CANDIDATE,
        sessionId: session.sessionId,
        candidate: GCandidate(
          sdpMlineIndex: candidate.sdpMLineIndex,
          sdpMid: candidate.sdpMid,
          candidate: candidate.candidate,
        ),
      ));
    });
  }

  void _addDataChannel(Session session, RTCDataChannel channel) {
    channel.onDataChannelState = (e) {};
    channel.onMessage = (RTCDataChannelMessage data) {
      onDataChannelMessage?.call(session, channel, data);
    };
    session.dc = channel;
    onDataChannel?.call(session, channel);
  }

  Future<void> _createDataChannel(Session session,
      {label = 'fileTransfer'}) async {
    RTCDataChannelInit dataChannelDict = RTCDataChannelInit()
      ..maxRetransmits = 30;
    RTCDataChannel channel =
        await session.pc!.createDataChannel(label, dataChannelDict);
    _addDataChannel(session, channel);
  }

  Future<void> _createOffer(Session session, Media media) async {
    RTCSessionDescription s = await session.pc!.createOffer({});
    await session.pc!.setLocalDescription(_fixSdp(s));
    MessageUtil.signaler(GNegotiation(
      type: GSignalertType.OFFER,
      sessionId: session.sessionId,
      description: GDescription(sdp: s.sdp, type: s.type),
      media: media.name,
    ));
  }

  RTCSessionDescription _fixSdp(RTCSessionDescription s) {
    var sdp = s.sdp;
    s.sdp =
        sdp!.replaceAll('profile-level-id=640c1f', 'profile-level-id=42e032');
    return s;
  }

  Future<void> _createAnswer(Session session, Media media) async {
    try {
      RTCSessionDescription s = await session.pc!.createAnswer(
        media == Media.video ? _dcConstraints : {},
      );
      await session.pc!.setLocalDescription(_fixSdp(s));
      MessageUtil.signaler(GNegotiation(
        type: GSignalertType.ANSWER,
        sessionId: session.sessionId,
        description: GDescription(sdp: s.sdp, type: s.type),
        media: media.name,
      ));
    } catch (e) {
      logger.e(e);
    }
  }

  Future<void> _cleanSessions() async {
    if (_localStream != null) {
      _localStream!.getTracks().forEach((element) async {
        await element.stop();
      });
      _localStream = null;
    }
    for (var stream in _remoteStreams) {
      stream.getTracks().forEach((element) async {
        await element.stop();
      });
    }
    _sessions.forEach((key, sess) async {
      await sess.pc?.close();
      await sess.dc?.close();
    });
    _sessions.clear();
  }
}
