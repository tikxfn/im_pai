import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/function_config.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/chat/widgets/chat_talk_model.dart';
import 'package:unionchat/widgets/marquee_text.dart';
import 'package:unionchat/widgets/user_name_tags.dart';
import 'package:openapi/api.dart';

class ChatTalkTitle extends StatelessWidget {
  final bool checkModal; // 是否开启多选模式
  final ChatTalkParams params; // 页面传递参数
  final ChatTalkUserData userData; // 个人相关变量
  final Function()? onTap;

  const ChatTalkTitle({
    required this.params,
    required this.userData,
    required this.checkModal,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var myColors = ThemeNotifier();
    if (checkModal) {
      return Text('选择消息'.tr());
    }
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (params.roomId.isNotEmpty)
            MarqueeText(
              text: params.mark.isNotEmpty ? params.mark : params.name,
              style: TextStyle(
                color: params.vip ? myColors.vipName : null,
              ),
            ),
          if (params.roomId.isEmpty)
            //用户昵称、靓号
            UserNameTags(
              select: false,
              userName: params.mark.isNotEmpty ? params.mark : params.name,
              goodNumber:
                  params.userNumber.isNotEmpty && FunctionConfig.goodNumber,
              numberType: params.numberType ?? GUserNumberType.NIL,
              circleGuarantee: params.circleGuarantee,
              vip: params.vip,
              vipLevel: params.vipLevel,
              vipBadge: params.vipBadge,
              onlyName: params.onlyName,
              iconSize: 20,
            ),
          //在线状态、ip、地址、id、账号、群成员
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (params.roomId.isNotEmpty && params.totalCount.isNotEmpty)
                Text(
                  '位成员'.tr(args: [params.totalCount]),
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
              if (userData.online)
                Container(
                  width: 5,
                  height: 5,
                  margin: const EdgeInsets.only(
                    right: 3,
                    top: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: myColors.primary,
                  ),
                ),
              Flexible(
                child: Text.rich(
                  TextSpan(
                    text: '',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.normal,
                      color: myColors.textGrey,
                    ),
                    children: [
                      if (userData.onlineTime.isNotEmpty)
                        TextSpan(text: userData.onlineTime),
                      if (!platformPhone && userData.userIP.isNotEmpty)
                        TextSpan(text: ' ${userData.userIP}'),
                      if (!platformPhone && userData.userId.isNotEmpty)
                        TextSpan(text: ' ID:${userData.userId}'),
                      if (!platformPhone && userData.userAccount.isNotEmpty)
                        TextSpan(
                          text:
                              ' ${'账号'.tr()}:${params.userNumber.isNotEmpty && FunctionConfig.goodNumber ? params.userNumber : userData.userAccount}',
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
