import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/tab_bottom_height.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../notifier/theme_notifier.dart';
import '../../widgets/contact_list.dart';
import '../../widgets/keyboard_blur.dart';
import '../../widgets/search_input.dart';

class ProvinceSelect extends StatefulWidget {
  const ProvinceSelect({super.key});

  static const String path = 'help/province_select';

  @override
  State<StatefulWidget> createState() {
    return _ProvinceSelectState();
  }
}

class _ProvinceSelectState extends State<ProvinceSelect> {
  String keywords = '';

  bool isCity = false;

  //某省份下城市列表合集
  List cityList1 = [];

  //数据列表
  List province = [];

  //所有城市列表
  List cityAll = [];

  //特殊省份
  List specialProvince = [];

  //热门城市
  List popularCities = [];

  //特殊城市province_code
  List l = ['81', '82', '71', '999'];

  //热门城市city_code
  List popularCityCode = [
    '110100000000',
    '440100000000',
    '440300000000',
    '310100000000'
  ];

  //传入城市数据
  List<GAreaModel> areaData = [];

  //转化的已选城市数据
  List<CityData> cityData = [];
  final TextEditingController _ctr = TextEditingController();

  //载入json
  loadData() async {
    try {
      await rootBundle
          .loadString(assetPath('city_data/city_data.json'))
          .then((value) {
        province.clear();
        specialProvince.clear();
        popularCities.clear();
        List list = [];
        list = json.decode(value);
        for (var v in list) {
          if (l.contains(v['city_code'])) {
            specialProvince.add(v);
          } else {
            province.add(v);
          }
          for (var j in v['child']) {
            cityAll.add(j);
            if (popularCityCode.contains(j['city_code'])) {
              popularCities.add(j);
            }
          }
        }
        if (mounted) setState(() {});
      });
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //选择省份后替换数据为城市
  selectCity(String id) {
    logger.i(id);
    isCity = true;
    cityList1 = [];
    for (var v in province) {
      if (v['city_code'] == id) cityList1.add(v['child']);
    }
    for (var v in specialProvince) {
      if (v['city_code'] == id) cityList1.add(v['child']);
    }
    province = [];
    for (var v in cityList1) {
      for (var a in v) {
        province.add(a);
      }
    }
    if (_ctr.text.isNotEmpty) {
      _ctr.text = keywords = '';
      FocusManager.instance.primaryFocus?.unfocus();
    }

    setState(() {});
  }

  //选择城市
  onChoose(e) {
    // if (Global.user?.userNumber == null ||
    //     Global.user!.userNumber!.isEmpty && cityData.isNotEmpty) {
    //   tip('最多选择1个城市'.tr());
    //   return;
    // }
    if (cityData.length >= 10) {
      tip('最多选择10个城市'.tr());
      return;
    }
    CityData newData = CityData(
      areaCode: e['city_code'],
      areaName: e['city_name'],
    );
    for (var v in cityData) {
      if (v.areaCode == newData.areaCode) return;
    }
    cityData = [newData, ...cityData];
    // cityData.add(newData);
    if (_ctr.text.isNotEmpty) {
      _ctr.text = keywords = '';
      FocusManager.instance.primaryFocus?.unfocus();
    }
    if (mounted) setState(() {});
  }

  //删除城市
  delete(CityData e) {
    cityData.remove(e);
    logger.i(cityData);
    if (mounted) setState(() {});
  }

  //更新首页用户筛选
  updateUserSelect() async {
    FocusManager.instance.primaryFocus?.unfocus();
    //城市code
    List<String> areaCodeList = [];
    for (var a in cityData) {
      areaCodeList.add(a.areaCode);
    }
    //城市name
    List<String> areaNameList = [];
    for (var b in cityData) {
      areaNameList.add(b.areaName);
    }
    String areaCode = '';
    if (areaCodeList.isNotEmpty) areaCode = areaCodeList.join(',');
    logger.i(areaCode);
    try {
      final api = CircleApi(apiClient());
      await api.circleUpdateUserCircleSet(
        V1UpdateUserCircleSetArgs(
          areaCode: V1UpdateUserCircleSetArgsValue(value: areaCode),
        ),
      );
      if (!mounted) return;
      if (mounted) Navigator.pop(context, [areaCodeList, areaNameList]);
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  // 搜索城市
  List<ContractData> _searchList() {
    if (keywords.isEmpty) return [];
    var textColor = ThemeNotifier().iconThemeColor;
    List<ContractData> list = [];
    for (var e in cityAll) {
      var cd = ContractData(
        widget: GestureDetector(
          onTap: () {
            onChoose(e);
          },
          child: ListTile(
            title: Text(
              e['city_name'],
              style: TextStyle(
                color: textColor,
              ),
            ),
          ),
        ),
        name: e['city_name'],
        tagIndex: '∧',
      );
      var cityName = e['city_name'];
      var kw = keywords.replaceAll(' ', '').replaceAll('\n', '');
      if (cityName.contains(kw)) {
        list.add(cd);
        continue;
      }
      cityName = cityName.replaceAll('市', '');
      var szm = cityName.split('').map((v) {
        return PinyinHelper.getPinyinE(v).split('').first.toLowerCase();
      }).toString();
      if (kw.length < 2) {
        if (szm.split(',').first.contains(kw.toLowerCase())) {
          list.add(cd);
        }
      } else {
        var py = PinyinHelper.getPinyinE(cityName).toLowerCase();
        int hasLength = 0;
        if (py.split('').first.contains(kw.split('').first.toLowerCase())) {
          for (var v in kw.toLowerCase().split('')) {
            if (py.contains(v)) {
              hasLength++;
            }
          }
        }
        if (hasLength == kw.length) {
          list.add(cd);
        }
      }
    }
    return list;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      if (args == null) return;
      if (args['areaData'] != null) {
        areaData = args['areaData'];
        for (var v in areaData) {
          cityData.add(
            CityData(
              areaCode: v.cityCode ?? '',
              areaName: v.cityName ?? '',
            ),
          );
        }
      }
    });
    loadData();
  }

  @override
  void dispose() {
    super.dispose();
    _ctr.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color primary = myColors.circleBlueButtonBg;
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      resizeToAvoidBottomInset: keywords.isNotEmpty,
      appBar: AppBar(
        title: Text('选择地区'.tr()),
      ),
      body: SafeArea(
        child: KeyboardBlur(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              ThemeBody(
                child: Column(
                  children: [
                    SearchInput(
                      height: 45,
                      radius: 23,
                      controller: _ctr,
                      onChanged: (str) {
                        setState(() {
                          keywords = str;
                        });
                      },
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      alignment: Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '已选择城市:'.tr(),
                              style: TextStyle(
                                color: myColors.iconThemeColor,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                for (var i = 0; i < cityData.length; i++)
                                  cityTag(
                                    title: cityData[i].areaName,
                                    tagBgColor: myColors.circleSelectCityTagbg,
                                    tagTitleColor: myColors.iconThemeColor,
                                    onDelete: () {
                                      delete(cityData[i]);
                                    },
                                  )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    //热门城市
                    if (!isCity && keywords == '') hotCity(),
                    Expanded(
                      child: ContactList(
                        jumpFirst: true,
                        list: [
                          [
                            if (isCity)
                              ContractData(
                                widget: Column(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (_ctr.text.isNotEmpty) {
                                          _ctr.text = keywords = '';
                                          FocusManager.instance.primaryFocus
                                              ?.unfocus();
                                        }
                                        loadData();
                                        isCity = false;
                                        if (mounted) setState(() {});
                                      },
                                      child: ListTile(
                                        title: Text(
                                          '重新选择省份'.tr(),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: primary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      height: 5,
                                      color: myColors.circleBorder,
                                    )
                                  ],
                                ),
                                name: '重新选择省份'.tr(),
                                tagIndex: '∧',
                              ),
                            //特殊城市
                            if (!isCity && keywords == '')
                              for (var e in specialProvince)
                                ContractData(
                                  widget: GestureDetector(
                                    onTap: () {
                                      selectCity(e['city_code']);
                                    },
                                    child: ListTile(
                                      title: Text(
                                        e['city_name'],
                                        style: TextStyle(
                                          color: textColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  name: e['city_name'],
                                  tagIndex: '∧',
                                ),
                            //搜索结果
                            for (var v in _searchList()) v,
                          ]
                        ],
                        orderList: [
                          if (keywords == '')
                            for (var e in province)
                              ContractData(
                                widget: GestureDetector(
                                  onTap: isCity
                                      ? () {
                                          onChoose(e);
                                        }
                                      : () {
                                          selectCity(e['city_code']);
                                        },
                                  child: ListTile(
                                    title: Text(
                                      e['city_name'],
                                      style: TextStyle(
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ),
                                name: e['city_name'],
                              ),
                        ],
                      ),
                    ),
                    if (keywords == '')
                      const TabBottomHeight(
                        height: 68,
                      ),
                  ],
                ),
              ),
              //确认按钮
              if (keywords == '') sureButton(),
            ],
          ),
        ),
      ),
    );
  }

  //已选圈子tag
  Widget cityTag({
    String title = '',
    Color tagBgColor = Colors.white,
    Color tagTitleColor = Colors.black,
    Function()? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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

  //热门城市
  Widget hotCity() {
    var myColors = context.watch<ThemeNotifier>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      alignment: Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              '热门城市:'.tr(),
              style: TextStyle(
                color: myColors.iconThemeColor,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < popularCities.length; i++)
                  GestureDetector(
                    onTap: () {
                      onChoose(popularCities[i]);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: myColors.circleSelectCityTagbg,
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
                            popularCities[i]['city_name'],
                            style: TextStyle(
                                color: myColors.iconThemeColor,
                                fontSize: 15,
                                overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //确认按钮
  Widget sureButton() {
    return BottomButton(
      title: '确定'.tr(),
      onTap: () {
        updateUserSelect();
      },
    );
  }
}

//城市modal
class CityData {
  //城市id
  final String areaCode;

  //城市name
  final String areaName;

  CityData({
    required this.areaCode,
    required this.areaName,
  });
}
