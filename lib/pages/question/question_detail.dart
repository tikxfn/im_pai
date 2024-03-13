import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/enum.dart';
import '../../common/func.dart';
import '../../common/interceptor.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/up_loading.dart';

class QuestionDetail extends StatefulWidget {
  const QuestionDetail({super.key});

  static const path = 'question/detail';

  @override
  State<QuestionDetail> createState() => _QuestionDetailState();
}

class _QuestionDetailState extends State<QuestionDetail> {
  String id = '';
  LoadStatus loadStatus = LoadStatus.nil;
  GQaModel? detail;

  //获取详情
  getDetail() async {
    var api = QaApi(apiClient());
    if (mounted) {
      setState(() {
        loadStatus = LoadStatus.loading;
      });
    }
    try {
      var res = await api.qaDetails(GIdArgs(id: id));
      if (res == null || !mounted) return;
      setState(() {
        detail = res;
        loadStatus = LoadStatus.nil;
      });
    } on ApiException catch (e) {
      onError(e);
      if (!mounted) return;
      setState(() {
        loadStatus = LoadStatus.failed;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dynamic args = ModalRoute.of(context)!.settings.arguments;
    id = args['id'];
    getDetail();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      appBar: AppBar(
          // title: const Text('问题详情'),
          ),
      body: ThemeBody(
        child: loadStatus != LoadStatus.nil
            ? UpLoading(loadStatus)
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                children: [
                  Column(
                    children: [
                      Text(
                        (detail?.q ?? '').isNotEmpty ? detail!.q! : '',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
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
                  Divider(height: 15, color: myColors.lineGrey, indent: .5),
                  Html(data: detail?.a ?? ''),
                ],
              ),
      ),
    );
  }
}
