import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/help/circle_my_select.dart';
import 'package:unionchat/pages/help/province_my_select.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';

class HelpHomeSelect extends StatefulWidget {
  const HelpHomeSelect({super.key});

  static const path = 'help/home_select';

  @override
  State<StatefulWidget> createState() {
    return _HelpHomeSelectState();
  }
}

class _HelpHomeSelectState extends State<HelpHomeSelect> {
  //多选列圈子id
  List<String> circleIdList = [];
  //多选列圈子名字
  List<String> circleNameList = [];

  //多选列城市id
  List<String> areaCodeList = [];
  //多选列城市名字
  List<String> areaNameList = [];
  List<GAreaModel> areaData = [];

//获取首页用户筛选
  getUserSelect() async {
    try {
      final api = CircleApi(apiClient());
      final res = await api.circleGetUserCircleSet({});
      if (res == null) return;
      if (!mounted) return;
      logger.i(res);
      List<String> newCircleId = [];
      List<String> newCircleNameList = [];
      if (res.circle.isNotEmpty) {
        for (var v in res.circle) {
          newCircleId.add(v.id!);
          newCircleNameList.add(v.name!);
        }
      }
      logger.i(res.circle);
      areaData = [];
      List<String> newAreaCodeList = [];
      List<String> newAreaNameList = [];
      if (res.area.isNotEmpty) {
        areaData = res.area.toList();
        for (var v in res.area) {
          newAreaCodeList.add(v.cityCode!);
          newAreaNameList.add(v.cityName!);
        }
      }
      circleIdList = newCircleId;
      circleNameList = newCircleNameList;
      areaCodeList = newAreaCodeList;
      areaNameList = newAreaNameList;
      logger.i(areaData);
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    } finally {}
  }

  //刷新选择的城市列表
  refreshCity() async {
    try {
      final api = CircleApi(apiClient());
      final res = await api.circleGetUserCircleSet({});
      if (res == null) return;
      if (!mounted) return;
      areaData = [];
      List<String> newAreaCodeList = [];
      List<String> newAreaNameList = [];
      if (res.area.isNotEmpty) {
        areaData = res.area.toList();
        for (var v in res.area) {
          newAreaCodeList.add(v.cityCode!);
          newAreaNameList.add(v.cityName!);
        }
      }
      areaCodeList = newAreaCodeList;
      areaNameList = newAreaNameList;
      logger.i(areaData);
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //更新首页用户筛选
  updateUserSelect() async {
    String areaCode = '';
    String circleId = '';
    if (areaCodeList.isNotEmpty) areaCode = areaCodeList.join(',');
    if (circleIdList.isNotEmpty) circleId = circleIdList.join(',');
    logger.i(areaCode);
    logger.i(circleId);
    try {
      final api = CircleApi(apiClient());
      await api.circleUpdateUserCircleSet(
        V1UpdateUserCircleSetArgs(
          areaCode: V1UpdateUserCircleSetArgsValue(value: areaCode),
          circleId: V1UpdateUserCircleSetArgsValue(value: circleId),
        ),
      );
      if (!mounted) return;
      tip('保存成功'.tr());
      if (mounted) setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  @override
  void initState() {
    super.initState();
    getUserSelect();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
        appBar: AppBar(
          title: Text('筛选'.tr()),
        ),
        body: ThemeBody(
          child: Column(
            children: [
              inkWellButton(
                onTap: () async {
                  var result = await Navigator.pushNamed(
                    context,
                    CircleMySelect.path,
                    arguments: {
                      'circleIdList': circleIdList,
                      'circleNameList': circleNameList,
                    },
                  );
                  if (result == null) return;
                  List<List<String>> circleResult =
                      result as List<List<String>>;
                  circleIdList = circleResult[0];
                  circleNameList = circleResult[1];
                  if (mounted) setState(() {});
                },
                image: 'images/help/circle_select_circle.png',
                title: '选择圈子'.tr(),
                children: [
                  for (var v in circleNameList)
                    circleTag(
                      title: v,
                      tagBgColor: myColors.circleSelectCircleTagbg,
                      tagTitleColor: myColors.circleSelectCircleTagTitle,
                      onDelete: () {
                        var i = circleNameList.indexOf(v);
                        circleIdList.remove(circleIdList[i]);
                        circleNameList.remove(circleNameList[i]);

                        if (mounted) setState(() {});
                      },
                    )
                ],
              ),
              Container(
                color: myColors.circleBorder,
                height: 5,
              ),
              inkWellButton(
                onTap: () async {
                  var result = await Navigator.pushNamed(
                    context,
                    ProvinceSelect.path,
                    arguments: {
                      'areaData': areaData,
                    },
                  );

                  if (result == null) return;
                  List<List<String>> areaResult = result as List<List<String>>;
                  areaCodeList = areaResult[0];
                  areaNameList = areaResult[1];
                  refreshCity();
                  if (mounted) setState(() {});
                },
                image: 'images/help/circle_select_city.png',
                title: '选择地区'.tr(),
                children: [
                  for (var v in areaNameList)
                    cityTag(
                      title: v,
                      tagBgColor: myColors.circleSelectCityTagbg,
                      tagTitleColor: myColors.iconThemeColor,
                      onDelete: () {
                        var i = areaNameList.indexOf(v);
                        areaNameList.remove(areaNameList[i]);
                        areaCodeList.remove(areaCodeList[i]);
                        List<GAreaModel> newAreaData = [];
                        for (var data in areaData) {
                          if (data.cityName == v) continue;
                          newAreaData.add(data);
                        }
                        areaData = newAreaData;
                        if (mounted) setState(() {});
                      },
                    )
                ],
              ),
            ],
          ),
        ),
        bottomNavigationBar: Container(
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
            child: Row(
              children: [
                Expanded(
                  child: CircleButton(
                    onTap: () {
                      circleIdList = [];
                      circleNameList = [];
                      areaCodeList = [];
                      areaNameList = [];
                      updateUserSelect();
                      tip('已清空筛选条件'.tr());
                      setState(() {});
                    },
                    icon: 'images/help/circle_select_delete.png',
                    title: '清空条件'.tr(),
                    radius: 10,
                    theme: AppButtonTheme.blue0,
                    fontSize: 16,
                    height: 47,
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: CircleButton(
                    onTap: () async {
                      await updateUserSelect();
                      if (mounted) Navigator.pop(context);
                    },
                    title: '保存条件'.tr(),
                    icon: 'images/help/circle_select_save.png',
                    radius: 10,
                    theme: AppButtonTheme.blue,
                    fontSize: 16,
                    height: 47,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  //列表组件
  Widget inkWellButton({
    Function()? onTap,
    required String image,
    String title = '',
    List<Widget>? children,
  }) {
    var myColors = ThemeNotifier();
    Color textColor = myColors.iconThemeColor;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Image.asset(
                  width: 48,
                  height: 48,
                  assetPath(image),
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  width: 15,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 19,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Image.asset(
                  width: 12,
                  height: 18,
                  assetPath('images/help/right_jiantou.png'),
                  color: myColors.iconThemeColor,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          if (children != null)
            Container(
              padding: const EdgeInsets.only(top: 13),
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 6,
                runSpacing: 10,
                children: children,
              ),
            ),
        ],
      ),
    );
  }

  //圈子tag
  Widget circleTag({
    String title = '',
    Color tagBgColor = Colors.white,
    Color tagTitleColor = Colors.black,
    Function()? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
      decoration: BoxDecoration(
        color: tagBgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
                color: tagTitleColor,
                fontSize: 15,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(
            width: 3,
          ),
          GestureDetector(
            onTap: onDelete,
            child: Image.asset(
              width: 19,
              height: 19,
              assetPath('images/help/circle_select_reduce.png'),
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  //圈子tag
  Widget cityTag({
    String title = '',
    Color tagBgColor = Colors.white,
    Color tagTitleColor = Colors.black,
    Function()? onDelete,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
      decoration: BoxDecoration(
        color: tagBgColor,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            width: 19,
            height: 19,
            assetPath('images/help/weizhi.png'),
            fit: BoxFit.contain,
          ),
          const SizedBox(
            width: 3,
          ),
          Text(
            title,
            style: TextStyle(
                color: tagTitleColor,
                fontSize: 15,
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(
            width: 3,
          ),
          GestureDetector(
            onTap: onDelete,
            child: Image.asset(
              width: 19,
              height: 19,
              assetPath('images/help/circle_select_reduce.png'),
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}
