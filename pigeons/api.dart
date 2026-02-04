import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/core/platform/notification_api.g.dart',
    dartOptions: DartOptions(),
    dartPackageName: 'flutter_challenge',
    kotlinOut: 'android/app/src/main/kotlin/com/example/flutter_challenge/NotificationApi.g.kt',
    kotlinOptions: KotlinOptions(package: 'com.example.flutter_challenge'),
    swiftOut: 'ios/Runner/NotificationApi.g.swift',
    swiftOptions: SwiftOptions(),
  ),
)
class NotificationPayload {
  const NotificationPayload({required this.postId, required this.title});

  final int postId;
  final String title;
}

@HostApi()
abstract class NotificationApi {
  void showLikeNotification(NotificationPayload payload);

  @async
  bool requestNotificationPermission();

  @async
  bool checkNotificationPermission();
}

