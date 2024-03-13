import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/pages/account/login.dart';
import 'package:unionchat/pages/tabs.dart';
import 'package:unionchat/routes.dart';
import 'package:unionchat/widgets/theme_image.dart';
import 'package:provider/provider.dart';

// 适配器
class Adapter extends StatelessWidget {
  static bool isWideScreen = false;
  static GlobalKey<NavigatorState>? rightKey;
  static final RouteSettingsNotifier _routeSettingsNotifier =
      RouteSettingsNotifier();
  final Widget home;

  const Adapter({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    //配置pc实现鼠标点击拖动
    Set<PointerDeviceKind> kTouchLikeDeviceTypes = <PointerDeviceKind>{
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      PointerDeviceKind.stylus,
      PointerDeviceKind.invertedStylus,
      PointerDeviceKind.unknown
    };
    return LayoutBuilder(builder: (context, constraints) {
      // context.setLocale(const Locale('zh'));
      Adapter.isWideScreen = constraints.maxWidth >= 700;
      return ChangeNotifierProvider(
        create: (_) => _routeSettingsNotifier,
        child: MaterialApp(
          scrollBehavior: const MaterialScrollBehavior()
              .copyWith(scrollbars: true, dragDevices: kTouchLikeDeviceTypes),
          navigatorKey: Global.navigatorKey,
          home: home,
          theme: context.watch<ThemeNotifier>().getTheme(),
          onGenerateRoute: (RouteSettings settings) {
            return CustomCupertinoPageRoute(
              builder: (context) {
                Widget child = Routes.get(settings)(context);
                if (isWideScreen && settings.name == Tabs.path) {
                  return Consumer<RouteSettingsNotifier>(
                    builder: (BuildContext context, value, _) {
                      return DoubleNavigator(
                        isTab: settings.name == Tabs.path,
                        left: child,
                        settings: value.settings,
                      );
                    },
                  );
                }
                return ThemeImage(child: child);
              },
              settings: settings,
            );
          },
          builder: (context, child) {
            final easyLoading = EasyLoading.init();
            final locale = Localizations.localeOf(context);
            Intl.defaultLocale = locale.toLanguageTag();
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: easyLoading(context, child),
            );
          },
          localizationsDelegates: [
            ...context.localizationDelegates,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: context.supportedLocales,
          locale: context.locale,
        ),
      );
    });
  }

  //清空右侧路由
  static cleanRoutes() {
    if (!isWideScreen || rightKey == null || rightKey!.currentState == null) {
      return;
    }
    var state = rightKey!.currentState!;
    state.popUntil((route) => false);
    _routeSettingsNotifier.set(null);
  }

  // 跳转
  static Future<T?> navigatorTo<T>(
    String path, {
    Object? arguments,
    bool removeUntil = false,
  }) async {
    BuildContext? mainContext = Global.context;
    if (isWideScreen && path != Login.path) {
      _routeSettingsNotifier.set(
        RouteSettings(name: path, arguments: arguments),
      );
      return null;
    }
    if (mainContext == null) return null;
    _routeSettingsNotifier.set(null);
    if (removeUntil) {
      return await Navigator.of(mainContext).pushNamedAndRemoveUntil(
        path,
        (route) => false,
        arguments: arguments,
      );
    } else {
      return await Navigator.of(mainContext).pushNamed(
        path,
        arguments: arguments,
      );
    }
  }
}

// 双路由
class DoubleNavigator extends StatelessWidget {
  final Widget left;
  final RouteSettings? settings;
  final bool isTab;

  const DoubleNavigator({
    super.key,
    required this.left,
    required this.isTab,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    Adapter.rightKey = GlobalKey<NavigatorState>();
    var myColors = context.watch<ThemeNotifier>();
    return Row(
      children: [
        Container(
          constraints: const BoxConstraints(
            minWidth: 200,
            maxWidth: 350,
          ),
          decoration: BoxDecoration(
            border: Border(
              right: BorderSide(
                color: myColors.lineGrey,
                width: .5,
              ),
            ),
          ),
          child: left,
        ),
        Expanded(
          flex: 1,
          child: HeroControllerScope(
            controller: HeroController(),
            child: Navigator(
              key: Adapter.rightKey,
              onGenerateRoute: (RouteSettings settings) {
                return CustomCupertinoPageRoute(
                  builder: Routes.get(settings),
                  settings: settings,
                );
              },
              pages: [
                (settings == null)
                    ? const MaterialPage(
                        child: NoRouter(),
                      )
                    : MaterialPage(
                        arguments: settings!.arguments,
                        child: Routes.get(
                          RouteSettings(
                            name: settings!.name,
                            arguments: settings,
                          ),
                        )(context),
                      ),
              ],
              onPopPage: (route, result) => route.didPop(result),
            ),
          ),
        ),
      ],
    );
  }
}

class RouteSettingsNotifier extends ChangeNotifier {
  RouteSettings? _settings;

  RouteSettings? get settings => _settings;

  void set(RouteSettings? settings) {
    _settings = settings;
    notifyListeners();
  }
}

class NoRouter extends StatelessWidget {
  const NoRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('未选择任何页面'),
      ),
    );
  }
}

class CustomCupertinoPageRoute extends CupertinoPageRoute {
  CustomCupertinoPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
  }) : super(builder: builder, settings: settings);

  @override
  Duration get transitionDuration =>
      const Duration(milliseconds: 600); // 自定义过渡时间为500毫秒
}
