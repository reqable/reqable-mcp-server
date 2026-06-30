import 'dart:io';
import 'package:path/path.dart' as path;

class Storage {

  static String? get rootPath {
    if (Platform.isWindows) {
      final String? appData = Platform.environment['APPDATA'];
      if (appData != null && appData.isNotEmpty) {
        return '$appData\\Reqable';
      }
      final String? home = Platform.environment['HOME'];
      if (home != null && home.isNotEmpty) {
        return '$home\\AppData\\Roaming\\Reqable';
      }
      return null;
    } else if (Platform.isMacOS) {
      final String? home = Platform.environment['HOME'];
      if (home == null || home.isEmpty) {
        return null;
      }
      return '$home/Library/Application Support/com.reqable.macosx';
    } else if (Platform.isLinux) {
      final String? home = Platform.environment['HOME'];
      if (home == null || home.isEmpty) {
        return null;
      }
      return '$home/.local/share/com.reqable.linux';
    }
    return null;
  }

  static String? getFilePath(List<String> paths) {
    final String? root = rootPath;
    if (root == null) {
      return null;
    }
    return path.joinAll([root, ...paths]);
  }

}