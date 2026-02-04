import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, NotificationApi {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    NotificationApiSetup.setUp(binaryMessenger: controller.binaryMessenger, api: self)
    
    // Set delegate to handle notifications in foreground
    UNUserNotificationCenter.current().delegate = self
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func showLikeNotification(payload: NotificationPayload) throws {
    let content = UNMutableNotificationContent()
    content.title = payload.title
    content.body = "Post #\(payload.postId) liked!"
    content.sound = .default

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
    let request = UNNotificationRequest(identifier: "like_\(payload.postId)", content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request)
  }

  func requestNotificationPermission(completion: @escaping (Result<Bool, Error>) -> Void) {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      if let error = error {
        completion(.failure(error))
      } else {
        completion(.success(granted))
      }
    }
  }

  func checkNotificationPermission(completion: @escaping (Result<Bool, Error>) -> Void) {
    UNUserNotificationCenter.current().getNotificationSettings { settings in
      switch settings.authorizationStatus {
      case .authorized, .provisional, .ephemeral:
        completion(.success(true))
      default:
        completion(.success(false))
      }
    }
  }

  // Handle notifications while the app is in foreground
  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound, .badge])
  }
}

