import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/enum.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class OnlineStatePage extends StatefulWidget {
  const OnlineStatePage({super.key});

  static const path = 'OnlineStatePage/home';

  @override
  State<OnlineStatePage> createState() => _OnlineStatePageState();
}

class _OnlineStatePageState extends State<OnlineStatePage> {
  final allSwitch = ValueNotifier(false);
  final onlySwitch = ValueNotifier(false);

  final _title = ValueNotifier('');
  Bitmask privacy = const UserPrivacy(0);

  String _id = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    _title.value = args['title'] ?? '';
    _id = args['id'];
    privacy = UserPrivacy(toInt(Global.user?.privacy));
    if (args['id'] == '3') {
      //用户和群组
      allSwitch.value = privacy.contains(
          UserPrivacy.friendInviteRoom | UserPrivacy.strangerInviteRoom);
      onlySwitch.value =
          !allSwitch.value && privacy.contains(UserPrivacy.friendInviteRoom);
    } else if (args['id'] == '2') {
      //语音通话
      allSwitch.value =
          privacy.contains(UserPrivacy.friendCall | UserPrivacy.strangerCall);
      onlySwitch.value =
          !allSwitch.value && privacy.contains(UserPrivacy.friendCall);
    }
  }

  @override
  dispose() {
    super.dispose();
    allSwitch.dispose();
    onlySwitch.dispose();
    _title.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color bgColor = myColors.themeBackgroundColor;
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title.value),
      ),
      body: ThemeBody(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: ListView(
            children: [
              Container(
                color: bgColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '所有人'.tr(),
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: allSwitch,
                      builder: (context, value, _) {
                        return AppSwitch(
                          value: value,
                          onChanged: (val) {
                            if (val) {
                              allSwitch.value = true;
                              onlySwitch.value = false;
                            } else {
                              allSwitch.value = false;
                            }
                            savePrivacy();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Container(
                color: bgColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '仅朋友'.tr(),
                      style: TextStyle(
                        fontSize: 15,
                        color: textColor,
                      ),
                    ),
                    ValueListenableBuilder(
                      valueListenable: onlySwitch,
                      builder: (context, value, _) {
                        return AppSwitch(
                          value: value,
                          onChanged: (val) {
                            if (val) {
                              allSwitch.value = false;
                              onlySwitch.value = true;
                            } else {
                              onlySwitch.value = false;
                            }
                            savePrivacy();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void savePrivacy() async {
    if (_id == '2') {
      privacy = privacy.remove(UserPrivacy.friendCall);
      privacy = privacy.remove(UserPrivacy.strangerCall);
      if (allSwitch.value) {
        privacy |= UserPrivacy.friendCall;
        privacy |= UserPrivacy.strangerCall;
      }
      if (onlySwitch.value) {
        privacy |= UserPrivacy.friendCall;
      }
    } else if (_id == '3') {
      //用户和群组
      privacy = privacy.remove(UserPrivacy.friendInviteRoom);
      privacy = privacy.remove(UserPrivacy.strangerInviteRoom);
      //语音通话
      if (allSwitch.value) {
        privacy |= UserPrivacy.friendInviteRoom;
        privacy |= UserPrivacy.strangerInviteRoom;
      }
      if (onlySwitch.value) {
        privacy |= UserPrivacy.friendInviteRoom;
      }
    }

    var api = UserApi(apiClient());
    loading();
    try {
      await api.userSetBasicInfo(V1SetBasicInfoArgs(
        privacy: SetBasicInfoArgsPrivacy(privacy: privacy.toString()),
      ));
      await Global.syncLoginUser();
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }
}
