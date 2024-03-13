import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/pages/friend/group_list.dart';
import 'package:unionchat/widgets/button.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';

import '../../../common/func.dart';
import '../../../global.dart';
import '../../../notifier/theme_notifier.dart';

class MallUseCard extends StatefulWidget {
  const MallUseCard({super.key});

  static const String path = 'Mall/use_card';

  @override
  State<MallUseCard> createState() => _MallUseCardState();
}

class _MallUseCardState extends State<MallUseCard> {
  String titleName = '';
  String image = ''; //卡券图片
  GRoomModel? group; //选择的群
  bool waitStatus = false; //发送等待
  GOrderType cardType = GOrderType.NIL;
  GCardModel? cardData; //卡卷信息

  //兑换
  _submit() async {
    switch (cardType) {
      case GOrderType.rOOM500:
        addGroup();
        return;
      case GOrderType.rOOM1000:
        break;
      case GOrderType.rOOM2000:
        break;
      case GOrderType.rOOM5000:
        break;
      case GOrderType.ACCELERATOR_CARD:
        break;
      case GOrderType.CHANGE_NICKNAME_CARD:
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
    }
    return;
  }

  //使用群扩容券
  addGroup() async {
    loading();
    waitStatus = true;
    setState(() {});
    try {
      await RoomApi(apiClient()).roomUpgrade(V1RoomUpgradeArgs(
        cardId: cardData?.id,
        roomId: group?.id,
      ));
      if (!mounted) return;
      tipSuccess('兑换成功'.tr());
      waitStatus = false;
      setState(() {});
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
      waitStatus = false;
      setState(() {});
    }
  }

  //获取券的人数
  getAddNumber(GOrderType type) {
    switch (type) {
      case GOrderType.rOOM500:
        return 500;
      case GOrderType.rOOM1000:
        return 1000;
      case GOrderType.rOOM2000:
        return 2000;
      case GOrderType.rOOM5000:
        return 5000;
      case GOrderType.ACCELERATOR_CARD:
        break;
      case GOrderType.CHANGE_NICKNAME_CARD:
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
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!mounted) return;
      dynamic args = ModalRoute.of(context)!.settings.arguments ?? {};
      if (args['image'] != null) image = args['image'] ?? '';
      if (args['titleName'] != null) titleName = args['titleName'] ?? '';
      if (args['cardData'] != null) cardData = args['cardData'];
      if (args['cardType'] != null) {
        cardType = args['cardType'] ?? GOrderType.NIL;
      }
      logger.i(cardType);
      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          titleName,
        ),
      ),
      body: ThemeBody(
        child: Column(
          children: [
            bodyWidget(cardType),
            if (cardData != null)
              BottomButton(
                title: '立即使用'.tr(),
                onTap: () {
                  _submit();
                },
                disabled: waitStatus,
                fontSize: 19,
                waiting: waitStatus,
              ),
          ],
        ),
      ),
    );
  }

  Widget bodyWidget(cardType) {
    switch (cardType) {
      case GOrderType.rOOM500:
        return groupAdd();
    }
    return Container();
  }

  //群扩容组件
  Widget groupAdd() {
    var myColors = ThemeNotifier();
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  if (image.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 17),
                      child: Image.asset(
                        assetPath(image),
                        width: 70,
                        height: 70,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 15),
                    child: Text(
                      '卡券名称',
                      style: TextStyle(
                        fontSize: 16,
                        color: myColors.iconThemeColor,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Text(
                      cardData?.name ?? '',
                      style: TextStyle(
                        fontSize: 28,
                        color: myColors.iconThemeColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                var resut = await Navigator.pushNamed(context, GroupList.path);
                if (resut == null) return;
                group = resut as GRoomModel;
                setState(() {});
              },
              child: itemWidget(
                leftText: '选择群聊'.tr(),
                rightText: group?.roomName ?? '',
                needRightIcon: true,
              ),
            ),
            itemWidget(
              leftText: '当前群人数上限'.tr(),
              rightText: group?.peopleLimit ?? '',
            ),
            itemWidget(
              leftText: '群上限人数'.tr(),
              rightText:
                  getAddNumber(cardData?.type ?? GOrderType.NIL).toString(),
              rightColo: myColors.greenButtonBg,
            ),
          ],
        ),
      ),
    );
  }

  //行组件
  Widget itemWidget({
    String? leftText,
    String? rightText,
    Color? rightColo,
    bool needRightIcon = false,
  }) {
    var myColors = ThemeNotifier();
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.5,
            color: myColors.circleBorder,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              leftText ?? '',
              style: TextStyle(
                fontSize: 17,
                color: myColors.iconThemeColor,
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Text(
                    rightText ?? '',
                    style: TextStyle(
                      fontSize: 16,
                      color: rightColo ?? myColors.subIconThemeColor,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                if (needRightIcon)
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Image.asset(
                      assetPath('images/my/jiantou.png'),
                      width: 7,
                      height: 13,
                      color: myColors.subIconThemeColor,
                      fit: BoxFit.contain,
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
