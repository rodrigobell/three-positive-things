//
//  WordCloudViewController.swift
//  three-positive-things
//
//  Created by Rodrigo Bell on 2/18/19.
//  Copyright © 2019 Rodrigo Bell. All rights reserved.
//

import UIKit
import DBSphereTagCloudSwift

class WordCloudViewController: UIViewController {
    
    var sphereView: DBSphereView!
    @IBOutlet weak var containerView: UIView!
    let screenSize: CGRect = UIScreen.main.bounds
    let iCloudKeyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sphereView = DBSphereView(frame: CGRect(x: 20, y: (screenSize.height / 2) - 280, width: screenSize.width - 40, height: screenSize.width - 40))
        print(screenSize.width)
        var array = [UIButton]()
        
        let words = getWords()
        
        for word in words {
            let btn = UIButton(type: UIButton.ButtonType.system)
            btn.setTitle(word, for: .normal)
            btn.setTitleColor(.darkGray, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: 1.2)
            btn.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
            array.append(btn)
            sphereView.addSubview(btn)
        }
        
        sphereView.setCloudTags(array)
        sphereView.backgroundColor = .white
        self.containerView.addSubview(sphereView)

    }
    
    func getWords() -> [String] {
        var wordCounts = [String : Int]()
        let iCloudDict = iCloudKeyStore.dictionaryRepresentation
        for (_, value) in iCloudDict {
            if let things = value as? [String] {
                for thing in things {
                    let words = thing.wordList
                    for word in words {
                        if wordCounts[word] == nil {
                            wordCounts[word] = 1
                        } else {
                            wordCounts[word] = wordCounts[word]! + 1
                        }
                    }
                }
            }
        }
        var words = [String]()
        for (word, count) in wordCounts {
            if count > 0 {
                words.append(word)
            }
        }
        return words
    }

    @IBAction func backButtonPressed(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
}

extension String {
    var wordList: [String] {
        return components(separatedBy: .punctuationCharacters)
            .joined()
            .components(separatedBy: .whitespaces)
    }
}
