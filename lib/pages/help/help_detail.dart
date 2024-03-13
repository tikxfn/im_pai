import 'package:flutter/material.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/chat/chat_talk.dart';
import 'package:unionchat/widgets/network_image.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';
import '../chat/widgets/chat_talk_model.dart';

class HelpDetail extends StatefulWidget {
  const HelpDetail({super.key});

  static const String path = 'help/detail';

  @override
  State<StatefulWidget> createState() {
    return _HelpDetailState();
  }
}

class _HelpDetailState extends State<HelpDetail> {
  String trendsId = ''; //动态id
  String userId = ''; //用户id
  String avatar = ''; //头像
  String circleName = ''; //圈子名
  GCircleArticleModel? detail;

  //获取详情
  getDetail() async {
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleDetailCircleArticle(GIdArgs(id: trendsId));
      if (res == null) return;
      logger.d(res);
      detail = res;
      userId = res.userId!;
      avatar = res.userInfo!.avatar!;
      circleName = res.circleName!;
      setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    dynamic args = ModalRoute.of(context)!.settings.arguments;
    if (args == null) return;
    if (args['trendsId'] != null) trendsId = args['trendsId'];
    logger.i(trendsId);
    if (trendsId.isNotEmpty) {
      getDetail();
    }
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('帮办详情'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share, color: myColors.primary),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.favorite_border, color: myColors.primary),
          ),
        ],
      ),
      body: Column(
        children: [
          if (detail != null)
            Expanded(
              flex: 1,
              child: ListView(
                children: [
                  //标题等
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: myColors.white,
                      border: Border(
                        bottom: BorderSide(
                          color: myColors.lineGrey,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          circleName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  //发起人
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 15),
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 15),
                    decoration: BoxDecoration(
                      color: myColors.white,
                      border: Border(
                        top: BorderSide(
                          color: myColors.lineGrey,
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: myColors.lineGrey,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        AppNetworkImage(
                          avatar,
                          width: 50,
                          height: 50,
                          borderRadius: BorderRadius.circular(50),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          detail!.userInfo!.nickname!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            // color: myColors.linkGrey,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '发起该帮办',
                          style: TextStyle(
                            fontSize: 12,
                            color: myColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  //内容
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: myColors.white,
                      border: Border(
                        top: BorderSide(
                          color: myColors.lineGrey,
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: myColors.lineGrey,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          detail!.content!,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                        for (var i = 0; i < detail!.images.length; i++)
                          GestureDetector(
                            onTap: () {
                              // previewMedia(detail!.images[i]);
                            },
                            child: AppNetworkImage(
                              detail!.images[i],
                              marginTop: 10,
                              width: double.infinity,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (detail != null && userId != Global.user!.id)
            Expanded(
              flex: 0,
              child: Container(
                color: myColors.white,
                child: SafeArea(
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 15),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          ChatTalk.path,
                          arguments: ChatTalkParams(receiver: userId),
                        );
                      },
                      child: const Text('私信TA'),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
