import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  private let channelName = "app.contact_launcher"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
      channel.setMethodCallHandler { call, result in
        switch call.method {
        case "launchPhone":
          guard let args = call.arguments as? [String: Any],
                let phone = args["phone"] as? String,
                let url = URL(string: "tel:\(phone)"),
                UIApplication.shared.canOpenURL(url) else {
            result(false)
            return
          }
          UIApplication.shared.open(url, options: [:]) { success in
            result(success)
          }
        case "launchWhatsApp":
          guard let args = call.arguments as? [String: Any],
                let phone = args["phone"] as? String else {
            result(false)
            return
          }
          let message = (args["message"] as? String) ?? ""
          let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
          guard let url = URL(string: "https://wa.me/\(phone)?text=\(encodedMessage)"),
                UIApplication.shared.canOpenURL(url) else {
            result(false)
            return
          }
          UIApplication.shared.open(url, options: [:]) { success in
            result(success)
          }
        default:
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
