//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 26.03.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import SnapKit
import UIKit

@available(iOS 14.0, *)
var cloudAppSplitViewController: GlobalSplitViewController!

/// This variable prevents all network activities and caching. The app will use sample data and won't communicate with Hetzner. Intended for development
var cloudAppPreventNetworkActivityUseSampleData: Bool = true

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene

        window?.rootViewController = loadInitialViewController() // UINavigationController(rootViewController: ProjectListViewController())
        window?.makeKeyAndVisible()
    }

    func loadInitialViewController() -> UIViewController {
        if #available(iOS 14.0, *) {
            loadSplitViewController()
            return cloudAppSplitViewController
        } else {
            return ProjectListViewController()
        }
    }

    @available(iOS 14.0, *)
    func loadSplitViewController() {
        cloudAppSplitViewController = GlobalSplitViewController(style: .tripleColumn)
        cloudAppSplitViewController.preferredDisplayMode = .twoBesideSecondary //.twoBesideSecondary
        cloudAppSplitViewController.preferredSplitBehavior = .tile //.tile

        cloudAppSplitViewController.setViewController(ProjectListViewController(), for: .primary)
        let vc1 = UIViewController()
        vc1.view.backgroundColor = .systemBackground
        let vc2 = UIViewController()
        vc2.view.backgroundColor = .systemBackground
        cloudAppSplitViewController.setViewController(vc2, for: .secondary)
        cloudAppSplitViewController.setViewController(vc1, for: .supplementary)
    }

    func sceneDidDisconnect(_: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
