import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';

class VideoCall extends StatefulWidget {
  const VideoCall({super.key});

  static const String path = 'call/video';

  @override
  State<StatefulWidget> createState() {
    return _VideoCallState();
  }
}

class _VideoCallState extends State<VideoCall> {
  MediaStream? _localStream;
  final _localRenderer = RTCVideoRenderer();
  bool _isOpen = false;
  bool mirror = true;

  @override
  void initState() {
    _initRenderers();
    super.initState();
  }

  _initRenderers() async {
    await _localRenderer.initialize();
    _open();
  }

  _open() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user', //environment:后置摄像头。user:前置摄像头
      }
    };
    try {
      var stream = await navigator.mediaDevices.getUserMedia(mediaConstraints);
      _localStream = stream;
      _localRenderer.srcObject = _localStream;
    } catch (e) {
      logger.e(e);
    }
    if (!mounted) return;
    setState(() {
      _isOpen = true;
    });
  }

  _close() async {
    if (!mounted) return;
    try {
      await _localStream?.dispose();
      _localRenderer.srcObject = null;
    } catch (e) {
      logger.e(e);
    }
    setState(() {
      _isOpen = false;
    });
  }

  //切换摄像头
  changeCamera() async {
    var sl = _localStream!.getVideoTracks();
    logger.d(sl);
    if (sl.isNotEmpty) {
      await Helper.switchCamera(sl[0]);
      setState(() {
        mirror = !mirror;
      });
    }
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_isOpen) _close();
    _localRenderer.dispose();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            RTCVideoView(
              _localRenderer,
              mirror: mirror,
              objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
            ),
            Positioned(
              bottom: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 50),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // startStream();
                          changeCamera();
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(0, 0, 0, .3),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Image.asset(
                            assetPath('images/video_change.png'),
                            width: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () {
                          if (_isOpen) _close();
                          Navigator.pop(context);
                        },
                        child: Image.asset(
                          assetPath('images/video_stop.png'),
                          width: 50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
