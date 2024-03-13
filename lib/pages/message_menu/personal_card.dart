import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';

class PersonalCardPage extends StatefulWidget {
  const PersonalCardPage({Key? key}) : super(key: key);
  static const String path = 'personalCard/page';

  @override
  State<PersonalCardPage> createState() => _PersonalCardPageState();
}

class _PersonalCardPageState extends State<PersonalCardPage> {
  Color backColor = ThemeNotifier().backGroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        actions: [
          TextButton(
            onPressed: () async {},
            child: const Text('· · ·'),
          ),
        ],
      ),
      backgroundColor: backColor,
      body: createBody(),
    );
  }

// 97 115 150
  Widget createBody() {
    var myColors = ThemeNotifier();
    return Padding(
      padding: const EdgeInsets.all(60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            height: 40,
          ),
          Row(
            children: [
              Image.asset(
                assetPath('images/pyq.png'),
                height: 40,
                width: 40,
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '哦呦',
                        style: TextStyle(
                            color: myColors.textBlack,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(
                        '四川 成都',
                        style: TextStyle(
                          color: myColors.textGrey,
                          fontSize: 14,
                          // fontWeight: FontWeight.w600
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Image.asset(
            assetPath('images/image_loading.png'),
            height: 240,
            width: 240,
          ),
          const SizedBox(
            height: 30,
          ),
          Text(
            '扫一扫上面的二维码图案，加我为朋友。',
            style: TextStyle(
              color: myColors.secondTextColor,
              fontSize: 13,
              // fontWeight: FontWeight.w600
            ),
          ),
          Expanded(child: Container()),
          //底部三个按钮
          createBottom(),
        ],
      ),
    );
  }

  Widget createBottom() {
    var myColors = ThemeNotifier();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          '扫一扫',
          style: TextStyle(
              color: Color.fromRGBO(97, 115, 150, 1.0),
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Container(
            color: const Color.fromRGBO(97, 115, 150, 1.0),
            height: 10,
            width: 0.5,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              if (backColor == myColors.white) {
                backColor = myColors.backGroundColor;
              } else if (backColor == myColors.backGroundColor) {
                backColor = myColors.white;
              }
            });
          },
          child: const Text(
            '换一换',
            style: TextStyle(
                color: Color.fromRGBO(97, 115, 150, 1.0),
                fontSize: 15,
                fontWeight: FontWeight.w600),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Container(
            color: const Color.fromRGBO(97, 115, 150, 1.0),
            height: 10,
            width: 0.5,
          ),
        ),
        const Text(
          '保存图片',
          style: TextStyle(
              color: Color.fromRGBO(97, 115, 150, 1.0),
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
