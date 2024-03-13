import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

import '../../notifier/theme_notifier.dart';

class AllowAddMethod extends StatefulWidget {
  const AllowAddMethod({super.key});

  static const path = 'AllowAddMethod/home';

  @override
  State<AllowAddMethod> createState() => _AllowAddMethodState();
}

class _AllowAddMethodState extends State<AllowAddMethod> {
  final friendFromQr = ValueNotifier(false);
  final friendFromPhone = ValueNotifier(false);
  final friendFromRecommend = ValueNotifier(false);
  final friendFromRoom = ValueNotifier(false);
  final friendFromNumber = ValueNotifier(false);
  final friendFromAccount = ValueNotifier(false);
  Bitmask privacy = const UserPrivacy(0);

  @override
  void initState() {
    super.initState();
    privacy = UserPrivacy(toInt(Global.user?.privacy));

    friendFromQr.value = privacy.contains(UserPrivacy.friendFromQr);
    friendFromPhone.value = privacy.contains(UserPrivacy.friendFromPhone);
    friendFromRecommend.value =
        privacy.contains(UserPrivacy.friendFromRecommend);
    friendFromRoom.value = privacy.contains(UserPrivacy.friendFromRoom);
    friendFromNumber.value = privacy.contains(UserPrivacy.friendFromNumber);
    friendFromAccount.value = privacy.contains(UserPrivacy.friendFromAccount);
  }

  @override
  dispose() {
    super.dispose();
    friendFromQr.dispose();
    friendFromPhone.dispose();
    friendFromRecommend.dispose();
    friendFromRoom.dispose();
    friendFromNumber.dispose();
    friendFromAccount.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('加我为好友的方式'.tr()),
      ),
      body: ThemeBody(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              box(
                title: '二维码'.tr(),
                valueNotifier: friendFromQr,
                userPrivacy: UserPrivacy.friendFromQr,
              ),
              box(
                title: '手机号'.tr(),
                valueNotifier: friendFromPhone,
                userPrivacy: UserPrivacy.friendFromPhone,
              ),
              box(
                title: '名片'.tr(),
                valueNotifier: friendFromRecommend,
                userPrivacy: UserPrivacy.friendFromRecommend,
              ),
              box(
                title: '群聊'.tr(),
                valueNotifier: friendFromRoom,
                userPrivacy: UserPrivacy.friendFromRoom,
              ),
              box(
                title: '靓号'.tr(),
                valueNotifier: friendFromNumber,
                userPrivacy: UserPrivacy.friendFromNumber,
              ),
              box(
                title: '账号'.tr(),
                valueNotifier: friendFromAccount,
                userPrivacy: UserPrivacy.friendFromAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget box({
    required String title,
    required ValueNotifier<bool> valueNotifier,
    required UserPrivacy userPrivacy,
  }) {
    var myColors = ThemeNotifier();
    Color textColor = myColors.iconThemeColor;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              color: textColor,
            ),
          ),
          ValueListenableBuilder(
            valueListenable: valueNotifier,
            builder: (context, value, _) {
              return AppSwitch(
                value: value,
                onChanged: (val) {
                  if (val) {
                    valueNotifier.value = true;
                    privacy |= userPrivacy;
                  } else {
                    valueNotifier.value = false;
                    privacy = privacy.remove(userPrivacy);
                  }
                  savePrivacy();
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void savePrivacy() async {
    var api = UserApi(apiClient());
    loading();
    try {
      var args = V1SetBasicInfoArgs(
        privacy: SetBasicInfoArgsPrivacy(privacy: privacy.toString()),
      );
      await api.userSetBasicInfo(args);
      await Global.syncLoginUser();
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }
}
