import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/menu_ul.dart';

class VipSetting extends StatefulWidget {
  const VipSetting({super.key});

  static const path = 'vip/setting';

  @override
  State<StatefulWidget> createState() {
    return _VipSettingState();
  }
}

class _VipSettingState extends State<VipSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('VIP尊享'.tr()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 80,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                // color: myColors.primary,
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 251, 227, 68),
                    Color.fromARGB(255, 247, 186, 52),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sentiment_very_satisfied_sharp),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '开通超级会员',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        '开通超级会员',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(Icons.chevron_right_outlined),
                    ],
                  )
                ],
              ),
            ),
            MenuUl(
              marginTop: 0,
              children: [
                MenuItemData(
                  title: '昵称颜色'.tr(),
                  onTap: () {},
                ),
                MenuItemData(
                  title: '隐藏账号ID'.tr(),
                  arrow: false,
                  content: AppSwitch(
                      value: false,
                      onChanged: (val) {
                        // setState(() {
                        //   isTop = val;
                        // });
                        // setTop(val);
                      }),
                ),
                MenuItemData(
                  title: '隐藏上线时间'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: false,
                    onChanged: (val) {},
                  ),
                ),
                MenuItemData(
                  title: '隐藏IP属地(仅SVIP)'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: false,
                    onChanged: (val) {},
                  ),
                ),
                MenuItemData(
                  title: '关闭消息已读'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: false,
                    onChanged: (val) {},
                  ),
                ),
                MenuItemData(
                  title: '优先人工客服'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: false,
                    onChanged: (val) {},
                  ),
                ),
                MenuItemData(
                  title: '广告过滤'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: false,
                    onChanged: (val) {},
                  ),
                ),
                MenuItemData(
                  title: 'VIP高速通道'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: false,
                    onChanged: (val) {},
                  ),
                ),
                MenuItemData(
                  title: '不接收群发好友消息(仅SVIP5以上)'.tr(),
                  arrow: false,
                  content: AppSwitch(
                    value: false,
                    onChanged: (val) {},
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
