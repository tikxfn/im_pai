import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/pages/chat/widgets/text_message_time_icon.dart';

class TestWidget extends StatelessWidget {
  const TestWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            color: Colors.blue,
            child: TextMessageTimeIcon(
              '在 Dart 中https://chat.openai.com/c/cb8f97d7-4ae3-46f3-be18-2206bab1441a，你可以使用取\n余运算符 % 来计算两个数的余数。取余运算符返回除法的余数部分。以下是一个简单的示例：',
              width: 280,
              style: const TextStyle(),
              time: '昨天 12:23',
              timeStyle: const TextStyle(
                fontSize: 12,
              ),
              iconWidth: 12,
              icon: Image.asset(
                assetPath('images/weidu.png'),
                width: 12,
                height: 12,
              ),
            ),
          )
        ],
      ),
    );
  }
}
