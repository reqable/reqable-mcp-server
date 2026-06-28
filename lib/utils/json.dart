import 'dart:convert';
import 'dart:io';

extension JsonCodecExtension on JsonCodec {

  dynamic tryDecode(String text, {
    Object? Function(Object? key, Object? value)? reviver
  }) {
    final dynamic d;
    try {
      d = json.decode(text, reviver: reviver);
    } catch(e) {
      return null;
    }
    return d;
  }

  dynamic tryDecodeBytes(List<int> bytes, {
    Object? Function(Object? key, Object? value)? reviver,
    Encoding encoding = utf8
  }) {
    final String text;
    try {
      text = encoding.decode(bytes);
    } catch(e) {
      return null;
    }
    return tryDecode(text, reviver: reviver);
  }

  dynamic tryDecodeFile(String file, {
    Object? Function(Object? key, Object? value)? reviver,
    Encoding encoding = utf8
  }) {
    final File jsonFile = File(file);
    if (!jsonFile.existsSync()) {
      return null;
    }
    return tryDecodeBytes(jsonFile.readAsBytesSync(), reviver: reviver, encoding: encoding);
  }

}