import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/call/call_variable.dart';
import 'package:unionchat/pages/call/signaling.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

// 视频语音电话
class Calling extends StatefulWidget {
  const Calling({super.key});

  @override
  State<Calling> createState() => _CallingState();
}

class _CallingState extends State<Calling> with SingleTickerProviderStateMixin {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    CallVariable.callContext = context;
  }

  @override
  void dispose() {
    super.dispose();
    logger.d('calling-dispose');
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return ValueListenableBuilder(
        valueListenable: CallVariable.msgId,
        builder: (context, msgId, _) {
          return Scaffold(
            backgroundColor: myColors.textBlack,
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: ValueListenableBuilder(
              valueListenable: CallVariable.iceStatus,
              builder: (context, value, child) {
                var text = '等待接听...';
                switch (value) {
                  case IceState.none:
                    break;
                  case IceState.checking:
                    text = '连接中';
                    break;
                  case IceState.connected:
                    text = '';
                    break;
                  case IceState.close:
                    text = '已断开';
                    break;
                }
                return CallVariable.isVideoCall
                    ? createVideoBottomMenu(text)
                    : createVoiceBottomMenu(text);
              },
            ),
            body: WillPopScope(
              onWillPop: () async => false,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                      image: ExactAssetImage(assetPath('images/my/bg0.png')),
                      fit: BoxFit.cover,
                    )),
                    child: OrientationBuilder(
                      builder: (context, orientation) {
                        return ValueListenableBuilder(
                          valueListenable: CallVariable.isSelfBig,
                          builder: (context, value, child) =>
                              CallVariable.isVideoCall
                                  ? _createVideoView(value)
                                  : _createVoiceCall(value),
                        );
                      },
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: SafeArea(
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: Icon(
                          Icons.filter_none,
                          color: myColors.white,
                        ),
                        iconSize: 25,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topCenter,
                    child: SafeArea(
                      child: ValueListenableBuilder(
                        valueListenable: CallVariable.seconds,
                        builder: (context, value, _) => Text(
                          '${second2minute(value)}',
                          style: TextStyle(color: myColors.white),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  //视频的通话界面 自己的画面 全屏
  Widget _createVideoView(bool isSelfBig) {
    var myColors = ThemeNotifier();
    return ValueListenableBuilder(
      valueListenable: CallVariable.localView,
      builder: (context, localView, child) => ValueListenableBuilder(
        valueListenable: CallVariable.remoteView,
        builder: (context, remoteView, child) {
          RTCVideoView? fullView;
          RTCVideoView? topView;
          if (isSelfBig) {
            fullView = localView;
            topView = remoteView;
          } else {
            fullView = remoteView;
            topView = localView;
          }
          return ValueListenableBuilder(
            valueListenable: CallVariable.iceStatus,
            builder: (BuildContext context, status, Widget? child) {
              return Stack(
                children: <Widget>[
                  //  自己的画面
                  child!,
                  // 远程画面
                  if (status == IceState.connected) ...[
                    Positioned(
                      right: 20.0,
                      top: 80.0,
                      child: Container(
                        width: 100,
                        height: 150,
                        decoration: const BoxDecoration(color: Colors.black),
                        child: Stack(
                          children: [
                            topView ?? Container(),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20.0,
                      top: 80.0,
                      child: GestureDetector(
                        child: Container(
                          color: Colors.transparent,
                          width: 100.0,
                          height: 150.0,
                        ),
                        onTap: () {
                          CallVariable.isSelfBig.value = !isSelfBig;
                        },
                      ),
                    ),
                  ]
                ],
              );
            },
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              decoration: BoxDecoration(color: myColors.textBlack),
              child: fullView,
            ),
          );
        },
      ),
    );
  }

  Widget _createVoiceCall(bool isSelfBig) {
    return ValueListenableBuilder(
      valueListenable: CallVariable.iceStatus,
      builder: (BuildContext context, IceState status, Widget? child) => Stack(
        children: <Widget>[
          if (status != IceState.none && isSelfBig)
            Positioned(
              right: 20.0,
              top: 80.0,
              child: GestureDetector(
                child: Container(
                  color: Colors.transparent,
                  width: 100.0,
                  height: 150.0,
                ),
                onTap: () {
                  CallVariable.isSelfBig.value = !isSelfBig;
                },
              ),
            ),
          if (status == IceState.connected)
            Positioned(
              right: 20.0,
              left: 20,
              top: 100.0,
              child: createHeader(),
            )
        ],
      ),
    );
  }

  // 底部的功能按钮
  Widget createVideoBottomMenu(String text) {
    var myColors = ThemeNotifier();
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: Container(
        height: 200,
        constraints: const BoxConstraints(maxWidth: 450),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: myColors.textGrey,
                fontSize: 17,
              ),
            ),
            const SizedBox(
              height: 40.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                _editBtn(
                  btn: FloatingActionButton(
                    heroTag: 'switchCamera',
                    onPressed: CallVariable.switchCamera,
                    tooltip: 'SwitchCamera',
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.flip_camera_ios_outlined,
                      color: myColors.textBlack,
                    ),
                  ),
                  text: '翻转摄像头',
                  color: Colors.white,
                ),
                _editBtn(
                  btn: FloatingActionButton(
                    heroTag: 'Hangup',
                    onPressed: _hangUp,
                    tooltip: 'Hangup',
                    backgroundColor: Colors.pink,
                    child: const Icon(Icons.call_end),
                  ),
                  text: '取消',
                  color: Colors.white,
                ),
                ValueListenableBuilder(
                  valueListenable: CallVariable.videoOn,
                  builder: (context, value, _) {
                    return _editBtn(
                      btn: FloatingActionButton(
                        heroTag: 'Video',
                        tooltip: 'Video',
                        onPressed: CallVariable.switchCameraOn,
                        backgroundColor: Colors.white,
                        child: Icon(
                          value ? Icons.videocam : Icons.videocam_off,
                          color: myColors.textBlack,
                        ),
                      ),
                      text: '摄像头已${value ? '开' : '关'}',
                      color: Colors.white,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _hangUp() async {
    await CallVariable.hangUp();
  }

  // 底部的功能按钮
  Widget createVoiceBottomMenu(String text) {
    var myColors = ThemeNotifier();
    return Padding(
      padding: const EdgeInsets.only(
        left: 10.0,
        right: 10.0,
      ),
      child: Container(
        height: 180,
        constraints: const BoxConstraints(maxWidth: 400),
        // width: 240,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              text,
              style: TextStyle(
                color: myColors.textGrey,
                fontSize: 17,
              ),
            ),
            const SizedBox(
              height: 40.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                ValueListenableBuilder(
                  valueListenable: CallVariable.micMuted,
                  builder: (context, value, child) {
                    return _editBtn(
                      btn: FloatingActionButton(
                        onPressed: CallVariable.muteMic,
                        heroTag: 'microphone',
                        tooltip: 'microphone',
                        backgroundColor: Colors.white,
                        child: Icon(
                          value ? Icons.mic : Icons.mic_off,
                          color: myColors.textBlack,
                        ),
                      ),
                      text: '麦克风已${value ? '开' : '关'}',
                    );
                  },
                ),
                _editBtn(
                    btn: FloatingActionButton(
                      onPressed: _hangUp,
                      heroTag: 'Hangup',
                      tooltip: 'Hangup',
                      backgroundColor: myColors.red,
                      child: const Icon(Icons.call_end),
                    ),
                    text: '取消'),
                ValueListenableBuilder(
                  valueListenable: CallVariable.loudspeaker,
                  builder: (context, value, child) {
                    return _editBtn(
                      btn: FloatingActionButton(
                        heroTag: 'Mute Mic',
                        tooltip: 'Mute Mic',
                        backgroundColor: Colors.white,
                        onPressed: () {
                          CallVariable.switchAudioplayers(!value);
                        },
                        child: Icon(
                          value ? Icons.volume_up : Icons.volume_off_outlined,
                          color: myColors.textBlack,
                        ),
                      ),
                      text: '扬声器已${value ? '开' : '关'}',
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _editBtn({
    required Widget btn,
    String text = '',
    Color? color,
  }) {
    return Column(
      children: [
        btn,
        const SizedBox(height: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: color,
          ),
        ),
      ],
    );
  }

//头部的用户信息 icon + 名字
  Widget createHeader() {
    var myColors = ThemeNotifier();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppNetworkImage(
          CallVariable.avatar,
          avatar: true,
          width: 70,
          height: 70,
          borderRadius: BorderRadius.circular(35),
        ),
        const SizedBox(
          height: 15,
        ),
        Text(
          CallVariable.nickname,
          style: TextStyle(
            color: myColors.textBlack,
            fontSize: 17,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
