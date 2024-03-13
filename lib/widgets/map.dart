import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

class MapLocation {
  final String location;
  final String title;
  final String desc;

  MapLocation({
    required this.location,
    required this.title,
    required this.desc,
  });
}

class AppMap extends StatefulWidget {
  final bool showMap;
  final MapLocation? location;
  final Function(MapLocation)? onEnter;

  const AppMap({
    this.showMap = false,
    this.location,
    this.onEnter,
    super.key,
  });

  @override
  State<AppMap> createState() => _AppMapState();
}

class _AppMapState extends State<AppMap> {
  late final WebViewController _controller;
  late final String lat;
  late final String lng;
  MapLocation? _location;

  final String htmlContent = '''
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1.0, minimum-scale=1.0, maximum-scale=1.0, user-scalable=no">
  <title>Map Picker</title>
</head>
<style type="text/css">
  body,html { background: transparent; margin: 0; padding: 0; height: 100%;}
</style>
<body>
  <iframe id="mapPage" width="100%" height="100%" frameborder=0
      src="https://m.amap.com/picker/?keywords=&zoom=&center=&radius=&total=&key=06e442a7fc2b0bd321cc05e76c2d466c">
  </iframe>
  <script>
    window.addEventListener('message', function(event) {
        // 接收位置信息，用户选择确认位置点后选点组件会触发该事件，回传用户的位置信息
        window.messageHandler.postMessage(JSON.stringify(loc));
    }, false);
  </script>

</body>
</html>
''';

  // 选择位置监听
  _locationChange(String str) {
    if (!mounted) return;
    if (str.isEmpty) {
      setState(() {
        _location = null;
      });
      return;
    }
    var json = jsonDecode(str);
    setState(() {
      _location = MapLocation(
        location: '${json['location'][1]},${json['location'][0]}',
        title: json['name'] ?? '',
        desc: json['address'] ?? '',
      );
    });
  }

  // 显示地图列表
  _showAlertDialog() {
    if (!widget.showMap || widget.location == null) return;
    List<String> apps = ['高德地图', '百度地图'];
    if (Platform.isIOS) {
      apps.add('苹果地图');
    }
    openSheetMenu(
      context,
      list: apps,
      onTap: (i) {
        if (i == 0) _gotoAMapByKeywords();
        if (i == 1) _gotoBaiduMapByKeywords();
        if (i == 2) _gotoAppleMapByKeywords();
      },
    );
  }

  // 苹果地图
  _gotoAppleMapByKeywords() async {
    var url =
        'http://maps.apple.com/?ll=$lat,$lng&daddr=${Uri.encodeComponent(widget.location!.title)}';
    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        tip('无法打开苹果地图');
      }
    } on Exception {
      tip('无法打开苹果地图');
    }
  }

  // 高德地图
  _gotoAMapByKeywords() async {
    var head =
        Platform.isAndroid ? 'androidamap://route/plan/?' : 'iosamap://path?';
    var headAndroid = 'amapuri://route/plan/?';
    var linkUrl =
        'sourceApplication=${Global.versionInfo.appName}&did=&dlat=$lat&dlon=$lng&dname=${widget.location!.title}&dev=0&t=0';
    var url = '$head$linkUrl';
    if (Platform.isIOS) url = Uri.encodeFull(url);
    var uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri)) {
        var aUrl = '$headAndroid$linkUrl';
        uri = Uri.parse(aUrl);
        if (!Platform.isAndroid || !await launchUrl(uri)) {
          tip('无法打开高德地图');
        }
      }
    } catch (e) {
      tip('无法打开高德地图');
      logger.d(e);
    }
  }

  //高德经纬度转百度经纬度
  Map gaode2baidu(lng, lat) {
    var xPi = 3.14159265358979324 * 3000.0 / 180.0;
    var x = double.tryParse(lng) ?? 0;
    var y = double.tryParse(lat) ?? 0;
    var z = sqrt(x * x + y * y) + 0.00002 * sin(y * xPi);
    var theta = atan2(y, x) + 0.000003 * cos(x * xPi);
    var lngs = z * cos(theta) + 0.0065;
    var lats = z * sin(theta) + 0.006;
    return {'lng': lngs, 'lat': lats};
  }

  // 百度地图
  _gotoBaiduMapByKeywords() async {
    var d = gaode2baidu(lng, lat);
    var latitude = d['lat'];
    var longitude = d['lng'];
    String url =
        'baidumap://map/direction?region=&origin=&destination=$latitude,$longitude&coord_type=bd09ll&mode=driving&src=andr.flutter.im';
    if (Platform.isIOS) url = Uri.encodeFull(url);
    // log.d(url);
    try {
      if (await canLaunchUrlString(url)) {
        await launchUrlString(url);
      } else {
        tip('无法打开百度地图');
      }
    } on Exception {
      tip('无法打开百度地图');
    }
  }

  // 页面加载状态
  _webLoadState(String state) {
    switch (state) {
      case 'loading':
        loading();
        break;
      case 'loadclose':
        loadClose();
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    var url = Global.systemInfo.settingUrl?.settingUrl?.mapUrl ?? '';
    // url = 'https://map.genative.cn';
    if (url.isEmpty) {
      tipError('未获取到服务地址');
      _controller = WebViewController();
      return;
    }
    url += '/map/index.html';
    var args = '';
    Map<String, String> json = {
      'lnglat': '',
      'name': '',
      'desc': '',
    };
    if (widget.showMap && widget.location != null) {
      var lr = widget.location!.location.split(',');
      if (lr.length >= 2) {
        lat = lr[0];
        lng = lr[1];
        json['lnglat'] = '$lng,$lat';
        json['name'] = widget.location!.title;
        json['desc'] = widget.location!.desc;
        args =
            'lnglat=${json['lnglat']}&name=${json['name']}&desc=${json['desc']}&time=${date2time(null)}';
        url = '$url?$args';
      }
    } else {
      url = '$url?time=${date2time(null)}';
    }
    // logger.d(url);
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    controller
      ..setOnConsoleMessage((message) {
        logger.d(message.message);
      })
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            // logger.d(progress);
          },
          onPageStarted: (String u) {
            // _controller.runJavaScript('''
            //   var inputElement = document.createElement("input");
            //   inputElement.setAttribute("id", "feiou");
            //   inputElement.setAttribute("type", "hidden");
            //   inputElement.setAttribute("value", "$url");
            //   document.body.appendChild(inputElement);
            // ''');

            // _controller.runJavaScript('''
            //   var feiou = {};
            //   feiou.params = ${jsonEncode(json)};
            // ''');
            // _controller.runJavaScript(
            //     'window.params = ${jsonEncode(json)};console.log(window.params);');
            loading();
          },
          onPageFinished: (String url) {
            loadClose();
          },
          onWebResourceError: (WebResourceError error) {
            loadClose();
            logger.d(error.description);
          },
        ),
      )
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'messageHandler',
        onMessageReceived: (JavaScriptMessage message) {
          // logger.d(message.message);
          _locationChange(message.message);
        },
      )
      ..addJavaScriptChannel(
        'navigatorHandler',
        onMessageReceived: (JavaScriptMessage message) {
          _showAlertDialog();
        },
      )
      ..addJavaScriptChannel(
        'loadStateHandler',
        onMessageReceived: (JavaScriptMessage message) {
          _webLoadState(message.message);
        },
      )
      ..addJavaScriptChannel(
        'errorHandler',
        onMessageReceived: (JavaScriptMessage message) {
          logger.d(message.message);
        },
      )
      // ..runJavaScriptReturningResult('testFunc();')
      // ..runJavaScript('paramsInit(${jsonEncode(json)})')
      // ..loadFlutterAsset('assets/html/im-map/index.html');
      // ..loadHtmlString(htmlContent);
      ..loadRequest(Uri.parse(url));
    // 安卓webview
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setGeolocationPermissionsPromptCallbacks(
        onShowPrompt: (permission) async {
          return const GeolocationPermissionsResponse(
            allow: true,
            retain: true,
          );
        },
      );
    }
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return ThemeImage(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.showMap ? '位置详情' : '选择位置'),
          actions: [
            if (!widget.showMap)
              TextButton(
                onPressed: () {
                  if (_location == null) return;
                  widget.onEnter?.call(_location!);
                  Navigator.pop(context);
                },
                child: Text(
                  '确定',
                  style: TextStyle(
                    color: _location == null ? myColors.textGrey : null,
                  ),
                ),
              ),
          ],
        ),
        body: ThemeBody(
          child: WebViewWidget(
            controller: _controller,
          ),
        ),
      ),
    );
  }
}
