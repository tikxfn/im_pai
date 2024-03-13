import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/mine/complain.dart';
import 'package:unionchat/pages/question/question_list.dart';
import 'package:unionchat/pages/setting/setting_home.dart';
import 'package:unionchat/pages/setting/surveys.dart';
import 'package:unionchat/widgets/menu_ul.dart';
import 'package:unionchat/widgets/theme_body.dart';

class MoreFunction extends StatefulWidget {
  const MoreFunction({super.key});

  static const path = 'mine/more_function';

  @override
  State<StatefulWidget> createState() {
    return _MoreFunctionState();
  }
}

class _MoreFunctionState extends State<MoreFunction> {
  Timer? _timer;
  double _count = 0;

  // 上传错误日志
  _uploadLog() async {
    loading();
    var api = SettingApi(apiClient());
    var errLog = '';
    try {
      var file = File('${Global.appSupportDirectory}/runing.log');
      errLog = file.readAsStringSync();
      var args = V1SettingUploadErrorLogArgs(content: errLog);
      await api.settingUploadErrorLog(args);
      tipSuccess('上传成功');
    } on ApiException catch (e) {
      onError(e);
      logger.e(e);
      tipError('上传失败1');
    } catch (e) {
      logger.e(e);
      tipError('上传失败2');
    } finally {
      loadClose();
    }
  }

  // 连击
  _countTap() {
    _count++;
    if (_count == 5) {
      _uploadLog();
    }
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 1), () {
      _count = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _countTap,
          child: Text('更多功能'.tr()),
        ),
      ),
      body: ThemeBody(
        child: ListView(
          children: [
            MenuUl(
              bottomBoder: true,
              marginTop: 0,
              children: [
                MenuItemData(
                  title: '问卷调查'.tr(),
                  onTap: () => Navigator.pushNamed(context, Surveys.path),
                ),
                MenuItemData(
                  title: '帮助中心'.tr(),
                  onTap: () => Navigator.pushNamed(context, QuestionList.path),
                ),
              ],
            ),
            MenuUl(
              bottomBoder: true,
              marginTop: 5,
              children: [
                MenuItemData(
                  title: '投诉建议'.tr(),
                  onTap: () => Navigator.pushNamed(context, Complain.path),
                ),
                MenuItemData(
                  title: '隐私安全'.tr(),
                  onTap: () => Navigator.pushNamed(context, SettingHome.path),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
