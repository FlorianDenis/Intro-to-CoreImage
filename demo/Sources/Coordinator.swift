//
//  Coordinator.swift
//  IntroductionToCoreImage
//
//  Created by Florian on 07/01/2023.
//

import UIKit

class Coordinator {
    private lazy var navigationController: UINavigationController = {
//        let navigationController = UINavigationController(rootViewController: onboardingViewController)
        let navigationController = UINavigationController(rootViewController: aboutViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }()

    private lazy var aboutViewController: AboutViewController = {
        let aboutViewController = AboutViewController()
        aboutViewController.nextPressedHandler = { [weak self] in
            guard let self else { return }
            self.navigationController.pushViewController(
                self.onboardingViewController,
                animated: true
            )
        }
        return aboutViewController
    }()

    private lazy var onboardingViewController: OnboardingViewController = {
        let onboardingViewController = OnboardingViewController()
        return onboardingViewController
    }()

    var rootViewController: UIViewController {
        navigationController
    }

    public init() {}
}
