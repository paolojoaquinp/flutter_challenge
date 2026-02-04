import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, NativeNotificationsApi {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    NativeNotificationsApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: self)
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func showNotification(payload: NotificationPayload) throws {
    let content = UNMutableNotificationContent()
    content.title = payload.title
    content.body = payload.body
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    let request = UNNotificationRequest(identifier: "\(payload.id)", content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request)
  }

  func requestPermissions(completion: @escaping (Result<Bool, Error>) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(granted))
      }
    }
  }
}
