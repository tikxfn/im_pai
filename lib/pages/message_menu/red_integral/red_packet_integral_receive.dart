import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

class RedPacketIntegralReceivePage extends StatefulWidget {
  const RedPacketIntegralReceivePage({super.key});

  static const String path = 'red/integral/receive';

  @override
  State<RedPacketIntegralReceivePage> createState() =>
      _RedPacketIntegralReceivePageState();
}

class _RedPacketIntegralReceivePageState
    extends State<RedPacketIntegralReceivePage> {
  //是否是收到的红包
  bool _isReceive = true;

  List<GIntegralRedEnvelopeReceivedModel> _receiveList = [];
  List<GIntegralRedEnvelopeSendModel> _sendList = [];

  @override
  void initState() {
    super.initState();
    _requestDataReceive();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      backgroundColor: myColors.themeBackgroundColor,
      appBar: AppBar(
        backgroundColor: myColors.red,
        title: Text(
          _isReceive ? '收到的红包' : '发出的红包',
          style: TextStyle(color: myColors.goldColor),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showCupertinoDialog(context);
            },
            icon: Icon(
              Icons.more_horiz,
              color: myColors.yellow,
              size: 30.0,
            ),
          ),
        ],
      ),
      body: createBody(),
    );
  }

  Widget createBody() {
    return ListView.builder(
      itemBuilder: (BuildContext context, int index) {
        return _isReceive ? _getDataReceive(index) : _getDataSend(index);
      },
      shrinkWrap: true,
      itemCount: _isReceive ? _receiveList.length : _sendList.length,
    );
  }

  //注意这里是在实例化构造方法的时候就执行了，所以是先创建好数据，再通过下面的方式四来遍历获取数据
  Widget _getDataReceive(int index) {
    var myColors = ThemeNotifier();
    // if (index == 0) {
    //   return _header();
    // }
    // if (_receiveList.isEmpty) {
    //   return Container();
    // }
    var model = _receiveList[index];
    //首先我要说明一下，因为它返回的是一个map类型的值，所以我们就用var让它自动判断来接收值
    return Column(
      children: [
        ListTile(
          title: Text(model.user?.nickname ?? ''),
          subtitle: Text(time2formatDate(model.receivedTime ?? '')),
          trailing: Text('${model.amount} 派币'),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Container(
            color: myColors.backGroundColor,
            height: 1.0,
          ),
        )
      ],
    );
  }

  Widget _getDataSend(int index) {
    var myColors = ThemeNotifier();
    // if (index == 0) {
    //   return _header();
    // }
    // if (_sendList.isEmpty) {
    //   return Container();
    // }
    var model = _sendList[index];
    //首先我要说明一下，因为它返回的是一个map类型的值，所以我们就用var让它自动判断来接收值
    return Column(
      children: [
        ListTile(
          title: const Text('拼手气红包'),
          subtitle: Text(time2formatDate(model.createTime ?? '')),
          trailing: Text('${api2number(model.amount)} 派币'),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 15, right: 15),
          child: Container(
            color: myColors.backGroundColor,
            height: 1.0,
          ),
        )
      ],
    );
  }

  void _showCupertinoDialog(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            // title: Text("First titleime learning"),
            // message: Text("Cupertion learning things"),
            cancelButton: CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  '取消',
                  style: TextStyle(color: myColors.textBlack, fontSize: 16),
                )),
            actions: <Widget>[
              CupertinoActionSheetAction(
                onPressed: () {
                  if (!_isReceive) {
                    _isReceive = true;
                    _requestDataReceive();
                  }
                  Navigator.of(context).pop();
                },
                child: Text(
                  '收到的红包',
                  style: TextStyle(color: myColors.textBlack, fontSize: 16),
                ),
              ),
              CupertinoActionSheetAction(
                  onPressed: () {
                    if (_isReceive) {
                      _isReceive = false;
                      _requestDataSend();
                    }
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '发出的红包',
                    style: TextStyle(color: myColors.textBlack, fontSize: 16),
                  )),
            ],
          );
        });
  }

  //获取红包领取记录的接口
  _requestDataReceive() async {
    try {
      // var res = await RedEnvelopeApi(apiClient())
      //     .redEnvelopeSendDetails(GIdArgs(id: id));
      var res = await IntegralRedEnvelopeApi(apiClient())
          .integralRedEnvelopeReceivedList(
        V1IntegralRedEnvelopeReceivedListArgs(
          pager: GPagination(limit: '100'),
        ),
      );
      if (res != null) {
        // tipSuccess('数据获取成功');
        _receiveList = res.list;
        setState(() {});
      } else {
        tipError('数据获取失败');
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }

  //发出红包记录的接口
  _requestDataSend() async {
    try {
      // var res = await RedEnvelopeApi(apiClient())
      //     .redEnvelopeReceivedList(V1RedEnvelopeReceivedListArgs());
      var res = await IntegralRedEnvelopeApi(apiClient())
          .integralRedEnvelopeSendList(GPagination(limit: '100'));
      if (res != null) {
        // tipSuccess('数据获取成功');
        _sendList = res.list;
        setState(() {});
      } else {
        tipError('数据获取失败');
      }
    } on ApiException catch (e) {
      onError(e);
    } finally {
      loadClose();
    }
  }
}
