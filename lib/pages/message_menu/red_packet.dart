import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/db/model/message.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class RedPacketPage extends StatefulWidget {
  const RedPacketPage({super.key});

  static const String path = 'redPacket/page';

  @override
  State<RedPacketPage> createState() => _RedPacketPageState();
}

class _RedPacketPageState extends State<RedPacketPage> {
  final _selectTypeStr = '拼手气红包';
  TextEditingController countController = TextEditingController();
  TextEditingController moneyController = TextEditingController();
  TextEditingController topicController = TextEditingController();
  int peopleCount = 0;
  final _currentMoney = ValueNotifier('0.00');
  final isError = ValueNotifier(false);
  String errorText = '';

  //群ID
  String roomID = '';
  final totalCount = ValueNotifier(0);

  Message? _message;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (ModalRoute.of(context)?.settings.arguments == null) {
      return;
    }
    _message = ModalRoute.of(context)?.settings.arguments as Message;
    roomID = (_message?.receiverRoomId ?? '').toString();
    getDetail();
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
        backgroundColor: myColors.backGroundColor,
        appBar: AppBar(
          backgroundColor: myColors.backGroundColor,
          title: const Text('发红包'),
        ),
        body: SingleChildScrollView(
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
                      //选择红包类型
                      GestureDetector(
                        // onTap: () {
                        //   openSheetMenu(context,
                        //       list: ['拼手气红包', '普通红包', '专属红包', '取消']);
                        // },
                        child: Row(
                          children: [
                            Text(
                              '$_selectTypeStr ',
                              style: TextStyle(
                                  color: myColors.yellow,
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500),
                            ),
                            // Image.asset(
                            //   assetPath('images/down.png'),
                            //   height: 15,
                            //   width: 15,
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      //红包个数模块
                      createRedPacketCount(),
                      const SizedBox(
                        height: 6,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
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
                      const SizedBox(
                        height: 16,
                      ),

                      //总金额模块
                      createMoney(),
                      const SizedBox(
                        height: 18,
                      ),
                      //备注
                      createTopic(),

                      const SizedBox(
                        height: 60,
                      ),

                      //金额
                      Center(
                        child: ValueListenableBuilder(
                            valueListenable: _currentMoney,
                            builder: (context, value, _) {
                              return Text(
                                '￥$value',
                                style: TextStyle(
                                  fontSize: 40,
                                  color: myColors.textBlack,
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            }),
                      ),
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
                  '总金额',
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
                controller: moneyController,
                textAlign: TextAlign.end,
                onChanged: (value) {
                  // _currentMoney
                  if (value.contains('.')) {
                    _currentMoney.value = value;
                  } else {
                    if (value == '') {
                      value = '0';
                    }
                    _currentMoney.value = '$value.00';
                  }
                },

                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[0-9.]')),
                  //数字包括小数
                ],
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.all(0),
                  filled: true,
                  hintText: '￥0.00',
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
              child: Text(''),
            ),
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
        if (countController.text == '') {
          errorText = '红包个数不能为空';
          tipError(errorText);
        } else if (moneyController.text == '') {
          errorText = '红包金额不能为空';
          tipError(errorText);
        }
      },
      child: GestureDetector(
        onTap: () {
          if (countController.text == '' || toInt(countController.text) <= 0) {
            errorText = '红包个数不能为空';
            tipError(errorText);
            return;
          }
          if (moneyController.text == '' || toInt(moneyController.text) <= 0) {
            errorText = '红包金额不能为空';
            tipError(errorText);
            return;
          }
          if (toInt(countController.text) > totalCount.value) {
            errorText = '红包个数不能超过当前群聊人数';
            tipError(errorText);
            return;
          }

          sendRedPacketApi();
        },
        child: Center(
          child: Container(
            height: 55,
            width: 200,
            decoration: BoxDecoration(
              // border: new Border.all(color: Colors.white, width: 0.5),
              color: myColors.red,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Text(
                '塞钱进红包',
                style: TextStyle(
                  color: myColors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //获取详情
  getDetail() async {
    final api = RoomApi(apiClient());
    //获取群信息
    try {
      final res = await api.roomGetRoom(V1GetRoomArgs(roomId: roomID));
      if (res == null) return;
      totalCount.value = int.parse(res.room!.totalCount ?? '0');
    } on ApiException catch (e) {
      onError(e);
    } finally {}
    //获取自己在群里的信息
    try {
      final res = await api.roomGetRoom(V1GetRoomArgs(roomId: roomID));
      if (res == null || !mounted) return;
      setState(() {
        // totalCount = res.id;
      });
    } on ApiException catch (e) {
      onError(e);
    } finally {}
  }

  //发送红包
  sendRedPacketApi() async {
    final api = RedEnvelopeApi(apiClient());
    //获取群信息
    try {
      final red = V1RedEnvelopeSendArgs(
        quantity: countController.text,
        isAverage: GSure.NO,
        roomId: roomID,
        mark: topicController.text.isEmpty ? '恭喜发财，大吉大利' : topicController.text,
        amount: number2api(moneyController.text),
      );
      final res = await api.redEnvelopeSend(red);
      if (res == null) return;
      _sendRedPacket(res.id ?? '', res.mark ?? '');
    } on ApiException catch (e) {
      onError(e);
      tip('请确认输入个数和金额。');
    } finally {}
  }

  //发送红包  发消息
  _sendRedPacket(String id, String mark) async {
    // todo:发送普通红包
    loading();
    var msg = Message()
      ..senderUser = getSenderUser()
      ..type = GMessageType.RED_PACKET
      ..content = mark
      ..pairId = generatePairId(toInt(roomID), 0)
      ..contentId = toInt(id)
      ..receiverRoomId = toInt(roomID);
    await MessageUtil.send(msg);
    loadClose();
    tipSuccess('红包发送成功');
    if (mounted) Navigator.pop(context);
  }
}
