import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class FriendAddFace extends StatefulWidget {
  const FriendAddFace({super.key});

  static const String path = 'friends/addFace';

  @override
  State<StatefulWidget> createState() {
    return _FriendAddFaceState();
  }
}

class _FriendAddFaceState extends State<FriendAddFace> {
  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '面对面建群',
          style: TextStyle(color: myColors.textGrey),
        ),
        iconTheme: IconThemeData(
          color: myColors.textGrey, //修改颜色
        ),
        backgroundColor: myColors.textBlack,
      ),
      body: Container(
        color: myColors.textBlack,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 65),
              alignment: Alignment.center,
              child: Text(
                '和身边的朋友输入相同的四个数字，进入同一个群聊',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: myColors.textGrey,
                ),
              ),
            ),
            Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 100),
                child: const TextField(
                  readOnly: true,
                  decoration: InputDecoration(),
                )),
            Expanded(child: Container()),
            Wrap(
              // spacing: 4, //水平方向间距
              // runSpacing: 10, //垂直方向间距
              alignment: WrapAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    // print("1");
                  },
                  child: Container(
                    alignment: Alignment.center,
                    width: size.width / 3,
                    height: 50,
                    decoration: BoxDecoration(
                        border:
                            Border.all(width: 0.1, color: myColors.textGrey)),
                    child: Text('1',
                        style: TextStyle(
                          color: myColors.textGrey,
                          fontSize: 30,
                        )),
                  ),
                ),
                Container(
                  alignment: Alignment.center,
                  width: size.width / 3,
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.1, color: myColors.textGrey)),
                  child: Text('2',
                      style: TextStyle(
                        color: myColors.textGrey,
                        fontSize: 30,
                      )),
                ),
                Container(
                  alignment: Alignment.center,
                  width: size.width / 3,
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.1, color: myColors.textGrey)),
                  child: Text('3',
                      style: TextStyle(
                        color: myColors.textGrey,
                        fontSize: 30,
                      )),
                ),
                Container(
                  alignment: Alignment.center,
                  width: size.width / 3,
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.1, color: myColors.textGrey)),
                  child: Text('4',
                      style: TextStyle(
                        color: myColors.textGrey,
                        fontSize: 30,
                      )),
                ),
                Container(
                  alignment: Alignment.center,
                  width: size.width / 3,
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.1, color: myColors.textGrey)),
                  child: Text('5',
                      style: TextStyle(
                        color: myColors.textGrey,
                        fontSize: 30,
                      )),
                ),
                Container(
                  alignment: Alignment.center,
                  width: size.width / 3,
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.1, color: myColors.textGrey)),
                  child: Text('6',
                      style: TextStyle(
                        color: myColors.textGrey,
                        fontSize: 30,
                      )),
                ),
                Container(
                  alignment: Alignment.center,
                  // decoration: BoxDecoration(border: ),
                  width: size.width / 3,
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.1, color: myColors.textGrey)),
                  child: Text('7',
                      style: TextStyle(
                        color: myColors.textGrey,
                        fontSize: 30,
                      )),
                ),
                Container(
                  alignment: Alignment.center,
                  // decoration: BoxDecoration(border: ),
                  width: size.width / 3,
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.1, color: myColors.textGrey)),
                  child: Text('8',
                      style: TextStyle(
                        color: myColors.textGrey,
                        fontSize: 30,
                      )),
                ),
                Container(
                  alignment: Alignment.center,
                  // decoration: BoxDecoration(border: ),
                  width: size.width / 3,
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.1, color: myColors.textGrey)),
                  child: Text('9',
                      style: TextStyle(
                        color: myColors.textGrey,
                        fontSize: 30,
                      )),
                ),
                Container(
                  alignment: Alignment.center,
                  // decoration: BoxDecoration(border: ),
                  width: size.width / 3,
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.1, color: myColors.textGrey)),
                  child: Text('0',
                      style: TextStyle(
                        color: myColors.textGrey,
                        fontSize: 30,
                      )),
                ),
                Container(
                  alignment: Alignment.center,
                  // decoration: BoxDecoration(border: ),
                  width: size.width / 3,
                  height: 50,
                  decoration: BoxDecoration(
                      border: Border.all(width: 0.1, color: myColors.textGrey)),
                  child: Text('x',
                      style: TextStyle(
                        color: myColors.textGrey,
                        fontSize: 30,
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
