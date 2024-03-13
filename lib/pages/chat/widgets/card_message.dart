import 'package:flutter/material.dart';
import 'package:unionchat/widgets/avatar.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

//对话框名片消息
class CardMessage extends StatelessWidget {
  final CardMessageData data;

  const CardMessage(
    this.data, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Container(
      constraints: const BoxConstraints(
          // maxWidth: 240,
          ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              children: [
                AppAvatar(
                  list: [data.avatar],
                  size: 40,
                  userName: data.name,
                  userId: data.userId,
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: Text(
                    data.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 3),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: myColors.lineGrey,
                  width: .5,
                ),
              ),
            ),
            child: Text(
              data.tag,
              style: TextStyle(
                fontSize: 12,
                color: myColors.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CardMessageData {
  final String avatar;
  final String userId;
  final String name;
  final String tag;

  CardMessageData({
    required this.avatar,
    required this.name,
    required this.tag,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      'avatar': avatar,
      'name': name,
    };
  }

  factory CardMessageData.fromJson(Map<String, dynamic> json) {
    return CardMessageData(
      avatar: json['avatar'],
      name: json['name'],
      tag: json['tag'],
      userId: json['userId'],
    );
  }
}
