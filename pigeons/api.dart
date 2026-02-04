import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/core/utils/native_api.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/app/src/main/kotlin/com/example/flutter_challenge/NativeApi.g.kt',
  kotlinOptions: KotlinOptions(package: 'com.example.flutter_challenge'),
  swiftOut: 'ios/Runner/NativeApi.g.swift',
  swiftOptions: SwiftOptions(),
  dartPackageName: 'flutter_challenge',
))

class NotificationPayload {
  final int id;
  final String title;
  final String body;

  NotificationPayload({
    required this.id,
    required this.title,
    required this.body,
  });
}

@HostApi()
abstract class NativeNotificationsApi {
  void showNotification(NotificationPayload payload);
  @async
  bool requestPermissions();
}
