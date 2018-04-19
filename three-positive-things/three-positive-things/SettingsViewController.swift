//
//  SettingsViewController.swift
//  three-positive-things
//
//  Created by Rodrigo Bell on 2/6/18.
//  Copyright © 2018 Rodrigo Bell. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        print("hello settings")
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
//        _ = self.navigationController?.navigationController?.popViewController(animated: true)
        print("button pressed")

    }
    
}
