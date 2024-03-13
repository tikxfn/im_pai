import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:unionchat/global.dart';
import 'package:unionchat/common/interceptor.dart';
import 'package:unionchat/notifier/theme_notifier.dart';
import 'package:unionchat/widgets/theme_body.dart';
import 'package:openapi/api.dart';
import 'package:provider/provider.dart';

import '../../common/func.dart';

class LoginDevicePage extends StatefulWidget {
  const LoginDevicePage({super.key});

  static const path = 'LoginDevicePage/home';

  @override
  State<LoginDevicePage> createState() => _LoginDevicePageState();
}

class _LoginDevicePageState extends State<LoginDevicePage> {
  List<GUserDeviceModel> list = [];

  //获取设备列表
  _getList() async {
    try {
      var res = await UserApi(apiClient()).userDeviceList({});
      if (res == null || !mounted) return;
      setState(() {
        list = res.list;
      });
    } on ApiException catch (e) {
      onError(e);
    }
  }

  //设备下线
  _deviceOff(String deviceNo) {
    confirm(
      context,
      title: '确定要下线该设备？'.tr(),
      onEnter: () async {
        loading();
        try {
          await PassportApi(apiClient()).passportDnoOffline(
            V1DnoOfflineArgs(deviceDno: deviceNo),
          );
          await _getList();
        } on ApiException catch (e) {
          onError(e);
        } finally {
          loadClose();
        }
      },
    );
  }

  //设备操作
  deviceEdit(GUserDeviceModel v) {
    openSheetMenu(
      context,
      list: ['下线'.tr()],
      onTap: (i) {
        if (i == 0) _deviceOff(v.dno!);
      },
    );
  }

  /// 获取iPhone设备型号
  String getIphoneModel(String target) {
    // 其他
    if (target.contains('i386') || target.contains('x86_64')) {
      return 'Simulator';
    }

    if (!target.toLowerCase().contains('iphone') ||
        !target.toLowerCase().contains('ipod') ||
        !target.toLowerCase().contains('ipad')) {
      return target;
    }
    if (target.contains('iPhone1,1')) return 'iPhone 2G';
    if (target.contains('iPhone1,2')) return 'iPhone 3G';
    if (target.contains('iPhone2,1')) return 'iPhone 3GS';
    if (target.contains('iPhone3,1') ||
        target.contains('iPhone3,2') ||
        target.contains('iPhone3,3')) {
      return 'iPhone 4';
    }
    if (target.contains('iPhone4,1')) return 'iPhone 4S';
    if (target.contains('iPhone5,1') || target.contains('iPhone5,2')) {
      return 'iPhone 5';
    }
    if (target.contains('iPhone5,3') || target.contains('iPhone5,4')) {
      return 'iPhone 5c';
    }
    if (target.contains('iPhone6,1') || target.contains('iPhone6,2')) {
      return 'iPhone 5s';
    }
    if (target.contains('iPhone7,1')) return 'iPhone 6 Plus';
    if (target.contains('iPhone7,2')) return 'iPhone 6';
    if (target.contains('iPhone8,1')) return 'iPhone 6s';
    if (target.contains('iPhone8,2')) return 'iPhone 6s Plus';
    if (target.contains('iPhone8,4')) return 'iPhone SE 1';
    if (target.contains('iPhone9,1') || target.contains('iPhone9,3')) {
      return 'iPhone 7';
    }
    if (target.contains('iPhone9,2') || target.contains('iPhone9,4')) {
      return 'iPhone 7 Plus';
    }
    if (target.contains('iPhone10,1') || target.contains('iPhone10,4')) {
      return 'iPhone 8';
    }
    if (target.contains('iPhone10,2') || target.contains('iPhone10,5')) {
      return 'iPhone 8 Plus';
    }
    if (target.contains('iPhone10,3') || target.contains('iPhone10,6')) {
      return 'iPhone X';
    }
    if (target.contains('iPhone11,2')) return 'iPhone XS';
    if (target.contains('iPhone11,4') || target.contains('iPhone11,6')) {
      return 'iPhone XS MAX';
    }
    if (target.contains('iPhone11,8')) return 'iPhone XR';
    if (target.contains('iPhone12,1')) return 'iPhone 11';
    if (target.contains('iPhone12,3')) return 'iPhone 11 Pro';
    if (target.contains('iPhone12,5')) return 'iPhone 11 Pro Max';
    if (target.contains('iPhone12,8')) return 'iPhone SE 2';
    if (target.contains('iPhone13,1')) return 'iPhone 12 mini';
    if (target.contains('iPhone13,2')) return 'iPhone 12';
    if (target.contains('iPhone13,3')) return 'iPhone 12 Pro';
    if (target.contains('iPhone13,4')) return 'iPhone 12 Pro Max';
    if (target.contains('iPhone14,4')) return 'iPhone 13 mini';
    if (target.contains('iPhone14,5')) return 'iPhone 13';
    if (target.contains('iPhone14,2')) return 'iPhone 13 Pro';
    if (target.contains('iPhone14,3')) return 'iPhone 13 Pro Max';
    if (target.contains('iPhone14,6')) return 'iPhone SE 3';
    if (target.contains('iPhone14,7')) return 'iPhone 14';
    if (target.contains('iPhone14,8')) return 'iPhone 14 Plus';
    if (target.contains('iPhone15,2')) return 'iPhone 14 Pro';
    if (target.contains('iPhone15,3')) return 'iPhone 14 Pro Max';

    // iPod
    if (target.contains('iPod1,1')) return 'iPod Touch 1';
    if (target.contains('iPod2,1')) return 'iPod Touch 2';
    if (target.contains('iPod3,1')) return 'iPod Touch 3';
    if (target.contains('iPod4,1')) return 'iPod Touch 4';
    if (target.contains('iPod5,1')) return 'iPod Touch 5';
    if (target.contains('iPod7,1')) return 'iPod Touch 6';
    if (target.contains('iPod9,1')) return 'iPod Touch 7';

    // iPad
    if (target.contains('iPad1,1')) return 'iPad 1';
    if (target.contains('iPad2,1') ||
        target.contains('iPad2,2') ||
        target.contains('iPad2,3') ||
        target.contains('iPad2,4')) return 'iPad 2';
    if (target.contains('iPad2,5') ||
        target.contains('iPad2,6') ||
        target.contains('iPad2,7')) {
      return 'iPad Mini 1';
    }
    if (target.contains('iPad3,1') ||
        target.contains('iPad3,2') ||
        target.contains('iPad3,3')) {
      return 'iPad 3';
    }
    if (target.contains('iPad3,4') ||
        target.contains('iPad3,5') ||
        target.contains('iPad3,6')) {
      return 'iPad 4';
    }
    if (target.contains('iPad4,1') ||
        target.contains('iPad4,2') ||
        target.contains('iPad4,3')) {
      return 'iPad Air';
    }
    if (target.contains('iPad4,4') ||
        target.contains('iPad4,5') ||
        target.contains('iPad4,6')) {
      return 'iPad mini 2';
    }
    if (target.contains('iPad4,7') ||
        target.contains('iPad4,8') ||
        target.contains('iPad4,9')) {
      return 'iPad mini 3';
    }
    if (target.contains('iPad5,1') || target.contains('iPad5,2')) {
      return 'iPad mini 4';
    }
    if (target.contains('iPad5,3') || target.contains('iPad5,4')) {
      return 'iPad Air 2';
    }
    if (target.contains('iPad6,3') || target.contains('iPad6,4')) {
      return 'iPad Pro (9.7-inch)';
    }
    if (target.contains('iPad6,7') || target.contains('iPad6,8')) {
      return 'iPad Pro (12.9-inch)';
    }
    if (target.contains('iPad6,11') || target.contains('iPad6,12')) {
      return 'iPad 5';
    }
    if (target.contains('iPad7,1') || target.contains('iPad7,2')) {
      return 'iPad Pro 2(12.9-inch)';
    }
    if (target.contains('iPad7,3') || target.contains('iPad7,4')) {
      return 'iPad Pro (10.5-inch)';
    }
    if (target.contains('iPad7,5') || target.contains('iPad7,6')) {
      return 'iPad 6';
    }
    if (target.contains('iPad7,11') || target.contains('iPad7,12')) {
      return 'iPad 7';
    }
    if (target.contains('iPad8,1') ||
        target.contains('iPad8,2') ||
        target.contains('iPad8,3') ||
        target.contains('iPad8,4')) return 'iPad Pro (11-inch)';
    if (target.contains('iPad8,5') ||
        target.contains('iPad8,6') ||
        target.contains('iPad8,7') ||
        target.contains('iPad8,8')) return 'iPad Pro 3 (12.9-inch)';
    if (target.contains('iPad8,9') || target.contains('iPad8,10')) {
      return 'iPad Pro 2 (11-inch)';
    }
    if (target.contains('iPad8,11') || target.contains('iPad8,12')) {
      return 'iPad Pro 4 (12.9-inch)';
    }
    if (target.contains('iPad11,1') || target.contains('iPad11,2')) {
      return 'iPad mini 5';
    }
    if (target.contains('iPad11,3') || target.contains('iPad11,4')) {
      return 'iPad Air 3';
    }
    if (target.contains('iPad11,6') || target.contains('iPad11,7')) {
      return 'iPad 8';
    }
    if (target.contains('iPad12,1') || target.contains('iPad12,2')) {
      return 'iPad 9';
    }
    if (target.contains('iPad13,1') || target.contains('iPad13,2')) {
      return 'iPad Air 4';
    }
    if (target.contains('iPad13,4') ||
        target.contains('iPad13,5') ||
        target.contains('iPad13,6') ||
        target.contains('iPad13,7')) return 'iPad Pro 4 (11-inch)';
    if (target.contains('iPad13,8') ||
        target.contains('iPad13,9') ||
        target.contains('iPad13,10') ||
        target.contains('iPad13,11')) return 'iPad Pro 5 (12.9-inch)';
    if (target.contains('iPad14,1') || target.contains('iPad14,2')) {
      return 'iPad mini 6';
    }

    return '未知型号';
  }

  @override
  void initState() {
    super.initState();
    _getList();
  }

  @override
  Widget build(BuildContext context) {
    var myColors = context.watch<ThemeNotifier>();
    return Scaffold(
      appBar: AppBar(
        title: Text('登录设备'.tr()),
      ),
      body: ThemeBody(
        child: ListView(
          children: list.map((e) {
            logger.d(e);
            var deviceName = getIphoneModel(e.platformVersion ?? '');
            var title = '${e.platform ?? ''} ${deviceName.split(',').first}';
            return GestureDetector(
              onTap: () {
                deviceEdit(e);
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: myColors.lineGrey, width: .5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title.trim().isNotEmpty ? title : '未知设备',
                            style: TextStyle(
                              color: myColors.primary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          // Text(
                          //   '登录IP：${e.ip}',
                          //   style: const TextStyle(
                          //     fontSize: 12,
                          //     color: myColors.textGrey,
                          //   ),
                          // ),
                          // Text(
                          //   '登录地区：${e.cityName}',
                          //   style: const TextStyle(
                          //     fontSize: 12,
                          //     color: myColors.textGrey,
                          //   ),
                          // ),
                          Text(
                            '最后在线：${time2date(e.updateTime, format: 'yyyy-MM-dd HH:mm:ss')}',
                            style: TextStyle(
                              fontSize: 12,
                              color: myColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: myColors.lineGrey,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
