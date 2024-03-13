// aes加密
import 'package:encrypt/encrypt.dart';

// aes加密
String aesEncrypt(
  String data,
  String secret,
  String iv,
) {
  final key = Key.fromBase64(secret);
  final i = IV.fromBase64(iv);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final encrypted = encrypter.encrypt(data, iv: i);
  return encrypted.base64;
}

// aes解密
String aesDecrypt(
  String data,
  String secret,
  String iv,
) {
  final key = Key.fromBase64(secret);
  final v = IV.fromBase64(iv);
  final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
  final decrypted = encrypter.decrypt64(data, iv: v);
  return decrypted;
}

class Encrypt {
  final List<int> key;
  int step = 0;

  Encrypt(this.key);

  List<int> xor(List<int> data) {
    int l = key.length;
    if (l == 0) {
      return data;
    }
    List<int> res = List<int>.filled(data.length, 0, growable: false);
    for (int i = 0; i < data.length; i++) {
      res[i] = data[i] ^ key[step];
      step++;
      if (step == l) {
        step = 0;
      }
    }
    return res;
  }
}

List<int> xor(List<int> data, List<int> key) {
  Encrypt x = Encrypt(key);
  return x.xor(data);
}
