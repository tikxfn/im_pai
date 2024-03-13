import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:provider/provider.dart';

import '../../../notifier/theme_notifier.dart';

class RedPacketMessage extends StatelessWidget {
  final RedPacketMessageData data;

  const RedPacketMessage(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color color = myColors.white;
    switch (data.status) {
      case RedPacketMessageStatus.received:
        color = myColors.whiteOpacity1;
        break;
      case RedPacketMessageStatus.notReceive:
        color = myColors.white;
        break;
      case RedPacketMessageStatus.over:
        color = myColors.whiteOpacity1;
        break;
    }
    return Container(
      // color: myColors.red,
      // constraints: const BoxConstraints(
      //   maxWidth: 240,
      // ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.asset(
                  assetPath('images/red_packet_message.png'),
                  height: 40,
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.title,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        style: TextStyle(
                          color: color,
                          fontSize: 16,
                        ),
                      ),
                      // Text(
                      //   tip,
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     color: color,
                      //   ),
                      // ),
                    ],
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
                  color: myColors.whiteOpacity,
                  width: .5,
                ),
              ),
            ),
            child: Text(
              data.target,
              style: TextStyle(
                color: color,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum RedPacketMessageStatus {
  //已领取
  received,
  //未领取
  notReceive,
  //已领完
  over,
}

class RedPacketMessageData {
  String title;
  String target;
  RedPacketMessageStatus status;

  RedPacketMessageData({
    required this.title,
    this.target = '红包游戏',
    this.status = RedPacketMessageStatus.notReceive,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'target': target,
      'status': status.toString().split('.').last, // 将枚举值转换为字符串
    };
  }

  factory RedPacketMessageData.fromJson(Map<String, dynamic> json) {
    return RedPacketMessageData(
      title: json['title'],
      target: json['target'],
      status: RedPacketMessageStatus.values.firstWhere(
          (e) => e.toString().split('.').last == json['status']), //将字符串转换回枚举值
    );
  }
}
