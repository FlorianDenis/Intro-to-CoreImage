//
//  AppDelegate.swift
//  IntroductionToCoreImage
//
//  Created by Florian Denis on 04/01/2023.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = AboutViewController()
        window?.makeKeyAndVisible()

        return true
    }
}
