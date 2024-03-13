import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/notice/notice_detail.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';
import '../../common/interceptor.dart';
import '../../widgets/pager_box.dart';

class NoticeList extends StatefulWidget {
  const NoticeList({super.key});

  static const String path = 'notice/list';

  @override
  State<NoticeList> createState() => _NoticeListState();
}

class _NoticeListState extends State<NoticeList> {
  int limit = 20;
  List<GNoticeModel> _list = [];

  //获取列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = NoticeApi(apiClient());
    try {
      final res = await api.noticeList({});
      if (res == null || !mounted) return 0;
      setState(() {
        _list = res.list.toList();
      });
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {
      if (load) loadClose();
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('公告列表'.tr()),
      ),
      body: ThemeBody(
        child: PagerBox(
          padding: const EdgeInsets.all(15),
          limit: limit,
          onInit: () async {
            return await _getList(init: true);
          },
          onPullDown: () async {
            return await _getList(init: true);
          },
          children: _list.map((v) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: 3,
                        height: 12,
                        decoration: BoxDecoration(
                          color: myColors.textGrey,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          time2formatDate(v.createTime),
                          style: TextStyle(
                            color: myColors.textGrey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      NoticeDetail.path,
                      arguments: {'id': v.id},
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.symmetric(
                      vertical: 21,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color: myColors.themeBackgroundColor,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: myColors.bottomShadow,
                          blurRadius: 10,
                          offset: const Offset(0, 0),
                        ),
                      ],
                      // border: Border(
                      //   bottom: BorderSide(
                      //     color: myColors.lineGrey,
                      //     width: .5,
                      //   ),
                      // ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.only(right: 14),
                              child: Image.asset(
                                assetPath('images/talk/gonggao.png'),
                                width: 17,
                                height: 17,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                v.title!.isEmpty ? '-' : v.title!,
                                maxLines: 2,
                                style: TextStyle(
                                  color: textColor,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Divider(
                            color: myColors.noticeBoder,
                          ),
                        ),
                        Text(
                          (v.content ?? '').trim(),
                          maxLines: 4,
                          style: TextStyle(
                            fontSize: 15,
                            color: myColors.accountTagTitle,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
