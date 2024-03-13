import 'package:unionchat/im_core.dart';
import 'package:unionchat/pages/launch_screen.dart';

void main(List<String> args) {
  setApisJsonUrl(
    urls: [
      'https://paipaishare.oss-accelerate.aliyuncs.com/data_center.json',
      'https://pjim.s3.ap-east-1.amazonaws.com/data_center.json',
    ],
  );
  // 推送配置
  setTpnsConfig(
    domainName: '',
    iosAccessId: '1600038821',
    iosAccessKey: 'I07EZNNHNX5R',
    androidAccessId: '1500038819',
    androidAccessKey: 'A653FHSL13ES',
  );
  // setJGPnsConfig(
  //   appKey: 'bf9a9c52361555420341f3c4',
  // );
  // 设置阿里云oss加密密钥
  setStoreKey(storeKey: '2d62729f10c34aee8cf65e05b9891305');
  setEncrypt(
    isEncrypt: true,
    secret: 'WQTijhWoGZMimjTVSmUD5Ylld66PJNmYJiAAYRA1IyM=',
    iv: 'Mi/nl9tklis76Yx+FZfOEw==',
  );
  setRoomShowTotal(true);
  // setRegisterIcCode(true);
  setIm(false);
  //设置启动页
  start(args, launchScreen: const DefaultLaunchPage());
}
