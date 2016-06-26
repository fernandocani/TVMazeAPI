//
//  NavigationViewController.swift
//  TVMaze API
//
//  Created by Fernando Cani on 6/23/16.
//  Copyright © 2016 com.fernandocani. All rights reserved.
//

import UIKit

class NavigationViewController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationBar.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        self.navigationBar.backgroundColor      = UIColor(hex: blackColor)
        self.navigationBar.tintColor            = UIColor.whiteColor()
        self.navigationBar.titleTextAttributes  = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
}