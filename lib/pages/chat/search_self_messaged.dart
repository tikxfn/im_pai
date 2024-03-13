import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/adapter/adapter.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/gl_search_input.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/channel.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/pages/chat/chat_talk.dart';
import 'package:unionchat/pages/chat/search_image_page.dart';
import 'package:unionchat/pages/chat/search_my_file.dart';
import 'package:unionchat/pages/chat/search_video_page.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';
import '../tabs.dart';

class SearchSelfMessagesPage extends StatefulWidget {
  const SearchSelfMessagesPage({super.key});

  static const String path = 'SearchSelfMessagesPage/talk';

  @override
  State<SearchSelfMessagesPage> createState() => _SearchSelfMessagesPageState();
}

class _SearchSelfMessagesPageState extends State<SearchSelfMessagesPage> {
  late TextEditingController _textEditingController;
  String userId = '';
  String pairId = '';
  String roomId = '';
  bool all = false;
  Channel? _channel;

  // final TextStyle _highlightedStyle =
  //     const TextStyle(fontSize: 16, color: Colors.green);
  //
  // final TextStyle _normalStyle =
  //     const TextStyle(fontSize: 16, color: myColors .textBlack);

  String inputKeywords = '';
  Timer? timer;
  List<Message> searchResults = [];

  final FocusNode _focusNode = FocusNode();

  //快速搜索
  void searchDelay(Function doSomething, {durationTime = 500}) {
    timer?.cancel();
    timer = Timer(Duration(milliseconds: durationTime), () {
      doSomething.call();
      timer = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      userId = args['id'] ?? '';
      pairId = args['pairId'] ?? '';
      roomId = args['roomId'] ?? '';
      all = (args['all'] ?? '').isNotEmpty;
      inputKeywords = args['inputKeywords'] ?? '';
      if (pairId.isNotEmpty) {
        _channel = await MessageUtil.getChannelByPairId(pairId);
      }
      if (inputKeywords != '') {
        _textEditingController.text = inputKeywords;
        requestData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;
    Color primary = myColors.primary;
    return KeyboardBlur(
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Column(
            children: [
              GlSearchInput(
                showButton: true,
                focusNode: _focusNode,
                controller: _textEditingController,
                buttonTap: () {
                  Navigator.pop(context);
                },
                onSubmitted: (value) {
                  _focusNode.unfocus();
                },
                onChanged: (str) {
                  // if (!_textEditingController.value.composing.isValid) {
                  inputKeywords = _textEditingController.text;
                  searchDelay(() {
                    requestData();
                  });
                  // }
                },
              ),
              if (searchResults.isNotEmpty)
                Expanded(
                  flex: 1,
                  child: ListView(
                    children: searchResults.map((message) {
                      var text = message.content ?? '';
                      if (message.type != null) {
                        text = message.content ?? '';
                        if (message.type == GMessageType.NOTES) {
                          var note = json2note(text);
                          text =
                              '${messageType2text(message.type)}${note.title} ${note.text}';
                        }
                      }
                      return ChatItem(
                        data: ChatItemData(
                          icons: [message.senderUser?.avatar ?? ''],
                          title: message.senderUser?.nickname ?? '',
                        ),
                        child: RichText(
                          text: TextSpan(
                            // text: model.content ?? '',
                            style: TextStyle(
                              fontSize: 12.0,
                              color: myColors.textGrey,
                            ),
                            children: highlightOccurrences(
                              text.replaceAll('\n', '').replaceAll(' ', ''),
                              inputKeywords,
                            ),
                          ),
                        ),
                        onTap: () {
                          if (_channel == null) return;
                          //跳转到消息的指定位置
                          var params =
                              chat2talkParams(channel2chatItem(_channel!));
                          params.queryId = toStr(message.id);
                          if (Adapter.isWideScreen) {
                            Adapter.navigatorTo(
                              ChatTalk.path,
                              arguments: params,
                            );
                          } else {
                            if (all) {
                              Navigator.pushNamed(
                                context,
                                ChatTalk.path,
                                arguments: params,
                              );
                            } else {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                ChatTalk.path,
                                ModalRoute.withName(Tabs.path),
                                arguments: params,
                              );
                            }
                          }
                        },
                      );
                    }).toList(),
                  ),
                )
              else
                Expanded(
                  flex: 1,
                  child: createNullView(primary),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createNullView(Color primary) {
    var myColors = ThemeNotifier();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
          child: Text(
            '搜索指定内容'.tr(),
            style: TextStyle(color: myColors.textGrey),
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  SearchImagePae.path,
                  arguments: {
                    'id': userId,
                    'roomId': roomId,
                    'pairId': pairId,
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  '图片'.tr(),
                  style: TextStyle(color: primary),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  SearchVideoPage.path,
                  arguments: {
                    'id': userId,
                    'roomId': roomId,
                    'pairId': pairId,
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  '视频'.tr(),
                  style: TextStyle(color: primary),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  SearchMyFilePage.path,
                  arguments: {
                    'id': userId,
                    'roomId': roomId,
                    'pairId': pairId,
                  },
                );
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                child: Text(
                  '文件'.tr(),
                  style: TextStyle(color: primary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  //搜索数据
  void requestData() async {
    if (inputKeywords.isEmpty) {
      searchResults = [];
      setState(() {});
      return;
    }
    searchResults =
        await MessageUtil.searchChannelMessage(pairId, inputKeywords);
    setState(() {});
  }

  List<TextSpan> highlightOccurrences(String source, String keyword) {
    var myColors = ThemeNotifier();
    List<TextSpan> spans = [];

    if (keyword.isEmpty) {
      spans.add(TextSpan(text: source));
      return spans;
    }

    final pattern = RegExp(keyword, caseSensitive: false);
    final matches = pattern.allMatches(source);

    int start = 0;
    for (Match match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(text: source.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: source.substring(match.start, match.end),
          style: TextStyle(fontWeight: FontWeight.bold, color: myColors.red),
        ),
      );
      start = match.end;
    }

    if (start < source.length) {
      spans.add(TextSpan(text: source.substring(start, source.length)));
    }

    return spans;
  }
}
