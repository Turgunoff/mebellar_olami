import UIKit
import Flutter
import YandexMapsMobile //

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool { // [Bool] katta harf bilan yozildi
    
    // Yandex Map API Key shu yerga qo'shiladi
    YMKMapKit.setApiKey("6db07f4e-a68f-4845-9e3c-79ed8d6e9c1f")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}