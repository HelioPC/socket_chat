import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Storage {
  Future<void> store(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

final storageProvider = Provider<Storage>((ref) {
  return StorageImpl();
});

class StorageImpl implements Storage {
  @override
  Future<void> delete(String key) async {
    final sp = await SharedPreferences.getInstance();

    await sp.remove(key);
  }

  @override
  Future<String?> read(String key) async {
    final sp = await SharedPreferences.getInstance();

    return sp.getString(key);
  }

  @override
  Future<void> store(String key, String value) async {
    final sp = await SharedPreferences.getInstance();

    await sp.setString(key, value);
  }
}
