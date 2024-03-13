import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class SettingProtocol extends StatelessWidget {
  const SettingProtocol({super.key});
  static const String path = 'setting/protocol';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户协议'.tr()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: const [
          Text.rich(
            TextSpan(
              text:
                  '服务条款\n\n软件服务及隐私条款\n\n欢迎您使用软件及服务，以下内容请仔细阅读。\n\n1、保护用户个人信息是一项基本原则，我们将会采取合理的措施保护用户的个人信息。除法律法规规定的情形外，未经用户许可我们不会向第三方公开、透漏个人信息。APP对相关信息采用专业加密存储与传输方式，保障用户个人信息安全，如果您选择同意使用APP软件， 即表示您认可并接受APP服务条款及其可能随时更新的内容。\n\n2、我们将会使用您的以下功能：麦克风、喇叭、WIFI网络、蜂窝通信网络、手机基站数据、、定位数据。如果您禁止APP使用以上相关服务和功能，您将自行承担不能获得或享用APP相应服务的后果。\n\n3、为了提供更好的客户服务，基于技术必要性收集一些有关设备级别事件（例如崩溃）的信息，但这些信息并不能够让我们识别您的 身份。为了能够让APP定位服务更精确，可能会收集并处理有关您实际所在位置信息（例如移动设备发送的GPS信号），WI-FI接入点和 基站位置信息。我们将对上述信息实施技术保护措施，以最大程度保护这些信息不被第三方非法获得，同时，您可以自行选择拒绝我们基于技术必要性 收集的这些信息，并自行承担不能获得或享用APP相应服务的后果。\n\n4、在您使用我们的产品或服务的过程中，我们可能：需要您提供个人信息，如姓名、电子邮件地址、电话号码、联系地址等以及注册或申请服务时需要 的其它类似个人信息；您对我们的产品和服务使用即表明您同意我们对这些信息的收集和合理使用。您可以自行选择拒绝、放弃使用相关产品或服务。\n\n5、由于您的自身行为或不可抗力等情形，导致上述可能涉及您隐私或您认为是私人信息的内容发生被泄露、批漏，或被第三方获取、使用、转让等情形的，均由您自行承担不利后果，我们对此不承担任何责任。\n\n6、我们拥有对上述条款的最终解释权。',
            ),
          ),
        ],
      ),
    );
  }
}
