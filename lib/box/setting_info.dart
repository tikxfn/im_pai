part of 'box.dart';

class SettingInfoAdapter extends TypeAdapter<V1SettingInfoResp> {
  static const activeKey = 'setting_info';

  @override
  V1SettingInfoResp read(BinaryReader reader) {
    return V1SettingInfoResp.fromJson(jsonDecode(reader.read())) ??
        V1SettingInfoResp();
  }

  @override
  int get typeId => 2;

  @override
  void write(BinaryWriter writer, V1SettingInfoResp obj) {
    writer.write(jsonEncode(obj.toJson()));
  }
}
