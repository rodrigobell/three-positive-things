//
//  SettingsViewController.swift
//  three-positive-things
//
//  Created by Rodrigo Bell on 2/6/18.
//  Copyright © 2018 Rodrigo Bell. All rights reserved.
//

import UIKit
import ChameleonFramework

class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var colorsTableView: UITableView!
    
    let colors = Theme.allCases
    
    override func viewDidLoad() {
        colorsTableView.delegate = self
        colorsTableView.dataSource = self
        colorsTableView.separatorStyle = .none
    }
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colors.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "color-option-cell", for: indexPath) as! ColorOptionTableViewCell
        
        let theme = colors[indexPath.row]
        cell.colorLabel.text = theme.name
        cell.colorView.backgroundColor = theme.mainColor
        cell.colorView.layer.cornerRadius = 10
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let theme = colors[indexPath.row]
        ThemeManager.applyTheme(theme: theme)
    }
}
