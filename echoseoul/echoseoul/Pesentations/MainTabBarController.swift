//
//  MainTabBarController.swift
//  echoseoul
//
//  Created by 이명직 on 2023/05/19.
//

import UIKit

class MainTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTabBar()
        setupViewController()
    }
    
    private func setupTabBar() {
        tabBar.tintColor = .white
        tabBar.unselectedItemTintColor = #colorLiteral(red: 0.8783859611, green: 0.8894438744, blue: 0.8892493844, alpha: 1)
        
        // iOS 15 이상부터 탭바 배경색이 투명
        if #available(iOS 15, *) {
            let appearance = UITabBarAppearance()
            let tabBar = UITabBar()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
            appearance.stackedLayoutAppearance.selected.iconColor = .white
            appearance.stackedLayoutAppearance.normal.iconColor = #colorLiteral(red: 0.8783859611, green: 0.8894438744, blue: 0.8892493844, alpha: 1)
            tabBar.standardAppearance = appearance;
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        else {
            tabBar.barTintColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
        }
    }
    
    private func setupViewController() {
        let homeVC = HomeViewControllerController()
        let mapVC = MapViewController()
        
        let homeItem = UITabBarItem(title: "홈", image: UIImage(systemName: "house"), tag: 0)
        let mapItem = UITabBarItem(title: "지도", image: UIImage(systemName: "map"), tag: 1)
        
        homeVC.tabBarItem = homeItem
        mapVC.tabBarItem = mapItem
        
        viewControllers = [homeVC, mapVC]
    }
}
