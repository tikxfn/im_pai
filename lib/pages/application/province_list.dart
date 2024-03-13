import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:lpinyin/lpinyin.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import '../../notifier/theme_notifier.dart';
import '../../widgets/contact_list.dart';
import '../../widgets/keyboard_blur.dart';
import '../../widgets/search_input.dart';

class ProvinceList extends StatefulWidget {
  const ProvinceList({super.key});

  static const String path = 'application/province';

  @override
  State<StatefulWidget> createState() {
    return _ProvinceListState();
  }
}

class _ProvinceListState extends State<ProvinceList> {
  String keywords = '';
  String city = '';
  String code = '0';
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

  //特殊城市city_code
  List l = ['81', '82', '71', '999'];
  //热门城市city_code
  List popularCityCode = [
    '110100000000',
    '440100000000',
    '440300000000',
    '310100000000'
  ];

  List<String> areaCodeList = [];

  final TextEditingController _ctr = TextEditingController();

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

  selectCity(String id) {
    isCity = true;
    for (var v in province) {
      if (v['city_code'] == id) cityList1.add(v['child']);
    }
    for (var v in specialProvince) {
      if (v['city_code'] == id) cityList1.add(v['child']);
    }
    province.clear();
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

  // 搜索城市
  List<ContractData> _searchList() {
    if (keywords.isEmpty) return [];
    var textColor = ThemeNotifier().iconThemeColor;
    List<ContractData> list = [];
    for (var e in cityAll) {
      var cd = ContractData(
        widget: GestureDetector(
          onTap: () {
            Navigator.pop(context, e);
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
      city = args['city'] ?? '';
      if (args['areaCodeList'] != null) areaCodeList = args['areaCodeList'];
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

    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      resizeToAvoidBottomInset: keywords.isNotEmpty,
      appBar: AppBar(
        title: Text('选择地区'.tr()),
      ),
      body: SafeArea(
        child: KeyboardBlur(
          child: ThemeBody(
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
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  height: 50,
                  child: Row(
                    children: [
                      Text(
                        '当前地区'.tr(),
                        style: TextStyle(
                          color: myColors.iconThemeColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          margin: const EdgeInsets.only(left: 8),
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
                                city,
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
                //热门城市
                if (!isCity && keywords == '') hotCity(),
                Expanded(
                  child: ContactList(
                    list: [
                      [
                        if (!isCity && keywords == '')
                          for (var e in specialProvince)
                            if (e['city_name'].toLowerCase().contains(keywords))
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
                                  tagIndex: '∧'),
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
                                      Navigator.pop(context, e);
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
              ],
            ),
          ),
        ),
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
                      Navigator.pop(context, popularCities[i]);
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
}
