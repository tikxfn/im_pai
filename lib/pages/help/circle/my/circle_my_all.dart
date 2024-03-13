import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../../notifier/theme_notifier.dart';

class CircleMyAll extends StatefulWidget {
  const CircleMyAll({super.key});

  static const String path = 'circle/my_all';

  @override
  State<StatefulWidget> createState() {
    return CircleMyAllState();
  }
}

class CircleMyAllState extends State<CircleMyAll> {
  int limit = 20;
  static List<GCircleModel> circleData = [];
  //初始加载后数据为空
  bool noList = false;

  //搜索列
  List<ChatItemData> searchList = [];

  //搜索列
  String searchName = '';

  //文本控制器
  final TextEditingController _textController = TextEditingController();

  // 是否输入内容
  bool _isInputWords = false;

  //获取列表
  Future<int> getList({bool init = false}) async {
    final api = CircleApi(apiClient());
    try {
      final res = await api.circleListCircle(V1ListCircleArgs(
        isPublic: GSure.NO,
        circleType: V1ListCircleType.ALL,
        name: searchName,
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : circleData.length.toString(),
        ),
      ));
      if (res == null) return 0;
      List<GCircleModel> newCirlceData = [];
      // newCirlceData = res.list;
      for (var v in res.list) {
        if (v.status == GApplyStatus.BAN) continue;
        if (v.status == GApplyStatus.APPLY) continue;
        newCirlceData.add(v);
      }
      if (!mounted) return 0;
      if (init) {
        circleData = newCirlceData;
        if (circleData.isEmpty) {
          noList = true;
        } else {
          noList = false;
        }
      } else {
        circleData.addAll(newCirlceData);
      }
      setState(() {});
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {}
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: Text('选择圈子'.tr()),
      ),
      body: ThemeBody(
        child: Column(
          children: [
            SearchInput(
              autofocus: false,
              controller: _textController,
              showButton: _isInputWords,
              onChanged: (value) {
                setState(() {
                  _isInputWords = _textController.text.isNotEmpty;
                  if (_textController.text.isEmpty) {
                    searchName = '';
                    getList(init: true);
                  }
                });
              },
              buttonTap: () {
                searchName = _textController.text;
                getList(init: true);
              },
            ),
            Expanded(
              flex: 1,
              child: PagerBox(
                limit: limit,
                onInit: () async {
                  //初始化

                  return await getList(init: true);
                },
                onPullDown: () async {
                  //下拉刷新

                  return await getList(init: true);
                },
                onPullUp: () async {
                  //上拉加载
                  return await getList();
                },
                children: [
                  if (circleData.isEmpty && noList)
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.7,
                      alignment: Alignment.center,
                      child: Image.asset(
                        assetPath('images/help/sp_zanwuneirong2.png'),
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                  if (circleData.isNotEmpty)
                    Container(
                      color: myColors.themeBackgroundColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: circleData.map((e) {
                          String circlyType = '公开'.tr();
                          switch (e.circleType) {
                            case GCircleType.GUARANTEE:
                              circlyType = '保圈'.tr();
                              break;
                            case GCircleType.NIL:
                              break;
                            case GCircleType.PRIVATE:
                              circlyType = '私有'.tr();
                              break;
                            case GCircleType.PUBLIC:
                              break;
                          }
                          return ChatItem(
                            onTap: () {
                              Navigator.pop(context, e);
                            },
                            hasSlidable: false,
                            avatarSize: 46,
                            titleSize: 16,
                            data: ChatItemData(
                              icons: [e.image ?? ''],
                              title: e.name ?? '',
                            ),
                            titleWidget: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    e.name ?? '',
                                    style: const TextStyle(
                                      height: 1,
                                      fontSize: 16,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                if (e.circleType != GCircleType.PUBLIC)
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: myColors.circlyTypePrivateBg,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    child: Text(
                                      circlyType,
                                      style: TextStyle(
                                        height: 1,
                                        color: myColors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
