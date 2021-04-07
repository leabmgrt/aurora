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
import SwiftKeychainWrapper
import LocalAuthentication

@available(iOS 14.0, *)
var cloudAppSplitViewController: GlobalSplitViewController!

/// This variable prevents all network activities and caching. The app will use sample data and won't communicate with Hetzner. Intended for development
var cloudAppPreventNetworkActivityUseSampleData: Bool = false

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        
        firstLaunchRoutine()

        window?.rootViewController = loadInitialViewController() // UINavigationController(rootViewController: ProjectListViewController())
        window?.makeKeyAndVisible()
        verifyBiometricAuthentication()
    }

    func loadInitialViewController() -> UIViewController {
        if #available(iOS 14.0, *) {
            loadSplitViewController()
            return cloudAppSplitViewController
        } else {
            return ProjectListViewController()
        }
    }
    
    func firstLaunchRoutine() {
        if !UserDefaults.standard.bool(forKey: "launchedBefore") {
            KeychainWrapper.standard.removeAllKeys()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }

    @available(iOS 14.0, *)
    func loadSplitViewController() {
        cloudAppSplitViewController = GlobalSplitViewController(style: .tripleColumn)
        cloudAppSplitViewController.preferredDisplayMode = .twoBesideSecondary // .twoBesideSecondary
        cloudAppSplitViewController.preferredSplitBehavior = .tile // .tile

        cloudAppSplitViewController.setViewController(ProjectListViewController(), for: .primary)
        let vc1 = UIViewController()
        vc1.view.backgroundColor = .systemBackground
        let vc2 = UIViewController()
        vc2.view.backgroundColor = .systemBackground
        cloudAppSplitViewController.setViewController(vc2, for: .secondary)
        cloudAppSplitViewController.setViewController(vc1, for: .supplementary)
    }
    
    func verifyBiometricAuthentication() {
        if KeychainWrapper.standard.bool(forKey: "biometricAuthEnabled") ?? false {
            let rootView = (window?.rootViewController)!
            let blurStyle: UIBlurEffect.Style = rootView.traitCollection.userInterfaceStyle == .dark ? .dark : .light
            let blurEffect = UIBlurEffect(style: blurStyle)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            
            blurEffectView.frame = rootView.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            blurEffectView.alpha = 1.0
            blurEffectView.tag = 934
            if rootView.view.viewWithTag(934) != nil { return }
            
            rootView.view.addSubview(blurEffectView)
            blurEffectView.snp.makeConstraints { (make) in
                make.top.equalTo(rootView.view.snp.top)
                make.leading.equalTo(rootView.view.snp.leading)
                make.bottom.equalTo(rootView.view.snp.bottom)
                make.trailing.equalTo(rootView.view.snp.trailing)
            }
            
            let authContext = LAContext()
            var authError: NSError?
            
            if authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                authContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Unlock the app") { (success, error) in
                    if success {
                        DispatchQueue.main.async {
                            UIView.animate(withDuration: 0.2, animations: {
                                blurEffectView.alpha = 0.0
                            }) { _ in
                                if let blurTag = rootView.view.viewWithTag(934) { blurTag.removeFromSuperview() }
                            }
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            EZAlertController.alert("Biometric authentication failed", message: "Please try again", actions: [.init(title: "Retry", style: .default, handler: { (_) in
                                self.verifyBiometricAuthentication()
                            })])
                        }
                    }
                }
            }
            else {
                EZAlertController.alert("Device error", message: "Biometric authentication is not enabled on your device. Please verify that it's enabled in the device settings", actions: [.init(title: "Retry", style: .default, handler: { (_) in
                    self.verifyBiometricAuthentication()
                })])
            }
        }
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
