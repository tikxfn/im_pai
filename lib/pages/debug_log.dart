import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/global.dart';

class AppDebugLog extends StatefulWidget {
  const AppDebugLog({super.key});

  @override
  State<AppDebugLog> createState() => _AppDebugLogState();
}

class _AppDebugLogState extends State<AppDebugLog> {
  String netState = '';

  _init() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      netState = connectivityResult.name;
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) _init();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('日志记录'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Text('当前网络状态：$netState'),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: Global.initLogs.map((e) {
              return Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.black,
                      width: .5,
                    ),
                  ),
                ),
                child: Text(e),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
