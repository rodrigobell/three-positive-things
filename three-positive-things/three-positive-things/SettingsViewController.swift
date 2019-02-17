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
    @IBOutlet weak var headerView: UIView!
    
    let colors = ThemeController.allCases
    
    override func viewDidLoad() {
        colorsTableView.delegate = self
        colorsTableView.dataSource = self
        colorsTableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let theme = ThemeManager.currentTheme()
        headerView.backgroundColor = theme.mainColor
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
        return 38
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "color-option-cell", for: indexPath) as! ColorOptionTableViewCell
        
        let theme = colors[indexPath.row]
        let currentTheme = ThemeManager.currentTheme()
        if theme == currentTheme {
            colorsTableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    
        cell.colorLabel.text = theme.name
        cell.colorView.backgroundColor = theme.mainColor
        cell.colorView.layer.cornerRadius = 10
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let theme = colors[indexPath.row]
        ThemeManager.applyTheme(theme: theme)
        headerView.backgroundColor = theme.mainColor
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .none
            
        }
    }
}
