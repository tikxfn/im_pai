import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class RedPacketIntegralPage extends StatefulWidget {
  const RedPacketIntegralPage({super.key});

  static const String path = 'red/integral/page';

  @override
  State<RedPacketIntegralPage> createState() => _RedPacketIntegralPageState();
}

class _RedPacketIntegralPageState extends State<RedPacketIntegralPage> {
  final List<String> _redPacketTypeList = ['拼手气红包', '普通红包'];
  int _redPacketType = 0;
  TextEditingController countController = TextEditingController();
  TextEditingController moneyController = TextEditingController();
  TextEditingController topicController = TextEditingController();
  int peopleCount = 0;
  final _currentMoney = ValueNotifier('0');
  final isError = ValueNotifier(false);
  String errorText = '';
  double integral = 0;

  //群ID
  String roomId = '';
  String receiverId = '';
  final totalCount = ValueNotifier(0);

  Message? _message;

  // 计算所需金额
  int countAmount() {
    int amount = toInt(moneyController.text);
    if (_redPacketType == 1) {
      amount *= toInt(countController.text);
    }
    return amount;
  }

  _init() async {
    await Global.syncLoginUser();
    if (!mounted) return;
    setState(() {
      integral = toDouble(Global.user?.integral);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.settings.arguments == null) {
      return;
    }
    _message = ModalRoute.of(context)?.settings.arguments as Message;
    roomId = (_message?.receiverRoomId ?? '').toString();
    receiverId = (_message?.receiverUserId ?? '').toString();
    getDetail();
    _init();
  }

  @override
  dispose() {
    super.dispose();
    countController.dispose();
    moneyController.dispose();
    topicController.dispose();
    _currentMoney.dispose();
    isError.dispose();
    totalCount.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return GestureDetector(
      behavior: HitTestBehavior.opaque, //要设置behavior属性，不然可能点击无效
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Scaffold(
        //键盘弹出高度超出解决
        resizeToAvoidBottomInset: false,
        backgroundColor: myColors.redPacketdBg,
        appBar: AppBar(
          // backgroundColor: myColors .backGroundColor,
          title: Text(
            '发红包',
            style: TextStyle(
              color: myColors.white,
            ),
          ),
          iconTheme: IconThemeData(color: myColors.white),
        ),
        body: Column(
          children: [
            Expanded(
              child: ThemeBody(
                bodyColor: myColors.tagColor,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: ValueListenableBuilder(
                        valueListenable: isError,
                        builder: (context, value, _) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            // padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                            children: [
                              //错误提示  头部
                              if (value)
                                Column(
                                  children: [
                                    SizedBox(
                                      height: 24,
                                      child: Expanded(
                                        flex: 1,
                                        child: Container(
                                          color: myColors.yellow,
                                          alignment: Alignment.centerRight,
                                          child: Center(
                                            child: Text(
                                              errorText,
                                              style: TextStyle(
                                                color: myColors.white,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                  ],
                                ),
                              if (roomId.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    //选择红包类型
                                    GestureDetector(
                                      onTap: () {
                                        openSheetMenu(
                                          context,
                                          list: _redPacketTypeList,
                                          onTap: (i) {
                                            setState(() {
                                              _redPacketType = i;
                                            });
                                          },
                                        );
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            _redPacketTypeList[_redPacketType],
                                            style: TextStyle(
                                              color: myColors.yellow,
                                            ),
                                          ),
                                          Icon(
                                            Icons.keyboard_arrow_down,
                                            color: myColors.yellow,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 16,
                                    ),
                                    //红包个数模块
                                    createRedPacketCount(),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10, top: 6, bottom: 16),
                                      child: ValueListenableBuilder(
                                          valueListenable: totalCount,
                                          builder: (context, value, _) {
                                            return Text(
                                              '本群共$value人',
                                              style: TextStyle(
                                                color: myColors.textGrey,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            );
                                          }),
                                    ),
                                  ],
                                ),

                              //总金额模块
                              createMoney(),
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 18, top: 10),
                                child: Text(
                                  '可用 $integral 派币',
                                  style: TextStyle(
                                    color: myColors.textGrey,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              //备注
                              createTopic(),

                              const SizedBox(height: 60),

                              //金额
                              Center(
                                child: Text(
                                  countAmount().toString(),
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: myColors.textBlack,
                                    fontWeight: FontWeight.w300,
                                  ),
                                ),
                              ),
                              //金额
                              // Center(
                              //   child: ValueListenableBuilder(
                              //       valueListenable: _currentMoney,
                              //       builder: (context, value, _) {
                              //         return Text.rich(
                              //           TextSpan(
                              //               // text: '派币 ',
                              //               children: [
                              //                 TextSpan(
                              //                   text: value,
                              //                   style: const TextStyle(
                              //                     fontSize: 40,
                              //                     color: myColors.textBlack,
                              //                     fontWeight: FontWeight.bold,
                              //                   ),
                              //                 ),
                              //               ]),
                              //         );
                              //       }),
                              // ),
                              const SizedBox(
                                height: 30,
                              ),
                              //提交按钮
                              createSureBtn(),
                            ],
                          );
                        }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //选择红包个数
  createRedPacketCount() {
    var myColors = ThemeNotifier();
    return Container(
      height: 50,
      decoration: BoxDecoration(
        // border: new Border.all(color: Colors.white, width: 0.5),
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Row(
          children: [
            Row(
              children: [
                const SizedBox(
                  width: 16,
                ),
                Image.asset(
                  assetPath('images/red_packet_message.png'),
                  height: 20,
                  width: 20,
                ),
                const SizedBox(
                  width: 8,
                ),
                const Text(
                  '红包个数',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                margin: const EdgeInsets.only(left: 10),
                alignment: Alignment.centerRight,
                child: Container(),
              ),
            ),
            Container(
              color: Colors.white,
              height: 50,
              width: 100,
              child: TextFormField(
                // autofocus: true,
                maxLines: 1,
                keyboardType: TextInputType.number,
                controller: countController,
                textAlign: TextAlign.end,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9]')),
                  //数字包括小数
                ],
                onChanged: (value) {
                  if (toInt(value) > totalCount.value) {
                    errorText = '红包个数不能超过当前群聊人数';
                  } else {
                    if (isError.value) {
                      errorText = '';
                    }
                  }
                  setState(() {});
                },

                validator: (value) {
                  if (toInt(value ?? '0') > totalCount.value) {
                    errorText = '红包个数不能超过当前群聊人数';
                  }
                  return '';
                },

                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  filled: true,
                  hintText: '填写个数',
                  hintStyle:
                      const TextStyle(color: Color(0xffAFAFAF), fontSize: 13),
                  fillColor: Colors.white,
                  focusColor: Colors.white,
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(width: 0.5, color: Colors.white),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 0.5, color: myColors.white),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 10, right: 15),
              child: Text('个'),
            ),
          ],
        ),
      ),
    );
  }

  //总金额
  createMoney() {
    var myColors = ThemeNotifier();
    return Container(
      height: 50,
      decoration: BoxDecoration(
        // border: new Border.all(color: Colors.white, width: 0.5),
        color: myColors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Row(
          children: [
            Row(
              children: [
                const SizedBox(width: 16),
                Image.asset(
                  assetPath('images/red_packet_message.png'),
                  height: 20,
                  width: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  _redPacketType == 0 ? '总金额' : '红包金额',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Expanded(
              flex: 1,
              child: Container(
                color: myColors.white,
                margin: const EdgeInsets.only(left: 10),
                alignment: Alignment.centerRight,
                child: TextFormField(
                  // autofocus: true,
                  maxLines: 1,
                  keyboardType: TextInputType.number,
                  controller: moneyController,
                  textAlign: TextAlign.end,
                  onChanged: (value) {
                    setState(() {});
                  },

                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                    //数字包括小数
                  ],
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.all(0),
                    filled: true,
                    hintText: '最少 1 派币的整数',
                    hintStyle:
                        const TextStyle(color: Color(0xffAFAFAF), fontSize: 13),
                    fillColor: Colors.white,
                    focusColor: Colors.white,
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.5, color: Colors.white),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(width: 0.5, color: myColors.white),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 25),
          ],
        ),
      ),
    );
  }

  //备注
  createTopic() {
    var myColors = ThemeNotifier();
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Center(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                color: Colors.white,
                margin: const EdgeInsets.only(left: 20, right: 20),
                alignment: Alignment.centerRight,
                child: Container(
                  color: Colors.white,
                  height: 50,
                  // width: 100,
                  child: TextFormField(
                    // autofocus: true,
                    maxLines: 1,
                    // keyboardType: TextInputType.number,
                    controller: topicController,
                    // textAlign: TextAlign.end,
                    // inputFormatters: [
                    //   FilteringTextInputFormatter.allow(RegExp("[0-9]")),
                    //   //数字包括小数
                    // ],
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.all(0),
                      filled: true,
                      hintText: '恭喜发财',
                      hintStyle: const TextStyle(
                          color: Color(0xffAFAFAF), fontSize: 15),
                      fillColor: Colors.white,
                      focusColor: Colors.white,
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(width: 0.5, color: Colors.white),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(width: 0.5, color: myColors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //提交按钮
  createSureBtn() {
    var myColors = ThemeNotifier();
    return GestureDetector(
      onTap: () {
        if (roomId.isNotEmpty && toInt(countController.text) <= 0) {
          errorText = '红包个数不能为空';
          tipError(errorText);
          return;
        }
        if (toInt(moneyController.text) <= 0) {
          errorText = '红包金额不能为空';
          tipError(errorText);
          return;
        }
        if (moneyController.text.contains('.')) {
          errorText = '请输入最少 1 派币的整数';
          tipError(errorText);
          return;
        }
        if (countAmount() > integral) {
          errorText = '可用派币不足';
          tipError(errorText);
          return;
        }
        if (roomId.isNotEmpty &&
            toInt(countController.text) > totalCount.value) {
          errorText = '红包个数不能超过当前群聊人数';
          tipError(errorText);
          return;
        }
        sendRedPacketApi();
      },
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          height: 49,
          decoration: BoxDecoration(
            color: myColors.redPacketdBg,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Text(
              '塞钱进红包',
              style: TextStyle(
                color: myColors.white,
                fontWeight: FontWeight.w500,
                fontSize: 19,
              ),
            ),
          ),
        ),
      ),
    );
  }

  //获取详情
  getDetail() async {
    if (roomId.isEmpty) return;
    final api = RoomApi(apiClient());
    //获取群信息
    try {
      final res = await api.roomGetRoom(V1GetRoomArgs(roomId: roomId));
      if (res == null || !mounted) return;
      totalCount.value = toInt(res.room?.totalCount);
      setState(() {});
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //发送红包
  sendRedPacketApi() async {
    loading();
    final api = IntegralRedEnvelopeApi(apiClient());
    try {
      final red = V1IntegralRedEnvelopeSendArgs(
        quantity: roomId.isNotEmpty ? countController.text : '1',
        isAverage: _redPacketType == 1 || roomId.isEmpty ? GSure.YES : GSure.NO,
        mark: topicController.text.isEmpty ? '恭喜发财，大吉大利' : topicController.text,
        amount: countAmount().toString(),
      );
      if (roomId.isNotEmpty) red.roomId = roomId;
      if ((_message?.receiverUserId ?? '').toString().isNotEmpty) {
        red.receivedUserId = (_message?.receiverUserId ?? '').toString();
      }
      // logger.d(red);
      final res = await api.integralRedEnvelopeSend(red);
      if (res == null) return;
      tipSuccess('红包发送成功');
      MessageUtil.receive(res, checkDno: false);
      if (mounted) Navigator.pop(context);
    } on ApiException catch (e) {
      onError(e);
      // tip('请确认输入个数和金额。');
    } finally {
      loadClose();
    }
  }

  //发送红包  发消息
  // _sendRedPacket(String id) async {
  //   loading();
  //   var res = await ApiRequest.apiSendMessage(
  //     data: MessageData(type: MessageType.redPacketIntegral),
  //     ids: [receiverId],
  //     roomIds: [roomId],
  //     contentIds: [id],
  //   );

  //   loadClose();
  //   if (res != null && res.isNotEmpty) {
  //     tipSuccess('红包发送成功');
  //     ChatTalkNotifier().add(ValueNotifier(MessageData.fromGChatModel(res[0])));
  //     if (mounted) Navigator.pop(context);
  //   } else {
  //     tipError('红包发送失败');
  //   }
  // }
}
