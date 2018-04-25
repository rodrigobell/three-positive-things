//
//  Theme.swift
//  three-positive-things
//
//  Created by Rodrigo Bell on 4/23/18.
//  Copyright © 2018 Rodrigo Bell. All rights reserved.
//

import UIKit
import ChameleonFramework

enum Theme: Int {
    case Orange, Red, NavyBlue, Black, Magenta, Teal, SkyBlue, Green, Mint, Blue, Coffee
    
    var mainColor: UIColor {
        switch self {
        case .Orange:
            return FlatOrange()
        case .Red:
            return FlatRed()
        case .NavyBlue:
            return FlatNavyBlue()
        case .Black:
            return FlatBlack()
        case .Magenta:
            return FlatMagenta()
        case .Teal:
            return FlatTeal()
        case .SkyBlue:
            return FlatSkyBlue()
        case .Green:
            return FlatGreen()
        case .Mint:
            return FlatMint()
        case .Blue:
            return FlatBlue()
        case .Coffee:
            return FlatCoffee()
        }
    }
    
    var secondaryColor: UIColor {
        switch self {
        case .Orange:
            return FlatOrange().withAlphaComponent(0.1)
        case .Red:
            return FlatRed().withAlphaComponent(0.1)
        case .NavyBlue:
            return FlatNavyBlue().withAlphaComponent(0.1)
        case .Black:
            return FlatBlack().withAlphaComponent(0.1)
        case .Magenta:
            return FlatMagenta().withAlphaComponent(0.1)
        case .Teal:
            return FlatTeal().withAlphaComponent(0.1)
        case .SkyBlue:
            return FlatSkyBlue().withAlphaComponent(0.1)
        case .Green:
            return FlatGreen().withAlphaComponent(0.1)
        case .Mint:
            return FlatMint().withAlphaComponent(0.1)
        case .Blue:
            return FlatBlue().withAlphaComponent(0.1)
        case .Coffee:
            return FlatCoffee().withAlphaComponent(0.1)
        }
    }
    
    var name: String {
        switch self {
        case .Orange:
            return "Orange"
        case .Red:
            return "Red"
        case .NavyBlue:
            return "Navy Blue"
        case .Black:
            return "Black"
        case .Magenta:
            return "Magenta"
        case .Teal:
            return "Teal"
        case .SkyBlue:
            return "Sky Blue"
        case .Green:
            return "Green"
        case .Mint:
            return "Mint"
        case .Blue:
            return "Blue"
        case .Coffee:
            return "Coffee"
        }
    }
    
    static var allCases: [Theme] {
        var values: [Theme] = []
        var index = 0
        while let element = self.init(rawValue: index) {
            values.append(element)
            index += 1
        }
        return values
    }
}

let selectedThemeKey = "SelectedTheme"
struct ThemeManager {
    static func currentTheme() -> Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: selectedThemeKey) as AnyObject).integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .Orange
        }
    }
    
    static func applyTheme(theme: Theme) {
        // 1
        UserDefaults.standard.setValue(theme.rawValue, forKey: selectedThemeKey)
        UserDefaults.standard.synchronize()
        // 2
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(
            red: (hex >> 16) & 0xFF,
            green: (hex >> 8) & 0xFF,
            blue: hex & 0xFF
        )
    }
}
