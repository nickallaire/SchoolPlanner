//
//  FourthViewController.swift
//  School Planner
//
//  Created by Nick Allaire on 12/16/16.
//  Copyright © 2016 Nick Allaire. All rights reserved.
//

import UIKit

class FourthViewController: UIViewController {
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var barButtonItem: UIBarButtonItem!
    @IBOutlet weak var navBar: UINavigationBar!
    var className = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib
        let barViewController = self.tabBarController?.viewControllers
        let svc = barViewController?[0] as! ThirdViewController
        self.className = svc.className
        self.navItem.title = self.className
        self.barButtonItem.title = "Back"
        self.navItem.leftBarButtonItem = barButtonItem
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.barButtonItem.tintColor = UIColor.white
        self.navBar.barTintColor = UIColor(red: 0.1255, green: 0.6039, blue: 0.6784, alpha: 1.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
}
