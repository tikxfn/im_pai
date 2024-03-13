import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:provider/provider.dart';

class AccountAndSafePage extends StatefulWidget {
  const AccountAndSafePage({Key? key}) : super(key: key);
  static const String path = 'accountandsafe/page';

  @override
  State<AccountAndSafePage> createState() => _AccountAndSafePageState();
}

class _AccountAndSafePageState extends State<AccountAndSafePage> {
  List listData = [
    '微信号',
    '手机号',
    '密码',
    '',
    '',
    '',
    '',
    '',
    '',
    '',
  ];
  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: myColors.backGroundColor,
        title: const Text('账号与安全'),
      ),
      body: createBody(),
    );
  }

  Widget createBody() {
    var myColors = ThemeNotifier();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        children: [
          createItem('账号'),
          Container(
            color: myColors.textGrey,
            height: 0.5,
            width: MediaQuery.of(context).size.width - 40,
          ),
          createItem('手机号'),
          Container(
            color: myColors.textGrey,
            height: 0.5,
            width: MediaQuery.of(context).size.width - 40,
          ),
          createItem('密码'),
          Container(
            color: myColors.textGrey,
            height: 0.5,
            width: MediaQuery.of(context).size.width - 40,
          ),
        ],
      ),
    );
  }

  Widget createItem(String title) {
    var myColors = ThemeNotifier();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: myColors.textBlack),
          ),
          Expanded(child: Container()),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
