import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:provider/provider.dart';

class MineVersion extends StatefulWidget {
  const MineVersion({
    super.key,
  });

  @override
  State<StatefulWidget> createState() {
    return _MineVersionState();
  }
}

class _MineVersionState extends State<MineVersion> {
  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Center(
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            padding: const EdgeInsets.only(top: 22),
            child: Container(
              width: 290,
              decoration: BoxDecoration(
                color: myColors.grey1,
                image: DecorationImage(
                  image: ExactAssetImage(
                    assetPath('images/my/version_bg.png'),
                  ),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 71),
                    child: Text(
                      '发现新版本',
                      style: TextStyle(
                          fontSize: 18,
                          color: myColors.textBlack,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 11),
                    child: Text(
                      'V1.0.12',
                      style: TextStyle(
                        fontSize: 18,
                        color: myColors.grey3,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 6,
                      left: 14,
                      right: 14,
                    ),
                    child: Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        '更新内容:',
                        style: TextStyle(
                          fontSize: 15,
                          color: myColors.textBlack,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 5,
                      left: 14,
                      right: 14,
                    ),
                    child: Container(
                      alignment: Alignment.topLeft,
                      height: 110,
                      child: ListView(
                        children: [
                          Text(
                            '1.更新版本，修复bug',
                            style: TextStyle(
                              fontSize: 13,
                              color: myColors.grey3,
                            ),
                          ),
                          Text(
                            '2.更新版本，修复bug2222222222222222222222222222222222222222222222222222222222222222222222222222222333333333333333333333333333333333333333333335555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111',
                            style: TextStyle(
                              fontSize: 13,
                              color: myColors.grey3,
                            ),
                          ),
                          Text(
                            '2.更新版本，修复bug2222222222222222222222222222222222222222222222222222222222222222222222222222222333333333333333333333333333333333333333333335555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555555111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111',
                            style: TextStyle(
                              fontSize: 13,
                              color: myColors.grey3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 25,
                      left: 13,
                      right: 13,
                      bottom: 10,
                    ),
                    child: CircleButton(
                      onTap: () {},
                      theme: AppButtonTheme.blue,
                      title: '立即更新',
                      height: 40,
                      fontSize: 16,
                      radius: 25,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 122,
            height: 86,
            alignment: Alignment.center,
            child: Image.asset(
              assetPath('images/my/sp_shenjitubiao.png'),
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            right: 10,
            top: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                width: 15,
                height: 15,
                // margin: EdgeInsets.only(top: 18.h),
                alignment: Alignment.center,
                child: Image.asset(
                  assetPath('images/my/btn_guanbi.png'),
                  width: 18,
                  height: 18,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
