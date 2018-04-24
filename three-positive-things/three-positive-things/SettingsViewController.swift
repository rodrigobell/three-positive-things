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
    
    let colors = [("Orange", Theme.Orange), ("Blue", Theme.Blue), ("Coffee", Theme.Coffee)]
    
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
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "color-option-cell", for: indexPath) as! ColorOptionTableViewCell
        
        let colorTuple = colors[indexPath.row]
        cell.colorLabel.text = colorTuple.0
        cell.colorView.backgroundColor = colorTuple.1.mainColor
        cell.colorView.layer.cornerRadius = 10
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let theme = colors[indexPath.row].1
        ThemeManager.applyTheme(theme: theme)
    }
}
