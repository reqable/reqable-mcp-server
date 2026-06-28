import 'dart:io';

import 'package:path/path.dart';
import 'package:pubspec_parse/pubspec_parse.dart';

const String _kGenCode = '''
// AUTO GENERATED FILE, DO NOT EDIT.

const String kVersionName = '\$versionName';
''';

void main(List<String> args) {
  final Pubspec pubspec = Pubspec.parse(File(join('pubspec.yaml')).readAsStringSync());
  final File versionFile = File(join('lib', 'version.g.dart'));
  if (!versionFile.parent.existsSync()) {
    versionFile.parent.createSync(recursive: true);
  }
  final List<String> version = pubspec.version.toString().split('+');
  final String code = _kGenCode
    .replaceFirst('\$versionName', version.first);
  versionFile.writeAsStringSync(code);
}