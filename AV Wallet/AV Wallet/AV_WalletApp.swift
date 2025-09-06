//
//  AV_WalletApp.swift
//  AV Wallet
//
//  Created by J.Baptiste Jezequel on 09/05/2025.
//

import SwiftUI

@available(iOS 14.0, *)
@main
struct AV_WalletApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

// Fallback for iOS 13.0
@available(iOS 13.0, *)
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if #available(iOS 14.0, *) {
            // Use SwiftUI App
        } else {
            // Use UIKit for iOS 13.0
            window = UIWindow(frame: UIScreen.main.bounds)
            let contentView = ContentView()
            window?.rootViewController = UIHostingController(rootView: contentView)
            window?.makeKeyAndVisible()
        }
        return true
    }
}
