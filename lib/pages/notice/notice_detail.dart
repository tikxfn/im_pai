import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:openapi/api.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/notice/notice_list.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';
import '../../widgets/url_text.dart';

class NoticeDetail extends StatefulWidget {
  const NoticeDetail({super.key});

  static const String path = 'notice/detail';

  @override
  State<StatefulWidget> createState() {
    return _NoticeDetailState();
  }
}

class _NoticeDetailState extends State<NoticeDetail> {
  bool showHistory = false;
  String id = '';
  GNoticeModel? detail;

  // 获取详情
  getDetail() async {
    if (id.isEmpty) return;
    try {
      var api = NoticeApi(apiClient());
      var res = await api.noticeDetails(GIdArgs(id: id));
      if (res == null || !mounted) return;
      setState(() {
        detail = res;
      });
    } on ApiException catch (e) {
      logger.e(e);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)?.settings.arguments ?? {};
      showHistory = args['showHistory'] ?? false;
      setState(() {});
      id = args['id'] ?? '';
      getDetail();
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('公告详情'.tr()),
        actions: [
          if (showHistory)
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, NoticeList.path);
              },
              child: Text(
                '往期公告'.tr(),
                style: TextStyle(
                  color: myColors.iconThemeColor,
                ),
              ),
            ),
        ],
      ),
      body: ThemeBody(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          children: [
            Column(
              children: [
                Text(
                  (detail?.title ?? '').isNotEmpty ? detail!.title! : '',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time2formatDate(detail?.createTime),
                  style: TextStyle(
                    color: myColors.textGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            Divider(height: 30, color: myColors.lineGrey, indent: .5),
            UrlText(
              (detail?.content ?? '').isNotEmpty ? detail!.content! : '',
              select: true,
              style: TextStyle(
                color: textColor,
                height: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
