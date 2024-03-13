package union.message.vip

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import cn.ay.clinkapi.Api

class MainActivity: FlutterActivity() {
    private var api: Api? = null // 定义 api 对象

    private val CHANNEL = "LOCAL_SERVICE"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "startService") {
                val key = call.argument<String>("key") // 获取传递的参数
                val nativeResult = startService(key) // 将参数传递给 startService
                result.success(nativeResult)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun startService(key: String?): Int {
        val key = key ?: "" // 如果 param 为空，使用默认值
        api = Api() // 创建 api 对象
        val ret = api!!.start(key) // 启动服务，传入参数 key
        return ret // 返回结果
    }
}
