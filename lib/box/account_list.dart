part of 'box.dart';

class AccountListItem {
  final String token;
  final String userId;

  AccountListItem(this.token, this.userId);
}

class AccountListItemAdapter extends TypeAdapter<AccountListItem> {
  @override
  AccountListItem read(BinaryReader reader) {
    return AccountListItem(reader.read(), reader.read());
  }

  @override
  int get typeId => 1;

  @override
  void write(BinaryWriter writer, AccountListItem obj) {
    writer.write(obj.token);
    writer.write(obj.userId);
  }
}
