//
//  TabBarViewController.swift
//  iBazre
//
//  Created by Levan Charuashvili on 10.01.23.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let layer = CAShapeLayer()
                layer.path = UIBezierPath(roundedRect: CGRect(x: 30, y: self.tabBar.bounds.minY - 5, width: self.tabBar.bounds.width - 60, height: self.tabBar.bounds.height + 10), cornerRadius: (self.tabBar.frame.width/2)).cgPath
                layer.shadowColor = UIColor.lightGray.cgColor
                layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
                layer.shadowRadius = 25.0
                layer.shadowOpacity = 0.3
                layer.borderWidth = 1.0
                layer.opacity = 1.0
                layer.isHidden = false
                layer.masksToBounds = false
                layer.fillColor = UIColor(named: "TabBarMainColor")?.cgColor
          
                self.tabBar.layer.insertSublayer(layer, at: 0)
        
        if let items = self.tabBar.items {
          items.forEach { item in item.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) }
        }

        self.tabBar.itemWidth = 55.0
        self.tabBar.itemPositioning = .centered
    }
    


}

