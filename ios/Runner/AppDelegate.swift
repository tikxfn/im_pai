import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        let methodChannel = FlutterMethodChannel(name: "LOCAL_SERVICE",
                                                  binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler({
          [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
          // 确认Flutter端调用的方法是startService
          guard call.method == "startService" else {
            result(FlutterMethodNotImplemented)
            return
          }
          // 尝试从Flutter端获取参数
          if let args = call.arguments as? [String: Any],
             let key = args["key"] as? String {
            self?.startService(key: key, result: result)
          } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing parameter", details: nil))
          }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    private func startService(key: String, result: @escaping FlutterResult) {
        let ret = clinkStart(key)
        result(ret)
    }
}

