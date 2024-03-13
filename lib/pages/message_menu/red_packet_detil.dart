import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/message_menu/red_packet_receive.dart';
import 'package:unionchat/widgets/chat_item.dart';
import 'package:unionchat/widgets/pager_box.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class RedPacketDetilPage extends StatefulWidget {
  const RedPacketDetilPage({Key? key}) : super(key: key);
  static const String path = 'redPacketdetil/page';

  @override
  State<RedPacketDetilPage> createState() => _RedPacketDetilPageState();
}

class _RedPacketDetilPageState extends State<RedPacketDetilPage> {
  //群ID
  String roomID = '';
  int totalCount = 0;

  Message? _message;

  V1RedEnvelopeSendDetailsResp? _res;

  //红包备注
  String? _mark;

  //红包的数量
  String? _redPCount;

  //已领取红包的数量
  String? _redPCounted;

  //领取的金额
  String? _surAmount;

  //总金额
  double _amount = 0;

  int limit = 20;

  List<GRedEnvelopeReceivedModel> _list = [];

  //获取列表
  _getList({bool init = false, bool load = false}) async {
    if (load) loading();
    final api = RedEnvelopeApi(apiClient());
    try {
      var args = V1RedEnvelopeSendDetailsReceivedArgs(
        id: (_message?.contentId ?? '').toString(),
        pager: GPagination(
          limit: limit.toString(),
          offset: init ? '0' : _list.length.toString(),
        ),
      );
      final res = await api.redEnvelopeSendDetailsReceived(args);
      if (res == null || !mounted) return 0;
      List<GRedEnvelopeReceivedModel> l = res.list.toList();
      setState(() {
        if (init) {
          _list = l;
        } else {
          _list.addAll(l);
        }
      });
      return res.list.length;
    } on ApiException catch (e) {
      onError(e);
      return limit;
    } finally {
      if (load) loadClose();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.settings.arguments == null) {
      return;
    }
    _message = ModalRoute.of(context)?.settings.arguments as Message;
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        // title: ,
        backgroundColor: myColors.red,
        actions: [
          IconButton(
            onPressed: () {
              // Navigator.pushNamed(context, RedPacketReceivePage.path);
              // _shoCuportionDialog(context);
              Navigator.pushNamed(context, RedPacketReceivePage.path);
            },
            icon: const Icon(Icons.more_horiz),
          ),
        ],
      ),
      body: PagerBox(
        limit: limit,
        onInit: () async {
          _requestData();
          return await _getList(init: true);
        },
        onPullDown: () async {
          _requestData();
          return await _getList(init: true);
        },
        onPullUp: () async {
          return await _getList();
        },
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Text(
                      '${_message?.senderUser?.nickname ?? ''}的红包',
                      style: TextStyle(
                          color: myColors.textBlack,
                          fontSize: 16,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 10),
              Text(
                _mark ?? '',
                style: TextStyle(
                  color: myColors.textGrey,
                  fontSize: 14,
                  // fontWeight: FontWeight.w600
                ),
              ),
              const SizedBox(height: 30),
              if (_surAmount != null && _surAmount!.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _surAmount!,
                      style: TextStyle(
                          color: myColors.yellow,
                          fontSize: 44,
                          fontWeight: FontWeight.w600),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '已存入钱包',
                          style: TextStyle(
                              color: myColors.yellow,
                              fontSize: 14,
                              fontWeight: FontWeight.w500),
                        ),
                        // Icon(
                        //   Icons.chevron_right,
                        //   color: myColors.yellow,
                        // )
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              Container(color: myColors.backGroundColor, height: 14),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '领取${_redPCounted ?? '0'}/${_redPCount ?? '0'}个',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: myColors.textGrey,
                    fontSize: 15,
                    // fontWeight: FontWeight.w500
                  ),
                ),
                if ((_amount > 0 && _res?.details?.userId == Global.user!.id) ||
                    (_message?.receiverRoomId ?? '').toString().isEmpty)
                  Text('共 $_amount 元'),
              ],
            ),
          ),
          Container(color: myColors.backGroundColor, height: 1),
          Column(
            children: _list.map((model) {
              var user = model.user;
              return ChatItem(
                border: true,
                data: ChatItemData(
                  icons: [user?.avatar ?? ''],
                  title: user?.nickname ?? '',
                  mark: user?.mark ?? '',
                  id: user?.id ?? '',
                  vip: toInt(user?.userExtend?.vipExpireTime) >=
                      toInt(date2time(null)),
                  vipLevel: user?.userExtend?.vipLevel ?? GVipLevel.NIL,
                  vipBadge: user?.userExtend?.vipBadge ?? GBadge.NIL,
                  goodNumber: (user?.userNumber ?? '').isNotEmpty,
                  numberType: user?.userNumberType ?? GUserNumberType.NIL,
                  circleGuarantee: toBool(user?.userExtend?.circleGuarantee),
                  onlyName: toBool(user?.useChangeNicknameCard),
                  text: time2formatDate(model.receivedTime ?? ''),
                ),
                end: Text(
                  '${api2number(model.amount)}元',
                  style: TextStyle(
                      color: myColors.textBlack,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  //获取红包领取详情的接口
  _requestData() async {
    loading();
    try {
      String id = (_message?.contentId ?? '').toString();
      _res = await RedEnvelopeApi(apiClient())
          .redEnvelopeSendDetails(GIdArgs(id: id));
      if (_res == null || !mounted) return;
      _amount = toDouble(api2number(_res?.details?.amount));
      _mark = _res?.details?.mark ?? '恭喜发财，大吉大利';
      _redPCount = _res?.details?.quantity ?? '0';
      String redPCounted = _res?.details?.surplusQuantity ?? '0';
      int currentC = int.parse(_redPCount!) - int.parse(redPCounted);
      _redPCounted = currentC.toString();
      var surAmount = toDouble(api2number(_res?.meReceived?.amount));
      if (surAmount > 0) _surAmount = surAmount.toString();
      setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }
}
