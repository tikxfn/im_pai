import 'dart:async';

import 'package:animations/animations.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/call/call_variable.dart';
import 'package:unionchat/pages/call/calling.dart';
import 'package:unionchat/pages/call/signaling.dart';
import 'package:provider/provider.dart';

class MiniTalk {
  static bool _isShow = false;
  static OverlayEntry? _overlayEntry;

  static open(
    BuildContext context, {
    required nickname,
    required avatar,
    required isVideo,
    int? msgId,
    int? toUserId,
  }) async {
    final completer = Completer<VoidCallback>();
    if (_isShow) {
      return null;
    }
    CallVariable.init(
      nickname: nickname,
      avatar: avatar,
      isVideo: isVideo,
      msgId: msgId,
      toUserId: toUserId,
    );

    _overlayEntry = OverlayEntry(builder: (context) {
      return _MiniTalkOverlay(completer);
    });
    Overlay.of(context).insert(_overlayEntry!);
    _isShow = true;
    (await completer.future)();
  }

  static void close() {
    _overlayEntry?.remove();
    _isShow = false;
    _overlayEntry = null;
  }
}

class _MiniTalkOverlay extends StatefulWidget {
  final Completer completer;

  const _MiniTalkOverlay(this.completer);

  @override
  State<_MiniTalkOverlay> createState() => __MiniTalkOverlayState();
}

class __MiniTalkOverlayState extends State<_MiniTalkOverlay> {
  double topPosition = 50.0;
  double leftPosition = 50.0;

  void updatePosition(double top, double left) {
    topPosition += top;
    leftPosition += left;
    MiniTalk._overlayEntry!.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    bool videoCall = CallVariable.isVideoCall;
    return Positioned(
      top: topPosition,
      left: leftPosition,
      child: GestureDetector(
        onPanUpdate: (details) {
          updatePosition(details.delta.dy, details.delta.dx);
        },
        child: OpenContainer(
          transitionDuration: const Duration(milliseconds: 500),
          closedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(videoCall ? 5 : 10),
            ),
          ),
          closedBuilder: (context, action) {
            Future.microtask(() {
              if (!widget.completer.isCompleted) {
                widget.completer.complete(action);
              }
            });
            return GestureDetector(
              onTap: () {
                action();
              },
              child: Material(
                // elevation: 4,
                child: Builder(
                  builder: (context) {
                    return Container(
                      width: videoCall ? 100.0 : 80,
                      height: videoCall ? 170.0 : 80,
                      decoration: BoxDecoration(
                        color: videoCall ? myColors.black : myColors.white,
                      ),
                      child: MiniBuilder(
                        builder: (
                          context,
                          iceStatus,
                          remoteView,
                          localView,
                          seconds,
                        ) {
                          if (!videoCall) {
                            var text = '';
                            switch (iceStatus) {
                              case IceState.checking:
                                text = '连接中'.tr();
                                break;
                              case IceState.none:
                                text = '等待接听'.tr();
                                break;
                              case IceState.connected:
                                text = second2minute(seconds);
                                break;
                              case IceState.close:
                                text = '已关闭'.tr();
                                break;
                            }
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.call,
                                  color: myColors.primary,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  text,
                                  style: TextStyle(
                                    color: myColors.primary,
                                  ),
                                ),
                              ],
                            );
                          }
                          if (remoteView != null) return remoteView;
                          if (localView != null) return localView;
                          return Container();
                        },
                      ),
                    );
                  },
                ),
              ),
            );
          },
          openBuilder: (context, action) {
            return const Calling();
          },
        ),
      ),
    );
  }
}

class MiniBuilder extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    IceState iceStatus,
    RTCVideoView? remoteView,
    RTCVideoView? localView,
    int seconds,
  ) builder;

  const MiniBuilder({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: CallVariable.iceStatus,
      builder: (context, iceStatus, _) {
        return ValueListenableBuilder(
          valueListenable: CallVariable.remoteView,
          builder: (context, remoteView, _) => ValueListenableBuilder(
            valueListenable: CallVariable.localView,
            builder: (context, localView, _) {
              return ValueListenableBuilder(
                valueListenable: CallVariable.seconds,
                builder: (context, seconds, _) {
                  return builder(
                    context,
                    iceStatus,
                    remoteView,
                    localView,
                    seconds,
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
