# flutter_im

## 配置

1. 腾讯云消息推送配置：

   - lib/common/tpns.dart
   - android/app/build.gradle
   - lib/android/app/src/main/AndroidManifest.xml

1. openinstall 配置：
   - android/app/build.gradle
   - lib/android/app/src/main/AndroidManifest.xml
   - lib/ios/Runner/Info.plist
1. 地图 sdk 配置
   - 高德开放平台获取 key，并配置到管理后台
   - 获取 android SHA1，并配置到高德开放平台对应 android key

## 打包

运行（打包）参数：

- BUILDNAME: 版本号 1.0.0
- BUILDNUMBER: 数字版本号 1
- MID: 商户 ID

```bash
# apk编译
flutter build apk --release --build-name=$(BUILDNAME) \
    --build-number=$(BUILDNUMBER) \
    --dart-define=MID=$(MID)

# ios编译
flutter build ipa --release --build-name=$(BUILDNAME) \
    --build-number=$(BUILDNUMBER) \
    --dart-define=MID=$(MID)
```
