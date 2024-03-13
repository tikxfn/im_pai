import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'package:unionchat/box/box.dart';
import 'package:unionchat/db/db.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:unionchat/adapter/adapter.dart';
import 'package:unionchat/common/func.dart';
import 'package:unionchat/common/local_service.dart';
import 'package:unionchat/common/tpns.dart';
import 'package:unionchat/db/operator/channel_operator.dart';
import 'package:unionchat/db/notifier/channel_list_notifier.dart';
import 'package:unionchat/db/message_utils.dart';
import 'package:unionchat/message/sse_stream.dart';
import 'package:unionchat/pages/account/login.dart';
import 'package:unionchat/pages/setting/lock/lock_enter.dart';
import 'package:unionchat/pages/tabs.dart';
import 'package:unionchat/task/task.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:logger/logger.dart';
import 'package:openapi/api.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'package:window_manager/window_manager.dart';
import 'function_config.dart';
import 'common/aes.dart';
import 'common/interceptor.dart';

var uuid = const Uuid();

class FileOutput extends LogOutput {
  final File file;

  FileOutput(this.file);

  @override
  void output(OutputEvent event) {
    for (var line in event.lines) {
      file.writeAsStringSync('$line\n', mode: FileMode.writeOnlyAppend);
    }
  }
}

Logger? _logger;

Logger get logger {
  if (kReleaseMode) {
    // if (true) {
    _logger = Logger(
      printer: LogfmtPrinter(),
      output: FileOutput(File('${Global.appSupportDirectory}/runing.log')),
      level: Level.warning,
      filter: ProductionFilter(),
    );
  } else {
    _logger = Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        printTime: true,
        colors: true, // Colorful log messages
        printEmojis: true, // Print an emoji for each log message
      ),
    );
  }
  return _logger!;
}

class VersionInfo {
  String platform;
  String platformVersion;
  String appVersion;
  String appBuildNumber;
  String appName;

  VersionInfo(
    this.platform,
    this.platformVersion,
    this.appVersion,
    this.appBuildNumber,
    this.appName,
  );
}

class Global {
  static bool appIn = false;
  static String noticeReceiver = '';
  static String noticeRoomId = '';
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static String? get token => settingsBox.get('token');
  static String? _dno;
  static late String storeSecret;

  // 接口地址远程配置文件
  static List<String> apisJsonUrl = [];

  static bool im = true;
  static String fileServerUrl = '';

  // 接口加密配置
  static late bool isEncrypt;
  static late String secret;
  static late String iv;

  static late String _temporaryDirectory;
  static Tpns? _tpns;

  // static JGPush? _jgPush;

  static late String _appDocumentsDir;
  static late String _appSupportDirectory;

  // 平台信息
  static late String _platform;
  static late String _platformVersion;

  // APP版本信息
  static late String _appName;
  static late String _appVersion;
  static late String _appBuildNumber;

  static bool isRunningInPackage = false;

  // 服务器系统信息
  static late V1SettingInfoResp _systemInfo;

  // 接口地址
  static String apiUrl = '';

  //商户
  static late String merchantId;

  static GUserModel? get user {
    return userBox.get(UserAdapter.activeKey);
  }

  static LoginUser? get loginUser {
    if (user == null) return null;
    return LoginUser.fromModel(user!);
  }

  // 屏蔽关键字列表
  static List<String> banSpeakList = [];

  // 二维码url白名单
  static List<String> whiteUrls = [];

  // 是否检测二维码url白名单
  static bool enabledWhiteUrl = false;

  // 邀请码字段名称
  static String shareCodeName = 'feiou_code';

  // 是否注册进入
  static bool registerIn = false;

  static BuildContext? get context {
    return navigatorKey.currentState?.overlay?.context;
  }

  // 设备号
  static String get dno {
    return _dno ?? '';
  }

  static String get temporaryDirectory {
    return _temporaryDirectory;
  }

  static String get documentDirectory {
    return _appDocumentsDir;
  }

  static String get appSupportDirectory {
    return _appSupportDirectory;
  }

  static V1SettingInfoResp get systemInfo {
    return _systemInfo;
  }

  static VersionInfo get versionInfo {
    return VersionInfo(
      _platform,
      _platformVersion,
      _appVersion,
      _appBuildNumber,
      _appName,
    );
  }

  static Tpns? get tpns {
    return _tpns;
  }

  // 设置用户群公告读取数据
  static Future<void> setUserNoticeDataRead(
    String roomId,
    String content,
  ) async {
    if (user == null) return;
    final hash = md5.convert(utf8.encode(content)).toString();
    await settingsBox.put('notice_${user!.id}_$roomId', hash);
  }

  // 判断用户是否读取这个公告
  static bool isUserNoticeDataRead(
    String roomId,
    String content,
  ) {
    if (user == null) return false;
    final hash = md5.convert(utf8.encode(content)).toString();
    final oldHash = settingsBox.get('notice_${user!.id}_$roomId') ?? '';
    return oldHash == hash;
  }

  // 环境初始化
  static Future initENV() async {
    WidgetsFlutterBinding.ensureInitialized();
    final cache = PaintingBinding.instance.imageCache;
    cache.maximumSizeBytes = 100 << 20;
    //初始化窗口管理插件
    if (!platformPhone) await windowManager.ensureInitialized();
    if (Platform.isWindows) {
      DartVLC.initialize();
      //windows提前初始化视频播放器
      Player(id: randomNumber(1000000000));
    }
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    EasyLocalization.ensureInitialized();
    Intl.defaultLocale = 'zh-Hans-CN';
    await Hive.initFlutter();
    await initBox();
    merchantId = const String.fromEnvironment('MID', defaultValue: '1');
    final List<Future> futures = [
      () async {
        _dno = await _initDNO();
      }(),
      () async {
        _temporaryDirectory = (await getTemporaryDirectory()).path;
        if (Platform.isWindows) {
          _temporaryDirectory = _temporaryDirectory.replaceAll('\\', '/');
        }
      }(),
      () async {
        _appDocumentsDir = (await getApplicationDocumentsDirectory()).path;
        if (Platform.isWindows) {
          _appDocumentsDir = _appDocumentsDir.replaceAll('\\', '/');
        }
      }(),
      () async {
        _appSupportDirectory = (await getApplicationSupportDirectory()).path;
        if (Platform.isWindows) {
          _appSupportDirectory = _appSupportDirectory.replaceAll('\\', '/');
        }
      }(),
      _setPlatformVersion(),
      _setAppVersion(),
    ];
    await Future.wait(futures);
    final errFile = File('${Global.appSupportDirectory}/error.log');
    PlatformDispatcher.instance.onError = (error, stack) {
      if (kDebugMode) {
        print('Error: $error');
        print('StackTrace: $stack');
      }
      _errorToFile(error, stack, errFile);
      return true;
    };
  }

  static _errorToFile(Object error, StackTrace stack, File file) {
    file.writeAsStringSync(
      'Error: $error\n',
      mode: FileMode.writeOnlyAppend,
    );
    file.writeAsStringSync(
      'StackTrace: $stack\n',
      mode: FileMode.writeOnlyAppend,
    );
  }

  static Future _setAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _appVersion = packageInfo.version;
    _appBuildNumber = packageInfo.buildNumber;
    _appName = packageInfo.appName;
    //设置pc端推送app名称
    if (Platform.isWindows || Platform.isMacOS) {
      localNotifier.setup(appName: _appName);
    }
  }

  static Future _setPlatformVersion() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (kIsWeb) {
      WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;
      _platform = 'Web';
      _platformVersion = webBrowserInfo.userAgent ?? '';
      return;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        final androidInfo = await deviceInfo.androidInfo;
        _platform = 'Android';

        _platformVersion =
            '${androidInfo.model}:${androidInfo.version.release}';
        break;
      case TargetPlatform.iOS:
        final iosInfo = await deviceInfo.iosInfo;
        _platform = 'iOS';
        _platformVersion =
            '${iosInfo.utsname.machine}:${iosInfo.systemVersion}';
        break;
      case TargetPlatform.fuchsia:
        _platform = 'Fuchsia';
        _platformVersion = 'Fuchsia';
        break;
      case TargetPlatform.linux:
        final linuxInfo = await deviceInfo.linuxInfo;
        _platform = 'Linux';
        _platformVersion = linuxInfo.version ?? '';
        break;
      case TargetPlatform.macOS:
        final macOSInfo = await deviceInfo.macOsInfo;
        _platform = 'macOS';
        _platformVersion = '${macOSInfo.model}:${macOSInfo.osRelease}}';
        break;
      case TargetPlatform.windows:
        final windowsInfo = await deviceInfo.windowsInfo;
        _platform = 'Windows';
        _platformVersion = windowsInfo.displayVersion;
        break;
    }
  }

  static Future<bool>? _initDataInfoFuture;

  // 初始化日志
  static List<String> initLogs = [];

  // 添加日志
  static addInitLogs(String str) {
    initLogs.add('${time2date(date2time(null))}：$str');
  }

  static Future<bool> initDataInfo({String? loadText}) {
    _initDataInfoFuture ??= _initDataInfo(loadText: loadText);
    return _initDataInfoFuture!;
  }

  static Future<bool> _initDataInfo({String? loadText}) async {
    try {
      _tpns = Tpns();
      // _jgPush = JGPush();
      var mainApiUrl = apiUrl;
      apiUrl = '';
      initLogs.clear();
      bool hasApiUrl = await _getApiUrl(loadText: loadText);
      if (!hasApiUrl) apiUrl = mainApiUrl;
      if (apiUrl.isEmpty) {
        tipError('未找到可用的服务器');
        return false;
      }
      final List<Future> futures = [
        syncLoginUser(setTPns: true, init: true),
        getSystemInfo(),
        () async {}(),
      ];
      loading();
      await Future.wait(futures);
      return true;
    } catch (e) {
      Task.close();
      logger.e(e);
      return false;
    } finally {
      loadClose();
      Global.appIn = true;
      _initDataInfoFuture = null; // 一次执行完成后，重置_future，以便下一次可以正常执行
    }
  }

  // 获取远端api配置json
  static Future<void> _getApi(String v, Completer<String> completer) async {
    var logTitle = '未知数据中心';
    if (v.contains('aliyuncs')) {
      logTitle = '阿里数据中心';
    } else if (v.contains('amazonaws')) {
      logTitle = '亚马逊数据中心';
    }
    logTitle = '[$logTitle]';
    try {
      addInitLogs('$logTitle ==> 开始请求');
      const apiEnv = String.fromEnvironment('API_ENV', defaultValue: 'unknown');
      if (apiEnv.toLowerCase() != 'online') {
        // todo:测试环境json
        // v = v.replaceAll('.json', '_test.json');
      }
      // logger.d(v);
      var res = await http.get(Uri.parse(v));
      addInitLogs('$logTitle ==> 请求成功，code:${res.statusCode}；body:${res.body}');
      if (res.statusCode == 200 && !completer.isCompleted) {
        completer.complete(res.body);
      }
    } catch (err) {
      addInitLogs('$logTitle ==> 请求失败：$err');
      logger.d(err);
    }
  }

  //获取远端api配置json
  static Future<String> _getApis() async {
    List<Future> futures = [];
    Completer<String> completer = Completer();
    for (var v in Global.apisJsonUrl) {
      futures.add(_getApi(v, completer));
    }
    () async {
      await Future.wait(futures);
      if (!completer.isCompleted) {
        addInitLogs('获取远端api配置json超时');
        completer.complete('');
      }
    }();
    var urls = await completer.future;
    return urls;
  }

  static bool _changeApiUrlLoading = false;

  // hash变化
  static Future<void> changeApiUrl(String dhx) async {
    if (_changeApiUrlLoading || dhx.isEmpty) return;
    try {
      _changeApiUrlLoading = true;
      String localDhx = settingsBox.get('data_hash') ?? '';
      if (localDhx.isEmpty) {
        // logger.d('本地hash为空');
        await settingsBox.put('data_hash', dhx);
        // logger.d('本地hash缓存：${_preferences.getString('data_hash')}');
        return;
      }
      if (dhx != localDhx) {
        await settingsBox.put('data_hash', dhx);
        // logger.d('$dhx ------- $localDhx：重新获取服务器地址');
        await _getApiUrl(load: false);
        // logger.d('获取完成：$apiUrl');
      }
    } finally {
      _changeApiUrlLoading = false;
    }
  }

  // 启动游戏盾
  static Future<String> _startGameService() async {
    try {
      var serviceSuccess = await AppLocalService.start();
      if (!serviceSuccess) return '';
      // 游戏盾启动成功
      const apiEnv = String.fromEnvironment(
        'API_ENV',
        defaultValue: 'unknown',
      );
      var port = apiEnv.toLowerCase() != 'online' ? '27829' : '27828';
      // todo:测试环境
      port = '27828'; // 正式环境端口
      return 'http://127.0.0.1:$port';
    } catch (e) {
      logger.d(e);
      return '';
    }
  }

  // 获取json服务器地址
  static Future<List<String>> _getJsonUrls() async {
    if (apisJsonUrl.isEmpty) {
      addInitLogs('apisJsonUrl 为空');
      return [];
    }
    String encryptStr = await _getApis();
    if (encryptStr.isEmpty) {
      addInitLogs('获取服务器地址失败');
      return [];
    }
    var apisRes = aesDecrypt(encryptStr, Global.secret, Global.iv);
    // logger.d(apisRes);
    List<dynamic> apis = jsonDecode(apisRes);
    List<String> urls = [];
    for (var v in apis) {
      var mid = v['MerchantId'] ?? '';
      if (mid.toString() == merchantId) {
        urls.add(v['Url']);
      }
    }
    return urls;
  }

  // 测试服务器连接
  static Future<bool> _testServiceLink(List<String> urls) async {
    Completer<void> completer = Completer();
    final List<Future> futures = [];
    addInitLogs('开始请求系统接口测试服务器');
    for (var v in urls) {
      futures.add(_testApiUrl(v, completer));
    }
    () async {
      await Future.wait(futures);
      if (!completer.isCompleted) {
        addInitLogs('系统接口测试服务器接口超时');
        completer.complete();
      }
    }();
    await completer.future;
    if (apiUrl.isNotEmpty) {
      addInitLogs('服务器连接成功：$apiUrl');
    } else {
      addInitLogs('服务器连接失败：未找到可用服务器');
    }
    return apiUrl.isNotEmpty;
  }

  //获取api请求地址
  static Future<bool> _getApiUrl({bool load = true, String? loadText}) async {
    try {
      if (load) loading(text: loadText);
      var gameService = await _startGameService();
      var linkSuccess = false;
      if (gameService.isNotEmpty) {
        linkSuccess = await _testServiceLink([gameService]);
      }
      if (linkSuccess) return true;
      var urls = await _getJsonUrls();
      if (urls.isEmpty) return false;
      return await _testServiceLink(urls);
    } catch (e) {
      logger.e(e);
      return false;
    } finally {
      if (load) loadClose();
    }
  }

  //测试api地址是否可用
  static Future<void> _testApiUrl(String url, Completer<void> completer) async {
    addInitLogs('开始测试系统接口$url');
    try {
      final api = SettingApi(apiClient(url: url));
      await api.settingPing({});
      // logger.d(res);
      addInitLogs('系统接口连接成功');
      if (!completer.isCompleted) {
        apiUrl = url;
        completer.complete();
      }
    } on ApiException catch (e) {
      addInitLogs('系统接口连接失败：$e=>${e.code}=>${e.message}');
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  // 获取系统信息
  static getSystemInfo() async {
    final api = SettingApi(apiClient());
    try {
      var oldRes =
          settingInfo.get(SettingInfoAdapter.activeKey) ?? V1SettingInfoResp();
      var args = V1SettingInfoArgs(
        appVersion: oldRes.appVersion?.updated,
        discoveryPage: oldRes.discoveryPage?.updated,
        settingApp: oldRes.settingApp?.updated,
        settingDomainLimit: oldRes.settingDomainLimit?.updated,
        settingProhibitContent: oldRes.settingProhibitContent?.updated,
        settingUrl: oldRes.settingUrl?.updated,
        settingVip: oldRes.settingVip?.updated,
        settingVipLevel: oldRes.settingVipLevel?.updated,
        settingVipRights: oldRes.settingVipRights?.updated,
      );
      final res = await api.settingInfo(args);
      if (res?.appVersion?.appVersion != null) {
        oldRes.appVersion = res?.appVersion;
      }
      if (res?.discoveryPage?.discoveryPage != null) {
        oldRes.discoveryPage = res?.discoveryPage;
      }
      if (res?.settingApp?.settingApp != null) {
        oldRes.settingApp = res?.settingApp;
      }
      if (res?.settingDomainLimit?.settingDomainLimit != null) {
        oldRes.settingDomainLimit = res?.settingDomainLimit;
      }
      if (res?.settingProhibitContent?.settingProhibitContent != null) {
        oldRes.settingProhibitContent = res?.settingProhibitContent;
      }
      if (res?.settingUrl?.settingUrl != null) {
        oldRes.settingUrl = res?.settingUrl;
      }
      if (res?.settingVip?.settingVip != null) {
        oldRes.settingVip = res?.settingVip;
      }
      if (res?.settingVipLevel?.settingVipLevel != null) {
        oldRes.settingVipLevel = res?.settingVipLevel;
      }
      if (res?.settingVipRights?.vipRights != null) {
        oldRes.settingVipRights = res?.settingVipRights;
      }
      await settingInfo.put(SettingInfoAdapter.activeKey, oldRes);
      _systemInfo = oldRes;
      // 屏蔽关键词
      banSpeakList =
          oldRes.settingProhibitContent?.settingProhibitContent ?? [];
      // url白名单
      whiteUrls = oldRes.settingDomainLimit?.settingDomainLimit?.domain ?? [];
      // 是否开启url白名单
      enabledWhiteUrl =
          toBool(oldRes.settingDomainLimit?.settingDomainLimit?.isOpen);
      var settingApp = oldRes.settingApp?.settingApp;
      FunctionConfig.sendCall = toBool(settingApp?.audioVideo);
      FunctionConfig.sendLocation = toBool(settingApp?.location);
      FunctionConfig.sendFile = toBool(settingApp?.document);
      FunctionConfig.cleanTalkHistory = toBool(settingApp?.clearChat);
      FunctionConfig.sendRedPacket = toBool(settingApp?.redPacket);
      FunctionConfig.messageDestroy = toBool(settingApp?.messageSelfDestruct);
      FunctionConfig.circle = toBool(settingApp?.circle);
      FunctionConfig.goodNumber = toBool(settingApp?.userNumber);
      FunctionConfig.guestLogin = toBool(settingApp?.touristLogin);
      FunctionConfig.integral = toBool(settingApp?.integral);
      FunctionConfig.commonFriend = toBool(settingApp?.commonFriend);
      FunctionConfig.vip = toBool(settingApp?.vip);
      FunctionConfig.mall = toBool(settingApp?.mall);
      FunctionConfig.superAlbum = toBool(settingApp?.superAlbum);
      FunctionConfig.phoneAccount = toBool(settingApp?.allowPhoneRegister);
      FunctionConfig.forgetFriendHelp = toBool(settingApp?.assistLogin);
      FunctionConfig.share = toBool(settingApp?.shareCasualChat);
    } on ApiException catch (e) {
      onError(e);
    } catch (e) {
      logger.e(e);
    }
  }

  // 获取用户信息
  static syncLoginUser({bool setTPns = false, bool init = false}) async {
    final api = PassportApi(apiClient());
    try {
      final res = await api.passportLoginUser({});
      if (res != null) {
        await setUser(res, setTPns: setTPns);
        if (init) await _initUserEnter();
      }
    } on ApiException catch (e) {
      logger.e(e);
    } catch (e) {
      logger.e(e);
    }
  }

  static String getInitialRoute() {
    final r = () {
      if (user == null || token == null) {
        return Login.path;
      } else if (loginUser!.enablePin && loginUser!.isPin) {
        return LockEnter.path;
      } else {
        return Tabs.path;
      }
    }();
    // logger.i('init_router: $r');
    return r;
  }

  static setToken(String token) async {
    await settingsBox.put('token', token);
    await _initUserEnter();
  }

  // 当新用户被设置的时候
  static _initUserEnter() async {
    SSEStream().listen();
    MessageUtil.syncGroup();
    await Task.init();
  }

  static setUser(GUserModel user, {bool setTPns = false}) async {
    if (user.platform == GAuthPlatform.REGISTER_BY_TOURIST) {
      user.account = '-';
    }
    await userBox.put(UserAdapter.activeKey, user);
    if (setTPns) {
      _tpns?.setAccount(user.id!);
    }
  }

  // 是否添加账号
  static bool isAddAccount = false;

  // 前往添加账号
  static goAddAccount() {
    isAddAccount = true;
    Adapter.navigatorTo(Login.path, removeUntil: true);
  }

  // 关闭添加账号
  static closeAddAccount() {
    isAddAccount = false;
    Navigator.pushNamedAndRemoveUntil(
      Global.context!,
      Tabs.path,
      (route) => false,
    );
  }

  // 删除缓存账号
  static Future removeAccount(String userId) async {
    List<AccountListItem> list = [];
    for (var v in getAccount()) {
      if (v.userId == userId) continue;
      list.add(v);
    }
    await settingsBox.put('accountList', jsonEncode(list));
  }

  // 清空缓存账号
  static Future cleanAccount() async {
    await settingsBox.delete('accountList');
  }

  // 获取缓存账号
  static List<AccountListItem> getAccount() {
    try {
      logger.d('------------------ ${accountBox.values}');
      return accountBox.values.toList();
    } catch (e) {
      logger.d(e);
      return [];
    }
  }

  // 设置账号缓存
  static Future addAccount(String token, String userId) async {
    var list = getAccount();
    for (var v in list) {
      if (v.userId == userId) return;
    }
    await accountBox.add(AccountListItem(token, userId));
  }

  // 登录
  static login(
    String token,
    GUserModel userInfo, {
    bool register = false,
  }) async {
    await addAccount(token, userInfo.id ?? '');
    if (isAddAccount && token.isNotEmpty) {
      await loginOut(nav: false);
    }
    await setUser(userInfo, setTPns: true);
    await setToken(token);
    ChannelListNotifier().searchByCondition(ChannelCondition());
    registerIn = register;
    if (toBool(userInfo.enablePin) && toBool(userInfo.isPin)) {
      Navigator.pushNamedAndRemoveUntil(
        context!,
        LockEnter.path,
        (route) => false,
      );
      return;
    }
    Navigator.pushNamedAndRemoveUntil(
      context!,
      Tabs.path,
      (route) => false,
    );
  }

  // 退出登录
  static loginOut({bool nav = true}) async {
    logger.d('loginOut');
    if (nav) await cleanAccount();
    isAddAccount = false;
    await settingsBox.delete('token');
    await userBox.delete(UserAdapter.activeKey);
    SSEStream().close();
    await Task.close();
    _tpns?.cleanAccounts();
    await DB.close();
    if (nav) Adapter.navigatorTo(Login.path, removeUntil: true);
  }

  // 清除本地缓存
  static Future cleanCache() async {
    await Task.close();
    await SSEStream().close();
    await DB.clearDatabase();
    await Task.init();
    SSEStream().listen();
    ChannelListNotifier().searchByCondition(ChannelCondition());
  }

  // 初始化一个设备id
  static Future<String> _initDNO() async {
    String? dno = settingsBox.get('dno');
    if (dno != null && dno.length == 32) return dno;
    const uuid = Uuid();
    var bytes = utf8.encode(uuid.v4()); // 将输入字符串转换为字节
    var digest = md5.convert(bytes); // 计算 MD5
    dno = digest.toString();
    await settingsBox.put('dno', dno);
    return dno;
  }
}
