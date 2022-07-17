import 'package:yaml/yaml.dart';

Future<T?> parseYaml<T>(Future<String> text) async {
  var parsed;
  try {
    parsed = loadYaml(await text);
  } on YamlException catch (e) {
    print('YAML parse error: $e');
    return null;
  }
  if (parsed is! T) {
    print('Incorrect YAML type? (${parsed.runtimeType})');
    return null;
  }
  return parsed;
}
