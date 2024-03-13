import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/pages/mall/my_card/mall_use_card.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../../common/interceptor.dart';
import '../../../notifier/theme_notifier.dart';
import '../../../widgets/set_name_input.dart';

class MallMyCard extends StatefulWidget {
  const MallMyCard({
    super.key,
  });

  static const String path = 'mall/my_card';

  @override
  State<MallMyCard> createState() => _MallMyCardState();
}

class _MallMyCardState extends State<MallMyCard> {
  List<GCardModel> _list = [];
  GOrderType cardType = GOrderType.NIL; //传入card类型
  String titleName = '';
  String image = '';

  //获取卡券
  _getList() async {
    var api = CardApi(apiClient());
    try {
      var res = await api.cardListCard({});
      if (res == null || !mounted) return;
      List<GCardModel> newList = [];
      if (cardType == GOrderType.CHANGE_NICKNAME_CARD) {
        //如果是唯名卡
        for (var v in res.list) {
          if (v.type == cardType) newList.add(v);
        }
      }
      if (cardType == GOrderType.rOOM500) {
        //如果是群扩容
        for (var v in res.list) {
          if (v.type == GOrderType.rOOM500) newList.add(v);
          if (v.type == GOrderType.rOOM1000) newList.add(v);
          if (v.type == GOrderType.rOOM2000) newList.add(v);
          if (v.type == GOrderType.rOOM5000) newList.add(v);
        }
      }
      _list = newList;
      logger.i(_list);
      setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  //使用卡券
  useCard(GCardModel e) {
    switch (cardType) {
      //根据传入card类型跳转，群扩容类型为GOrderType.rOOM500
      case GOrderType.CHANGE_NICKNAME_CARD: //唯名卡
        _useOnlyCard(e.name ?? '', e.id ?? '');
        return;
      case GOrderType.rOOM500: //群扩容
        Navigator.pushNamed(context, MallUseCard.path, arguments: {
          'image': image,
          'titleName': titleName,
          'cardData': e,
          'cardType': cardType,
        }).then((value) async {
          await _getList();
        });
        return;
      case GOrderType.rOOM1000:
        break;
      case GOrderType.rOOM2000:
        break;
      case GOrderType.rOOM5000:
        break;
      case GOrderType.GRAB_ORDER:
        break;
      case GOrderType.GROWTH:
        break;
      case GOrderType.INTEGRAL:
        break;
      case GOrderType.NIL:
        break;
      case GOrderType.NUMBER:
        break;
      case GOrderType.RENEW_NUMBER:
        break;
      case GOrderType.ROBOT:
        break;
      case GOrderType.VIP:
        break;
      case GOrderType.ACCELERATOR_CARD:
        break;
    }

    return;
  }

  //使用唯名卡
  _useOnlyCard(String name, String id) {
    if (id.isEmpty) return;
    Navigator.push(
      context,
      CupertinoModalPopupRoute(builder: (context) {
        return SetNameInput(
          title: name,
          subTitle: '修改后的昵称不能重复'.tr(),
          value: Global.user?.nickname ?? '',
          onEnter: (val) async {
            return await _saveNickName(userName: val, cardId: id);
          },
        );
      }),
    );
  }

  //保存昵称
  Future<bool> _saveNickName({
    String? userName,
    String? cardId,
  }) async {
    loading();
    if (userName == null) return false;
    V1SetBasicInfoArgs args = V1SetBasicInfoArgs(
      nickname: V1SetBasicInfoArgsValue(value: userName),
      cardId: SetBasicInfoArgsCardId(cardId: cardId),
    );
    var api = UserApi(apiClient());
    try {
      await api.userSetBasicInfo(args);
      Global.syncLoginUser();
      _getList();
      return true;
    } on ApiException catch (e) {
      onError(e);
      return false;
    } catch (e) {
      logger.e(e);
      return false;
    } finally {
      loadClose();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)?.settings.arguments ?? {};
      if (args['cardType'] != null) {
        cardType = args['cardType'] ?? GOrderType.NIL;
      }
      if (args['image'] != null) image = args['image'] ?? '';
      if (args['titleName'] != null) titleName = args['titleName'] ?? '';
    });
    _getList();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    Color primary = myColors.primary;
    Color textColor = myColors.iconThemeColor;
    return Scaffold(
      appBar: AppBar(
        title: Text(titleName),
      ),
      body: ThemeBody(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          children: _list.map((e) {
            var status = '';
            switch (e.status) {
              case GCardStatus.EXPIRE:
                status = '已过期'.tr();
                break;
              case GCardStatus.NIL:
                break;
              case GCardStatus.NO:
                break;
              case GCardStatus.REFUND:
                status = '已退款'.tr();
                break;
              case GCardStatus.YES:
                status = '已使用'.tr();
                break;
            }
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: .5,
                    color: myColors.lineGrey,
                  ),
                ),
              ),
              child: Row(
                children: [
                  if (image.isNotEmpty)
                    Image.asset(
                      assetPath(image),
                      height: 20,
                    ),
                  const SizedBox(width: 5),
                  Expanded(
                    flex: 1,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: e.name,
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (status.isNotEmpty)
                            TextSpan(
                              text: '（$status）',
                              style: TextStyle(
                                color: myColors.red,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (e.status == GCardStatus.NO)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        useCard(e);
                      },
                      child: Row(
                        children: [
                          Text(
                            '点击使用'.tr(),
                            style: TextStyle(
                              color: primary,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 15,
                            color: primary,
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
