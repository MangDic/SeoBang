//
//  AppDelegate.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/17.
//

import UIKit
import NMapsMap
import FirebaseCore

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
   
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        guard let window = window else { return false }
        setupFirebase()
        setupNMAP()
        
        let rootViewController = UINavigationController()
        rootViewController.navigationBar.isHidden = true
        
        var vc: UIViewController!
        
        if UserInfoService.shared.userNickName == "Null" {
            vc = InitializingViewController()
        }
        else {
            vc = MainTabBarController()
        }
        
        window.rootViewController = rootViewController
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        
        rootViewController.pushViewController(vc, animated: true)
        
        return true
    }
    
    private func setupFirebase() {
        FirebaseApp.configure()
    }
    
    private func setupNMAP() {
        NMFAuthManager.shared().clientId = NetworkService.nmap_api_key
    }
}

