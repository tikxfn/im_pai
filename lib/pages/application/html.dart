import 'dart:async';
import 'package:flutter/material.dart';
import 'package:unionchat/global.dart';
import 'package:webview_flutter/webview_flutter.dart';

// ignore: must_be_immutable
class HtmlPage extends StatefulWidget {
  String? url;
  HtmlPage({super.key, this.url});
  static const String path = 'application/html';
  @override
  State<HtmlPage> createState() => _HtmlPageState();
}

class _HtmlPageState extends State<HtmlPage> {
  late WebViewController controller;

  String? title;

  /// 获取当前加载页面的 title
  Future<void> _loadTitle() async {
    var temp = await controller.getTitle() ?? '123';
    logger.i('title:$temp');
    setState(() {
      title = temp;
    });
  }

//  //跳转外部
  // Future<void> _openOther(BuildContext context, String url) async {
  //   // print('payurl:' + url);
  //   // if (await canLaunch(url)) {
  //   //   await launch(url);
  //   // } else {
  //   //   Scaffold.of(context).showSnackBar(
  //   //     SnackBar(content: Text('未安装支付软件')),
  //   //   );
  //   // }
  // }

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse(widget.url ?? ''))
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (int progress) {
          // Update loading bar.
        },
        onPageStarted: (String url) {},
        onPageFinished: (String url) {
          _loadTitle();
        },
        onWebResourceError: (WebResourceError error) {},
        onNavigationRequest: (request) {
          // if (!request.url.startsWith('http://') &&
          //     !request.url.startsWith('https://')) {
          //   // _openOther(context, request.url);

          //   return NavigationDecision.prevent;
          // }
          return NavigationDecision.navigate;
        },
      ));

    if (mounted) setState(() {});
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title ?? '')),
      body: WillPopScope(
        onWillPop: () {
          return _goBack(context);
        },
        child: WebViewWidget(
          controller: controller,
        ),
      ),
    );
  }
}
