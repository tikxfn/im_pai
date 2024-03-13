import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/chat/chat_talk.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

import '../chat/widgets/chat_talk_model.dart';

class CustomerList extends StatefulWidget {
  const CustomerList({super.key});

  static const path = 'mine/customer/list';

  @override
  State<CustomerList> createState() => _CustomerListState();
}

class _CustomerListState extends State<CustomerList> {
  static List<ChatItemData> _list = [];

  // 获取客服列表
  _getList() async {
    var api = SettingApi(apiClient());
    try {
      var res = await api.settingCustomerList({});
      if (res == null || !mounted) return;
      List<ChatItemData> l = [];
      for (var v in res.list) {
        var mark = v.mark ?? '';
        l.add(ChatItemData(
          icons: [v.avatar ?? ''],
          title: v.nickname ?? '',
          mark: mark,
          id: v.id,
          goodNumber: v.userNumber != null && v.userNumber!.isNotEmpty,
          numberType: v.userNumberType ?? GUserNumberType.NIL,
          circleGuarantee: toBool(v.userExtend?.circleGuarantee),
          onlyName: toBool(v.useChangeNicknameCard),
          vip: toInt(v.userExtend?.vipExpireTime) >= toInt(date2time(null)),
          vipLevel: v.userExtend?.vipLevel ?? GVipLevel.NIL,
          vipBadge: v.userExtend?.vipBadge ?? GBadge.NIL,
          userType: UserTypeExt.formMerchantType(v.customerType),
        ));
      }
      setState(() {
        _list = l;
      });
    } on ApiException catch (e) {
      onError(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _getList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('客服列表'.tr()),
      ),
      body: ThemeBody(
        child: ListView(
          children: _list.map((e) {
            return ChatItem(
              border: true,
              titleSize: 17,
              avatarSize: 46,
              paddingLeft: 16,
              hasSlidable: false,
              data: e,
              onTap: () {
                var params = ChatTalkParams(
                  name: e.title,
                  mark: e.mark,
                  userNumber: e.userNumber,
                  remindId: e.atMessageId,
                  readId: e.readId,
                  onlyName: e.onlyName,
                  vip: e.vip,
                  vipLevel: e.vipLevel,
                  vipBadge: e.vipBadge,
                  numberType: e.numberType,
                  circleGuarantee: e.circleGuarantee,
                );
                if (e.room) {
                  params.roomId = e.id ?? '';
                } else {
                  params.receiver = e.id ?? '';
                }
                Navigator.pushNamed(
                  context,
                  ChatTalk.path,
                  arguments: params,
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}
