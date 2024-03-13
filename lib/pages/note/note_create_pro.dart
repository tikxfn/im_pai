import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/common/media_picker.dart';
import 'package:unionchat/common/upload_file.dart';
import 'package:unionchat/db/model/notes.dart';
import 'package:unionchat/db/notes_utils.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/note/note_detail_pro.dart';
import 'package:unionchat/pages/play_video.dart';
import 'package:unionchat/pages/play_video_win.dart';
import 'package:unionchat/widgets/app_video_pro.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/map.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:unionchat/widgets/row_list.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:provider/provider.dart';
import 'package:reorderables/reorderables.dart';

import '../../notifier/theme_notifier.dart';

class NoteCreatePro extends StatefulWidget {
  const NoteCreatePro({super.key});

  static const path = 'note/create/pro';

  @override
  State<StatefulWidget> createState() {
    return _NoteCreateProState();
  }
}

class _NoteCreateProState extends State<NoteCreatePro> {
  final _scrollController = ScrollController();
  final Map<String, FocusNode> _textNote = {};
  Notes _notes = Notes();
  String id = '';
  bool collect = false; //是否是收藏的笔记
  bool _order = false;
  List<String> typeList = [
    '标题',
    '文字',
    '图片',
    '视频',
    '位置',
  ];
  bool hasTitle = false;

  // 检测图片敏感内容
  Future<bool> _checkTask(List<File> files) async {
    loading(text: '正在检测敏感内容');
    try {
      List<FileProvider> providers = [];
      for (var v in files) {
        providers.add(FileProvider.fromFilepath(
          v.path,
          V1FileUploadType.NOTE_IMAGE,
        ));
      }
      return await UploadFile(
        providers: providers,
        load: false,
      ).checkQrcode();
    } on ApiException catch (e) {
      onError(e);
      return false;
    } finally {
      loadClose();
    }
  }

  // 视频播放
  _playVideo(String url) {
    Navigator.push(
      context,
      CupertinoModalPopupRoute(
        builder: (context) {
          if (Platform.isWindows) {
            return WinPlayVideo(url: url);
          } else {
            return AppPlayVideo(url: url);
          }
        },
      ),
    );
  }

  // 获取详情
  getDetail() async {
    var res = await NotesUtils.getById(toInt(id));
    if (res == null || !mounted) return;
    res.items = res.items.toList();
    logger.i(res);
    setState(() {
      _notes = res;
    });
  }

  // 保存
  _save() async {
    if (_notes.items.isEmpty) return;
    loading();
    await NotesUtils.save(_notes);
    loadClose();
    if (mounted) Navigator.pop(context);
  }

  // 预览
  _preview() {
    if (_notes.items.isEmpty) return;
    Navigator.pushNamed(
      context,
      NoteDetailPro.path,
      arguments: {
        'notes': _notes,
      },
    );
  }

  // 删除组件
  _delWidget(int i) {
    if (_notes.items[i].type == GNoteType.TITLE) {
      hasTitle = false;
    }
    setState(() {
      _notes.items.removeAt(i);
    });
  }

  // 添加组件
  addWidget(int i) {
    switch (i) {
      case 0:
        _addTitle();
        _jumpLast(first: false);
        break;
      case 1:
        _addText();
        _jumpLast();
        break;
      case 2:
        _addImage();
        break;
      case 3:
        _addVideo();
        break;
      case 4:
        _addLocation();
        break;
    }
  }

  // 跳转最后一个组件
  _jumpLast({bool first = false}) {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted && _scrollController.hasClients) {
        try {
          if (first) {
            _scrollController.jumpTo(0);
            return;
          }
          double maxScroll = _scrollController.position.maxScrollExtent;
          _scrollController.jumpTo(maxScroll);
        } catch (e) {
          // 这里可以根据需要进行异常处理或日志记录
          logger.e('Failed to jump to the last: $e');
        }
      }
    });
  }

  // 添加标题组件
  _addTitle() {
    var time = date2time(null);
    setState(() {
      _textNote[time] = FocusNode();
      var note = NoteItem()
        ..type = GNoteType.TITLE
        ..subTitle = time;
      _notes.items.insert(0, note);
      // _notes.items.add(note);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_textNote[time] == null) return;
      _textNote[time]!.requestFocus();
    });
  }

  // 添加文本组件
  _addText() {
    var time = date2time(null);
    setState(() {
      _textNote[time] = FocusNode();
      _notes.items.add(NoteItem()
        ..type = GNoteType.TEXT
        ..subTitle = time);
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_textNote[time] == null) return;
      _textNote[time]!.requestFocus();
    });
  }

  // 添加图片组件
  _addImage() async {
    var files = await MediaPicker.image(context);
    if (files.isEmpty || !mounted) return;
    if (!await _checkTask(files)) {
      tipError('内容包含敏感内容，无法上传！');
      return;
    }
    for (var v in files) {
      _notes.items.add(NoteItem()
        ..content = v.path
        ..type = GNoteType.IMAGE);
    }
    setState(() {});
    _jumpLast();
  }

  // 添加视频组件
  _addVideo() async {
    var files = await MediaPicker.video(context);
    if (files.isEmpty) return;
    for (var v in files) {
      _notes.items.add(NoteItem()
        ..content = v.path
        ..type = GNoteType.VIDEO);
    }
    setState(() {});
    _jumpLast();
  }

  // 添加位置组件
  _addLocation() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AppMap(
            onEnter: (location) {
              if (!mounted) return;
              _notes.items.add(NoteItem()
                ..title = location.title
                ..subTitle = location.desc
                ..content = location.location
                ..type = GNoteType.LOCATION);
              setState(() {});
              _jumpLast();
            },
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)?.settings.arguments ?? {};
    id = toStr(args['id']);
    collect = args['collect'] ?? false;
    if (id.isNotEmpty) getDetail();
  }

  // 标题组件
  Widget _titleWidget(int i) {
    hasTitle = true;
    var v = _notes.items[i];
    var myColors = ThemeNotifier();
    FocusNode? node;
    var time = v.subTitle ?? '';
    if (time.isNotEmpty && _textNote[time] != null) {
      node = _textNote[time];
    }
    return Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: myColors.chatInputColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        focusNode: node,
        enabled: !_order,
        onChanged: (val) {
          v.content = val;
        },
        controller: TextEditingController(text: v.content),
        minLines: 1,
        maxLines: 100,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () => _delWidget(i),
            icon: Image.asset(
              assetPath('images/my/note_delete.png'),
              width: 20,
              height: 18,
              fit: BoxFit.contain,
            ),
          ),
          suffixIconColor: myColors.red,
          hintText: '请输入标题',
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 文本组件
  Widget _textWidget(int i) {
    var v = _notes.items[i];
    var myColors = ThemeNotifier();
    FocusNode? node;
    var time = v.subTitle ?? '';
    if (time.isNotEmpty && _textNote[time] != null) {
      node = _textNote[time];
    }
    return Container(
      margin: const EdgeInsets.only(top: 5),
      decoration: BoxDecoration(
        color: myColors.chatInputColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        focusNode: node,
        enabled: !_order,
        onChanged: (val) {
          v.content = val;
        },
        controller: TextEditingController(text: v.content),
        minLines: 1,
        maxLines: 100,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          suffixIcon: IconButton(
            onPressed: () => _delWidget(i),
            icon: Image.asset(
              assetPath('images/my/note_delete.png'),
              width: 20,
              height: 18,
              fit: BoxFit.contain,
            ),
          ),
          suffixIconColor: myColors.red,
          hintText: '请输入',
          border: const OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // 图片组件
  Widget _imageWidget(int i) {
    var v = _notes.items[i];
    if ((v.content ?? '').isEmpty) return Container();
    var myColors = ThemeNotifier();
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              openSheetMenu(
                context,
                list: ['删除'],
                onTap: (o) {
                  if (o == 0) _delWidget(i);
                },
              );
            },
            child: AppNetworkImage(
              v.content ?? '',
              width: double.infinity,
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: () => _delWidget(i),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: myColors.red,
                ),
                child: Image.asset(
                  assetPath('images/my/note_delete.png'),
                  width: 20,
                  height: 18,
                  color: myColors.white,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 视频组件
  Widget _videoWidget(int i) {
    var v = _notes.items[i];
    if ((v.content ?? '').isEmpty) return Container();
    var myColors = ThemeNotifier();
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Stack(
        children: [
          InkWell(
            onTap: () {
              openSheetMenu(
                context,
                list: ['删除', '播放'],
                onTap: (o) {
                  if (o == 0) _delWidget(i);
                  if (o == 1) _playVideo(v.content ?? '');
                },
              );
            },
            child: AppVideoPro(v.content ?? ''),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: InkWell(
              onTap: () => _delWidget(i),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: myColors.red,
                ),
                child: Image.asset(
                  assetPath('images/my/note_delete.png'),
                  width: 20,
                  height: 18,
                  color: myColors.white,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 位置组件
  Widget _locationWidget(int i) {
    var v = _notes.items[i];
    if ((v.content ?? '').isEmpty) return Container();
    var myColors = ThemeNotifier();
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return AppMap(
                showMap: true,
                location: MapLocation(
                  location: v.content ?? '',
                  title: v.title ?? '',
                  desc: v.subTitle ?? '',
                ),
              );
            },
          ),
        );
        // Navigator.pushNamed(
        //   context,
        //   MapShowPage.path,
        //   arguments: {
        //     'location': v.content,
        //     'title': v.title,
        //     'content': v.subTitle,
        //   },
        // );
      },
      child: Container(
        margin: const EdgeInsets.only(top: 5),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: myColors.grey1,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                color: myColors.im2CircleIcon,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.location_on,
                color: myColors.white,
              ),
            ),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.title ?? '',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    v.subTitle ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () => _delWidget(i),
              child: Container(
                width: 30,
                height: 40,
                alignment: Alignment.center,
                child: Image.asset(
                  assetPath('images/my/note_delete.png'),
                  width: 20,
                  height: 18,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return KeyboardBlur(
      child: Scaffold(
        appBar: AppBar(
          title: Text(id.isEmpty ? '新增笔记'.tr() : '编辑笔记'.tr()),
          actions: [
            IconButton(
              onPressed: _save,
              icon: Icon(
                Icons.done,
                color: myColors.primary,
              ),
            ),
          ],
        ),
        body: ThemeBody(
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: ReorderableWrap(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(10),
                  onReorder: (int oldIndex, int newIndex) {
                    setState(() {
                      if (_notes.items[newIndex].type == GNoteType.TITLE ||
                          _notes.items[oldIndex].type == GNoteType.TITLE) {
                        return;
                      }
                      var item = _notes.items[oldIndex];
                      _notes.items.removeAt(oldIndex);
                      _notes.items.insert(newIndex, item);
                    });
                  },
                  children: _notes.items.map((v) {
                    var i = _notes.items.indexOf(v);
                    if (v.type == GNoteType.TITLE) return _titleWidget(i);
                    if (v.type == GNoteType.TEXT) return _textWidget(i);
                    if (v.type == GNoteType.IMAGE) return _imageWidget(i);
                    if (v.type == GNoteType.VIDEO) return _videoWidget(i);
                    if (v.type == GNoteType.LOCATION) {
                      return _locationWidget(i);
                    }
                    return Container();
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              if (!_order)
                RowList(
                  rowNumber: 5,
                  children: typeList.map((e) {
                    String imagePath = '';
                    bool disabled = false;
                    switch (e) {
                      case '标题':
                        imagePath = 'images/my/note_title.png';
                        disabled = hasTitle;
                        break;
                      case '文字':
                        imagePath = 'images/my/note_text.png';
                        break;
                      case '图片':
                        imagePath = 'images/my/note_image.png';
                        break;
                      case '视频':
                        imagePath = 'images/my/note_video.png';
                        break;
                      case '位置':
                        imagePath = 'images/my/note_location.png';
                        break;
                    }
                    return itemWidget(
                      title: e,
                      imagePath: imagePath,
                      disabled: disabled,
                      onTap: () {
                        addWidget(typeList.indexOf(e));
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 10),
              if (_order)
                AppButtonBottomBox(
                  child: CircleButton(
                    title: '排序完成',
                    height: 45,
                    fontSize: 14,
                    radius: 45,
                    onTap: () {
                      setState(() {
                        _order = false;
                      });
                    },
                  ),
                ),
              if (!_order)
                AppButtonBottomBox(
                  child: Row(
                    children: [
                      Expanded(
                        child: CircleButton(
                          title: '排序',
                          height: 45,
                          fontSize: 14,
                          radius: 25,
                          theme: AppButtonTheme.blue,
                          onTap: () {
                            setState(() {
                              _order = true;
                            });
                            // openSheetMenu(context, list: ['预览', '排序'],
                            //     onTap: (i) {
                            //   if (i == 0) _preview();
                            //   if (i == 1) {
                            //     setState(() {
                            //       _order = true;
                            //     });
                            //   }
                            // });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 1,
                        child: CircleButton(
                          title: '预览',
                          height: 45,
                          fontSize: 14,
                          theme: AppButtonTheme.greenWhite,
                          radius: 25,
                          disabled: _notes.items.isEmpty,
                          onTap: () {
                            _preview();
                            // openSheetMenu(
                            //   context,
                            //   list: [
                            //     '标题',
                            //     '文字',
                            //     '图片',
                            //     '视频',
                            //     '位置',
                            //   ],
                            //   onTap: addWidget,
                            // );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget itemWidget({
    required String title,
    required String imagePath,
    required Function() onTap,
    bool disabled = false,
  }) {
    var myColors = ThemeNotifier();
    return GestureDetector(
      onTap: !disabled ? onTap : null,
      child: Container(
        width: 30,
        alignment: Alignment.center,
        child: Column(
          children: [
            Image.asset(
              assetPath(imagePath),
              color: !disabled ? null : myColors.textGrey,
              height: 20,
              width: 25,
              fit: BoxFit.contain,
            ),
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: disabled
                        ? myColors.subIconThemeColor
                        : myColors.iconThemeColor,
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
