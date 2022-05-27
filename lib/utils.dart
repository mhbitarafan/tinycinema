import 'package:logging/logging.dart';

bool isNight() => DateTime.now().hour > 18 || DateTime.now().hour < 5;

String durationPrettify(Duration duration) {
  return duration.toString().split('.').first.padLeft(8, "0");
}

final log = Logger('general logger');
