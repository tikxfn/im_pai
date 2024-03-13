import 'dart:io';
import 'dart:typed_data';

import 'package:easy_localization/easy_localization.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor/image_editor.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class AppImageEditor extends StatefulWidget {
  final File file;
  final bool avatar;
  final bool isUser;

  const AppImageEditor(
    this.file, {
    this.avatar = false,
    this.isUser = false,
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AppImageEditorState();
}

class _AppImageEditorState extends State<AppImageEditor> {
  late File file;
  final GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey();
  bool _clip = false;
  bool _draw = false;
  bool _avatarMode = false;
  final List<Color> _drawColors = [
    ThemeNotifier().white,
    ThemeNotifier().black,
    ThemeNotifier().drawColor1,
    ThemeNotifier().drawColor2,
    ThemeNotifier().drawColor3,
    ThemeNotifier().drawColor4,
    ThemeNotifier().drawColor5,
    ThemeNotifier().drawColor6,
    ThemeNotifier().drawColor7,
    ThemeNotifier().drawColor8,
    ThemeNotifier().drawColor9,
  ];
  Color _drawColorNow = ThemeNotifier().white;
  final List<Doodle> _completedDoodles = [];

  // Doodle? _currentDoodle;

  //开始
  // void _onPanStart(Offset position) {
  //   if (!_draw) return;
  //   final Paint paint = Paint()
  //     ..color = _drawColorNow
  //     ..strokeWidth = 4.0
  //     ..style = PaintingStyle.stroke;

  //   final Path path = Path()..moveTo(position.dx, position.dy);
  //   setState(() {
  //     _currentDoodle = Doodle(path: path, paint: paint);
  //   });
  // }

  // //画笔更新
  // void _onPanUpdate(Offset position) {
  //   if (!_draw) return;
  //   setState(() {
  //     _currentDoodle?.path.lineTo(position.dx, position.dy);
  //   });
  // }

  // //画笔结束
  // void _onPanEnd() {
  //   if (!_draw) return;
  //   if (_currentDoodle != null) {
  //     setState(() {
  //       _completedDoodles.add(_currentDoodle!);
  //       _currentDoodle = null;
  //     });
  //   }
  // }

  //撤回
  void _onUndo() {
    setState(() {
      if (_completedDoodles.isNotEmpty) {
        _completedDoodles.removeLast();
      }
    });
  }

  //保存
  save() async {
    var res = await imageClipPc();
    if (mounted) {
      Navigator.pop(context, {'isCrop': true, 'result': res, 'ext': 'png'});
    }
  }

  //pc图片裁剪
  imageClipPc() async {
    loading(text: '图片裁剪中'.tr());
    try {
      var state = editorKey.currentState;
      if (state == null) {
        loadClose();
        return null;
      }
      var editAction = state.editAction!;
      Rect? cropRect = state.getCropRect();
      var data = state.rawImageData;

      img.Image? src = img.decodeImage(data);
      if (src == null) return null;
      // final lb = await loadBalancer;
      // img.Image src = await lb.run<img.Image, List<int>>(img.decodeImage, data);

      //相机拍照的图片带有旋转，处理之前需要去掉
      src = img.bakeOrientation(src);

      if (editAction.needCrop) {
        src = img.copyCrop(
          src,
          x: cropRect!.left.toInt(),
          y: cropRect.top.toInt(),
          width: cropRect.width.toInt(),
          height: cropRect.height.toInt(),
        );
      }

      if (editAction.needFlip) {
        img.FlipDirection mode = img.FlipDirection.both;
        if (editAction.flipY && editAction.flipX) {
          mode = img.FlipDirection.both;
        } else if (editAction.flipY) {
          mode = img.FlipDirection.horizontal;
        } else if (editAction.flipX) {
          mode = img.FlipDirection.vertical;
        }
        src = img.flip(src, direction: mode);
      }

      if (editAction.hasRotateAngle) {
        src = img.copyRotate(src, angle: editAction.rotateAngle.toInt());
      }
      // var fileData = img.encodeJpg(src);
      return img.encodeJpg(src);
    } catch (e) {
      return null;
    } finally {
      loadClose();
    }
  }

  //图片裁剪
  Future<Uint8List?> imageClip() async {
    loading(text: '图片裁剪中'.tr());
    try {
      var state = editorKey.currentState;
      if (state == null) {
        loadClose();
        return null;
      }
      final img = state.rawImageData;
      Rect? cropRect = state.getCropRect();
      var action = state.editAction!;
      final rotateAngle = action.rotateAngle.toInt();
      final flipHorizontal = action.flipY;
      final flipVertical = action.flipX;

      var option = ImageEditorOption();
      option.outputFormat = const OutputFormat.png();

      if (action.needCrop) {
        option.addOption(ClipOption.fromRect(cropRect!));
      }
      if (action.needFlip) {
        option.addOption(
          FlipOption(
            horizontal: flipHorizontal,
            vertical: flipVertical,
          ),
        );
      }
      if (action.hasRotateAngle) {
        option.addOption(RotateOption(rotateAngle));
      }
      return await ImageEditor.editImage(
        image: img,
        imageEditorOption: option,
      );
    } catch (e) {
      return null;
    } finally {
      loadClose();
    }
  }

  //编辑按钮组件
  Widget _editBtn({
    required IconData icon,
    bool active = false,
    Function()? onTap,
    Color? iconColor,
  }) {
    var myColors = ThemeNotifier();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: active ? myColors.readBg : null,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(
          icon,
          color: iconColor ?? myColors.white,
        ),
      ),
    );
  }

  //画笔工具栏
  Widget _drawWidget() {
    var myColors = ThemeNotifier();
    return Container(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _drawColors.map((e) {
                  var active = _drawColorNow == e;
                  double size = active ? 28 : 22;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _drawColorNow = e;
                      });
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(size),
                        color: e,
                        border: Border.all(
                          color: myColors.white,
                          width: active ? 3 : 2,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          GestureDetector(
            onTap: _onUndo,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(
                Icons.undo,
                color: myColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  //工具栏
  Widget _toolWidget() {
    return Container(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _editBtn(
            icon: Icons.cut,
            active: _clip,
            onTap: () {
              setState(() {
                _clip = !_clip;
              });
            },
          ),
          _editBtn(
            icon: Icons.edit,
            active: _draw,
            onTap: () {
              setState(() {
                _draw = !_draw;
              });
            },
          ),
        ],
      ),
    );
  }

  //裁剪工具栏
  Widget _clipWidget() {
    var myColors = ThemeNotifier();
    return Container(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_clip)
            _editBtn(
              icon: Icons.close,
              iconColor: myColors.red,
              onTap: () {
                setState(() {
                  _clip = !_clip;
                });
              },
            ),
          _editBtn(
            icon: Icons.autorenew,
            iconColor: myColors.messagePacketColor,
            onTap: () {
              editorKey.currentState!.reset();
            },
          ),
          if (_clip)
            Row(
              children: [
                _editBtn(
                  icon: Icons.flip,
                  onTap: () {
                    editorKey.currentState!.flip();
                  },
                ),
                _editBtn(
                  icon: Icons.rotate_left,
                  onTap: () {
                    editorKey.currentState!.rotate(right: false);
                  },
                ),
                _editBtn(
                  icon: Icons.rotate_right,
                  onTap: () {
                    editorKey.currentState!.rotate();
                  },
                ),
              ],
            ),
          if (_clip)
            _editBtn(
              icon: Icons.check,
              onTap: () {},
              iconColor: myColors.green,
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _avatarMode = widget.avatar;
    if (_avatarMode) _clip = true;
    file = widget.file;
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: myColors.white,
      appBar: AppBar(
        title: Text('图片裁剪'.tr()),
        actions: [
          // IconButton(
          //   onPressed: () async {
          //     await confirm(context, title: '图片编辑功能正在开发中...');
          //     if(!mounted) return;
          //     // editor.i18n()
          //     // final editedImage = await Navigator.push(
          //     //   context,
          //     //   MaterialPageRoute(
          //     //     builder: (context) => editor.ImageEditor(
          //     //       image: file.readAsBytesSync(), // <-- Uint8List of image
          //     //       appBar: myColors.white,
          //     //       // bottomBarColor: Colors.blue,
          //     //     ),
          //     //   ),
          //     // );
          //     // editedImage
          //     // setState(() {
          //     //   _avatarMode = false;
          //     //   _clip = false;
          //     // });
          //   },
          //   icon: const Icon(
          //     Icons.bug_report,
          //   ),
          // ),

          if (widget.isUser)
            TextButton(
              onPressed: () {
                if (Global.loginUser!.userVipLevel != GVipLevel.NIL &&
                    Global.loginUser!.userVipLevel != GVipLevel.n1) {
                  Navigator.pop(context, {'isCrop': false});
                } else {
                  tip('vip2以上用户才能使用此功能'.tr());
                  return;
                }
              },
              child: Text(
                '上传动图'.tr(),
                style: TextStyle(color: myColors.primary),
              ),
            ),
          if (!_clip || (_clip && _avatarMode))
            TextButton(
              onPressed: () {
                save();
              },
              child: Text(
                '保存'.tr(),
                style: TextStyle(color: myColors.primary),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ExtendedImage.file(
                    widget.file,
                    fit: BoxFit.contain,
                    mode: _clip
                        ? ExtendedImageMode.editor
                        : ExtendedImageMode.gesture,
                    extendedImageEditorKey: editorKey,
                    cacheRawData: true,
                    initEditorConfigHandler: (state) {
                      return EditorConfig(
                        maxScale: 8.0,
                        cropRectPadding: const EdgeInsets.all(20.0),
                        hitTestSize: 20.0,
                        cropAspectRatio:
                            _avatarMode ? CropAspectRatios.ratio1_1 : null,
                      );
                    },
                  ),
                  // GestureDetector(
                  //   onPanStart: (details) => _onPanStart(details.localPosition),
                  //   onPanUpdate: (details) => _onPanUpdate(details.localPosition),
                  //   onPanEnd: (details) => _onPanEnd(),
                  //   behavior: HitTestBehavior.opaque,
                  //   child: CustomPaint(
                  //     painter: DoodlePainter(
                  //       doodles: _completedDoodles,
                  //       currentDoodle: _currentDoodle,
                  //     ),
                  //     child: Container(),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
          if (!_avatarMode)
            Container(
              color: myColors.primary,
              padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
              child: SafeArea(
                child: Column(
                  children: [
                    //画笔工具栏
                    if (_draw) _drawWidget(),
                    //工具栏
                    if (!_clip) _toolWidget(),
                    //裁剪工具栏
                    if (_clip) _clipWidget(),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

//画笔
class Doodle {
  Doodle({required this.path, required this.paint});

  final Path path;
  final Paint paint;
}

//画布
class DoodlePainter extends CustomPainter {
  DoodlePainter({required this.doodles, required this.currentDoodle});

  final List<Doodle> doodles;
  final Doodle? currentDoodle;

  @override
  void paint(Canvas canvas, Size size) {
    for (final doodle in doodles) {
      canvas.drawPath(doodle.path, doodle.paint);
    }

    if (currentDoodle != null) {
      canvas.drawPath(currentDoodle!.path, currentDoodle!.paint);
    }
  }

  @override
  bool shouldRepaint(DoodlePainter oldDelegate) {
    return true;
  }
}
