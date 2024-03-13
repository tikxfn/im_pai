import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/form_widget.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';
import '../../../../notifier/theme_notifier.dart';

class UserNumberList extends StatefulWidget {
  const UserNumberList({super.key});

  static const String path = 'circle/usernumber_list';

  @override
  State<StatefulWidget> createState() {
    return UserNumberListState();
  }
}

class UserNumberListState extends State<UserNumberList> {
  static List<GUserNumberType> numberLevel = [
    GUserNumberType.LEOPARD,
    GUserNumberType.HONORABLE,
    GUserNumberType.STRAIGHT,
    GUserNumberType.SHORT,
    GUserNumberType.EXCELLENT,
    GUserNumberType.OTHER,
  ];

  List<GUserNumberType> selectType = [];

  //选择用户
  onChoose(GUserNumberType e) {
    if (selectType.contains(e)) {
      selectType.remove(e);
    } else {
      selectType.add(e);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments;
      if (args == null) return;
      if (args['typeList'] != null) selectType.addAll(args['typeList']);
      logger.i(selectType);
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();

    return Scaffold(
      appBar: AppBar(
        title: Text('选择靓号类型'.tr()),
        // actions: [
        //   TextButton(
        //     onPressed: () {
        //       Navigator.pop(context, selectType);
        //     },
        //     child: Text('保存'.tr()),
        //   )
        // ],
      ),
      body: ThemeBody(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Container(
                    color: myColors.themeBackgroundColor,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: numberLevel.map((e) {
                        return GestureDetector(
                          onTap: () => onChoose(e),
                          child: Row(
                            children: [
                              AppCheckbox(
                                value: selectType.contains(e),
                                size: 25,
                                paddingLeft: 15,
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 16),
                                  child: Text(
                                    goodNumberType2string(e),
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                    ),
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
            BottomButton(
              title: '保存'.tr(),
              onTap: () {
                Navigator.pop(context, selectType);
              },
            ),
          ],
        ),
      ),
    );
  }
}
