//
//  Utility.swift
//  iBazre
//
//  Created by Levan Charuashvili on 21.01.23.
//

import Foundation
import UIKit


func goToFeed(){
    let story = UIStoryboard(name: "Main", bundle:nil)
    let vc = story.instantiateViewController(withIdentifier: "feedVC") as! UITabBarController
    UIApplication.shared.windows.first?.rootViewController = vc
    UIApplication.shared.windows.first?.makeKeyAndVisible()
}





