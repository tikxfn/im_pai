import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/adapter/adapter.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/chat/chat_talk.dart';
import 'package:unionchat/pages/chat/search_self_messaged.dart';
import 'package:unionchat/pages/chat/widgets/chat_talk_model.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/light_text.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/enum.dart';
import '../../widgets/search_input.dart';
import '../../widgets/up_loading.dart';

class SearchAllMessagePage extends StatefulWidget {
  const SearchAllMessagePage({super.key});

  static const String path = 'SearchAllMessagePage/talk';

  @override
  State<SearchAllMessagePage> createState() => _SearchAllMessagePageState();
}

class _SearchAllMessagePageState extends State<SearchAllMessagePage> {
  final TextEditingController _controller = TextEditingController();
  ValueNotifier<LoadStatus> loadStatus = ValueNotifier(LoadStatus.nil);
  Timer? timer;
  List<SearchResultItem> _list = [];

  // 搜索事件
  _search(String val) async {
    loadStatus.value = LoadStatus.loading;
    _list = await MessageUtil.searchMessage(val);
    setState(() {});
    loadStatus.value = _list.isEmpty ? LoadStatus.no : LoadStatus.nil;
  }

  // 输入改变事件
  _inputChange(String val) {
    timer?.cancel();
    if (val.isEmpty) {
      loadStatus.value = LoadStatus.nil;
      _list.clear();
      setState(() {});
      return;
    }
    timer = Timer(const Duration(milliseconds: 500), () => _search(val));
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)?.settings.arguments ?? {};
      String keywords = args['keywords'] ?? '';
      if (keywords.isNotEmpty) {
        _controller.text = keywords;
        _search(keywords);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ThemeBody(
          child: Column(
            children: [
              SearchInput(
                hint: '查找聊天记录',
                controller: _controller,
                showButton: true,
                sureStr: '取消',
                buttonTap: () => Navigator.pop(context),
                onChanged: _inputChange,
                onSubmitted: _search,
              ),
              ValueListenableBuilder(
                valueListenable: loadStatus,
                builder: (context, value, _) {
                  if (value == LoadStatus.nil) return Container();
                  return UpLoading(value);
                },
              ),
              Expanded(
                flex: 1,
                child: ListView(
                  children: _list.map((model) {
                    return SearchTopicItem(model, _controller.text);
                  }).toList(),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class SearchTopicItem extends StatelessWidget {
  final SearchResultItem model;
  final String keywords;

  const SearchTopicItem(this.model, this.keywords, {super.key});

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    Color textColor = myColors.iconThemeColor;
    var nickname = model.channel.name ?? '';
    var mark = model.channel.mark ?? '';
    var title = '$nickname${mark.isNotEmpty ? '($mark)' : ''}';
    // var target = '';
    var searchCount = model.messages.length;
    var text = '';
    if (searchCount == 1 && model.messages[0].type != null) {
      text = model.messages[0].content ?? '';
      var type = model.messages[0].type;
      if (type == GMessageType.NOTES) {
        var note = json2note(text);
        text = '${messageType2text(type)}${note.title} ${note.text}';
      }
    }
    var channel = model.channel;
    var chat = channel2chatItem(channel);
    return ChatItem(
      hasSlidable: false,
      border: false,
      data: ChatItemData(
        icons: [channel.avatar ?? ''],
        title: channel.name ?? '',
        mark: channel.mark ?? '',
        room: chat.room,
        id: chat.id,
      ),
      titleWidget: LightText(
        title,
        keywords,
        style: TextStyle(
          fontSize: 17,
          color: textColor,
        ),
      ),
      child: searchCount == 1
          ? LightText(
              text.replaceAll(' ', '').replaceAll('\n', ''),
              keywords,
              style: TextStyle(
                fontSize: 15.0,
                color: myColors.textGrey,
              ),
            )
          : searchCount == 0
              ? Text(
                  '对话',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: myColors.blueTitle,
                  ),
                )
              : Text(
                  '条相关聊天记录'.tr(args: [searchCount.toString()]),
                  style: TextStyle(
                    fontSize: 15.0,
                    color: myColors.textGrey,
                  ),
                ),
      onTap: () {
        //跳转到消息的指定位置
        if (searchCount <= 1) {
          ChatTalkParams params = chat2talkParams(chat);
          if (model.messages.length == 1) {
            params.queryId = model.messages[0].id.toString();
          }
          if (Adapter.isWideScreen) {
            Adapter.navigatorTo(
              ChatTalk.path,
              arguments: params,
            );
          } else {
            Navigator.pushNamed(
              context,
              ChatTalk.path,
              arguments: params,
            );
          }
          return;
        }
        Map<String, dynamic> args = {};
        args['pairId'] = channel.pairId ?? '';
        args['name'] = channel.name ?? '';
        args['inputKeywords'] = keywords;
        args['all'] = '1';
        Navigator.pushNamed(
          context,
          SearchSelfMessagesPage.path,
          arguments: args,
        );
      },
    );
  }
}
