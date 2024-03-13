import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/keyboard_blur.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:unionchat/widgets/search_input.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class CircleMySelect extends StatefulWidget {
  const CircleMySelect({super.key});

  static const String path = 'circle/my_select';

  @override
  State<StatefulWidget> createState() {
    return CircleMySelectState();
  }
}

class CircleMySelectState extends State<CircleMySelect> {
  int limit = 20;
  List<GCircleModel> circleData = [];

  //搜索列
  List<GCircleModel> searchList = [];

  //已选列表圈子id
  List<String> circleIdList = [];
  //已选列表圈名字
  List<String> circleNameList = [];

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
      for (var v in res.list) {
        if (v.status == GApplyStatus.BAN) continue;
        if (v.status == GApplyStatus.APPLY) continue;
        newCirlceData.add(v);
      }
      if (!mounted) return 0;
      if (init) {
        circleData = newCirlceData;
      } else {
        circleData.addAll(newCirlceData);
      }
      if (mounted) setState(() {});
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } catch (e) {
      logger.e(e);
      return limit;
    } finally {}
  }

  //选择用户
  onChoose(GCircleModel e) {
    if (circleIdList.contains(e.id!)) {
      circleIdList.remove(e.id!);
      circleNameList.remove(e.name!);
    } else {
      // if (Global.user?.userNumber == null ||
      //     Global.user!.userNumber!.isEmpty && circleNameList.isNotEmpty) {
      //   tip('最多选择1个圈子'.tr());
      //   return;
      // }
      if (circleNameList.length >= 10) {
        tip('最多选择10个圈子'.tr());
        return;
      }
      circleIdList.add(e.id!);
      circleNameList.add(e.name!);
    }
    setState(() {});
  }

  //更新首页用户筛选
  updateUserSelect() async {
    FocusManager.instance.primaryFocus?.unfocus();
    String circleId = '';
    if (circleIdList.isNotEmpty) circleId = circleIdList.join(',');
    logger.i(circleId);
    try {
      final api = CircleApi(apiClient());
      await api.circleUpdateUserCircleSet(
        V1UpdateUserCircleSetArgs(
          circleId: V1UpdateUserCircleSetArgsValue(value: circleId),
        ),
      );
      if (!mounted) return;
      if (mounted) Navigator.pop(context, [circleIdList, circleNameList]);
    } on ApiException catch (e) {
      onError(e);
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
    Color bgColor = myColors.themeBackgroundColor;
    return Scaffold(
      appBar: AppBar(
        title: Text('选择圈子'.tr()),
      ),
      body: KeyboardBlur(
        child: ThemeBody(
          child: Column(
            children: [
              SearchInput(
                autofocus: false,
                height: 45,
                radius: 23,
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
                    if (!mounted) return 0;
                    dynamic args = ModalRoute.of(context)!.settings.arguments;
                    if (args == null) return 0;
                    circleIdList = args['circleIdList'];
                    circleNameList = args['circleNameList'];
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
                    if (circleData.isEmpty)
                      Container(
                        width: 424,
                        height: 581,
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
                        color: bgColor,
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
                            return GestureDetector(
                              onTap: () => onChoose(e),
                              child: Row(
                                children: [
                                  AppCheckbox(
                                    value: circleIdList.contains(e.id),
                                    size: 25,
                                    paddingLeft: 15,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: ChatItem(
                                      onTap: () {
                                        onChoose(e);
                                      },
                                      titleSize: 15,
                                      avatarSize: 44,
                                      data: ChatItemData(
                                        icons: [e.image ?? ''],
                                        title: e.name ?? '',
                                      ),
                                      hasSlidable: false,
                                      titleWidget: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              e.name ?? '',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ),
                                          if (e.circleType !=
                                              GCircleType.PUBLIC)
                                            Container(
                                              margin: const EdgeInsets.only(
                                                  left: 10),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 5,
                                                      vertical: 3),
                                              decoration: BoxDecoration(
                                                color: myColors
                                                    .circlyTypePrivateBg,
                                                borderRadius:
                                                    BorderRadius.circular(3),
                                              ),
                                              child: Text(
                                                circlyType,
                                                style: TextStyle(
                                                  color: myColors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                        ],
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
              Container(
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                  color: myColors.bottom,
                  boxShadow: [
                    BoxShadow(
                      color: myColors.bottomShadow,
                      blurRadius: 5,
                      offset: const Offset(0, 0),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: CircleButton(
                    onTap: () {
                      updateUserSelect();
                    },
                    title: '确定'.tr(),
                    radius: 10,
                    theme: AppButtonTheme.blue,
                    fontSize: 19,
                    height: 47,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
