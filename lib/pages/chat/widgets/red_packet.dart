import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/db/model/message.dart';

import '../../../notifier/theme_notifier.dart';
import '../../../widgets/avatar.dart';

class RedPacketDialog extends StatelessWidget {
  final Message msg;
  final Function()? onOpen;
  final Function()? onDetail;

  const RedPacketDialog(
    this.msg, {
    this.onOpen,
    this.onDetail,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    return Center(
      child: Center(
        child: Card(
          // margin: const EdgeInsets.only(left: 30.0, right: 30.0),
          elevation: 5.0,
          color: myColors.red,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: SizedBox(
            height: 420,
            width: 280,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 70),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppAvatar(
                      list: [msg.senderUser?.avatar ?? ''],
                      userName: msg.senderUser?.nickname ?? '',
                      userId: msg.receiverUserId.toString(),
                      size: 30,
                    ),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 220),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: Text(
                          '的红包'.tr(args: [msg.senderUser?.nickname ?? '']),
                          style: TextStyle(
                            color: myColors.goldColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  '恭喜发财，大吉大1利'.tr(),
                  style: TextStyle(
                    color: myColors.goldColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 60),
                Expanded(child: Container()),
                GestureDetector(
                  onTap: onOpen,
                  child: Container(
                    // color: myColors.goldColor,
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      // border: new Border.all(color: Colors.white, width: 0.5),
                      color: const Color(0xFFFFECC5),
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(70.0),
                    ),
                    child: Center(
                      child: Text(
                        '開'.tr(),
                        style: TextStyle(
                          color: myColors.textBlack,
                          fontSize: 40,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onDetail,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      '查看领取详情',
                      style: TextStyle(
                        color: myColors.textBlack,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
