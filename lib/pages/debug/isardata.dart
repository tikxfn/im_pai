import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/db/model/notes.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/operator/channel_operator.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/notifier/channel_list_notifier.dart';
import 'package:unionchat/task/task.dart';
import 'package:isar/isar.dart';
import 'package:openapi/api.dart';

class IsarData extends StatefulWidget {
  static String path = 'isar_data';
  const IsarData({super.key});

  @override
  State<IsarData> createState() => _IsarDataState();
}

class _IsarDataState extends State<IsarData> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据库测试'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              final message = MessageUtil.newMessage(
                '0000000100000039',
                GMessageType.TEXT,
              );
              message.content = '测试消息';
              await MessageUtil.send(message);
              logger.d(message);
            },
            child: const Text('发送消息测试'),
          ),
          ElevatedButton(
            onPressed: () async {
              final list = await MessageUtil.listUnSendMessages();
              logger.d(list);
            },
            child: const Text('查询任务消息'),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final task = MessageTask();
                  task.initialize();
                },
                child: const Text('初始化任务'),
              ),
            ],
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  Task.close();
                },
                child: const Text('关闭任务'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await Global.cleanCache();
                },
                child: const Text('删除数据目录'),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              final list = await MessageUtil.listChannel(ChannelCondition());
              logger.d(list);
            },
            child: const Text('搜索channel'),
          ),
          ElevatedButton(
            onPressed: () async {
              for (var element in ChannelListNotifier().channels) {
                logger.d(element.value);
              }
            },
            child: const Text('状态channel'),
          ),
          ElevatedButton(
            onPressed: () async {},
            child: const Text('状态ChannelNotifier'),
          ),
          ElevatedButton(
            onPressed: () async {
              listenToSSE();
            },
            child: const Text('长连接测试'),
          ),
          ElevatedButton(
            onPressed: () async {
              final n = ChannelListNotifier();
              n.searchByCondition(ChannelCondition());
              n.addListener(() {
                for (var c in n.channels) {
                  logger.d(c.value.lastMessage);
                }
              });
            },
            child: const Text('channel列表'),
          ),
          ElevatedButton(
            onPressed: () async {
              final v = await MessageUtil.getMaxUpId();
              logger.d(v);
            },
            child: const Text('maxId'),
          ),
          ElevatedButton(
            onPressed: () async {
              logger.d(Isar.splitWords('我想要更多控制'));
            },
            child: const Text('文本分割'),
          ),
          ElevatedButton(
            onPressed: () async {
              final v = is64BitSystem();
              logger.d(v);
            },
            child: const Text('机器位数'),
          ),
          ElevatedButton(
            onPressed: () async {
              final n = Notes()
                ..mark = 'hh'
                ..items = [
                  NoteItem()..content = '1',
                  NoteItem()..content = '2',
                  NoteItem()..content = '3',
                ];
              final data = n.toJson();
              print(data);
            },
            child: const Text('笔记序列号'),
          ),
        ],
      ),
    );
  }
}
