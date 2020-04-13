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
    
    @IBOutlet weak var backgroundView: UIView!
    var sphereView: DBSphereView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var segmentedControlTopWords: UISegmentedControl!
    @IBOutlet weak var daysLoggedLabel: UILabel!
    let screenSize: CGRect = UIScreen.main.bounds
    let iCloudKeyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore()
    var segmentedControlLastIndex: Int = 0
    var segmentedControlTopWordsLastIndex: Int = 0
    var theme: ThemeController!
    var stopWords: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sphereView = DBSphereView(frame: CGRect(x: 10, y: (screenSize.height / 2) - 270, width: screenSize.width - 20, height: screenSize.width - 20))
        self.containerView.addSubview(sphereView)
        self.containerView.sendSubview(toBack: sphereView)
        theme = ThemeManager.currentTheme()
        headerView.backgroundColor = theme.mainColor
        backgroundView.backgroundColor = theme.secondaryColor
        containerView.backgroundColor = theme.secondaryColor
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        segmentedControl.layer.zPosition = 1
        segmentedControlTopWords.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .selected)
        segmentedControlTopWords.setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.white], for: .normal)
        segmentedControlTopWords.layer.zPosition = 1
        
        stopWords = readStopWords()

        if #available(iOS 13.0, *) {
            segmentedControl.selectedSegmentTintColor = theme.mainColor
            segmentedControlTopWords.selectedSegmentTintColor = theme.mainColor
        }
        
        if iCloudKeyStore.bool(forKey: "segmentedControlDaysBackLastIndex") {
            self.segmentedControlLastIndex = Int(iCloudKeyStore.longLong(forKey: "segmentedControlDaysBackLastIndex"))
            self.segmentedControl.selectedSegmentIndex = self.segmentedControlLastIndex
        } else {
            iCloudKeyStore.set(self.segmentedControlLastIndex, forKey: "segmentedControlDaysBackLastIndex")
            iCloudKeyStore.synchronize()
        }
        
        if iCloudKeyStore.bool(forKey: "segmentedControlTopWordsLastIndex") {
            self.segmentedControlTopWordsLastIndex = Int(iCloudKeyStore.longLong(forKey: "segmentedControlTopWordsLastIndex"))
            self.segmentedControlTopWords.selectedSegmentIndex = self.segmentedControlTopWordsLastIndex
        } else {
            iCloudKeyStore.set(self.segmentedControlTopWordsLastIndex, forKey: "segmentedControlTopWordsLastIndex")
            iCloudKeyStore.synchronize()
        }
    
        self.updateSphereView()
        self.daysLoggedLabel.textColor = UIColor.black
        let daysLogged = getNumberOfDaysLogged()
        self.daysLoggedLabel.text = String(daysLogged) + " days logged"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let daysLogged = getNumberOfDaysLogged()
        self.daysLoggedLabel.text = String(daysLogged) + " days logged"
    }
    
    func updateSphereView() {
        var array = [UIButton]()
        let words = getWords()
        
        var sphereOffset: CGFloat = 20.0
        if (self.segmentedControlTopWordsLastIndex == 1) {
            sphereOffset = 100.0
        } else if (self.segmentedControlTopWordsLastIndex == 2) {
            sphereOffset = 180.0
        }
        
        sphereView.removeFromSuperview()
        sphereView = DBSphereView(frame: CGRect(x: (screenSize.width / 2) - ((screenSize.width - sphereOffset) / 2), y: (screenSize.height / 2) - ((screenSize.width - sphereOffset) / 2) - 60, width: screenSize.width - sphereOffset, height: screenSize.width - sphereOffset))
        self.containerView.addSubview(sphereView)
        self.containerView.sendSubview(toBack: sphereView)
        
        for wordTouple in words {
            let btn = UIButton(type: UIButton.ButtonType.system)
            btn.setTitle(wordTouple.0, for: .normal)
            btn.setTitleColor(.darkGray, for: .normal)
            var weight = CGFloat()
            switch wordTouple.1 {
            case 0..<5:
                weight = 0.38
            case 5..<10:
                weight = 0.45
            case 10..<15:
                weight = 0.52
            default:
                weight = 0.55
            }
            let fontWeight = UIFont.Weight(weight)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: fontWeight)
            btn.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
            array.append(btn)
            sphereView.addSubview(btn)
        }
        
        sphereView.setCloudTags(array)
    }
    
    @IBAction func segmentedControlDaysBackIndexChanged(_ sender: Any) {
        self.segmentedControlLastIndex = (sender as AnyObject).selectedSegmentIndex
        iCloudKeyStore.set(self.segmentedControlLastIndex, forKey: "segmentedControlDaysBackLastIndex")
        iCloudKeyStore.synchronize()
        self.updateSphereView()
    }
    
    @IBAction func segmentedControlTopWordsIndexChanged(_ sender: Any) {
        self.segmentedControlTopWordsLastIndex = (sender as AnyObject).selectedSegmentIndex
        iCloudKeyStore.set(self.segmentedControlTopWordsLastIndex, forKey: "segmentedControlTopWordsLastIndex")
        iCloudKeyStore.synchronize()
        self.updateSphereView()
    }
    
    func getWords() -> [(String,Int)] {
        var wordCounts = [String : Int]()
        let iCloudDict = iCloudKeyStore.dictionaryRepresentation
        var daysBack: Int = 9999
        if (self.segmentedControlLastIndex == 2) {
            daysBack = 30
        } else if (self.segmentedControlLastIndex == 1) {
            daysBack = 90
        }
        
        for (key, value) in iCloudDict {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let thingsDate = dateFormatter.date(from: key) {
                let startDate = Calendar.current.date(byAdding: .day, value: -daysBack, to: Date())
                let fallsBetween = (startDate! ... Date()).contains(thingsDate)
                if (!fallsBetween) {
                    continue
                }
            } else {
                continue
            }
            
            if let things = value as? [String] {
                for thing in things {
                    let words = thing.wordList
                    for word in words {
                        // Ignore words that contain numbers
                        let numbersRange = word.rangeOfCharacter(from: .decimalDigits)
                        if (numbersRange != nil) {
                            continue
                        }
                        // Convert word to lowercase and add to word dict
                        let word = word.lowercased()
                        if wordCounts[word] == nil {
                            wordCounts[word] = 1
                        } else {
                            wordCounts[word] = wordCounts[word]! + 1
                        }
                    }
                }
            }
        }
        let sortedWordCounts = wordCounts.sorted { $0.1 > $1.1 }
        var words = [(String, Int)]()
        var maxWords = 50
        if (self.segmentedControlTopWordsLastIndex == 1) {
            maxWords = 25
        } else if (self.segmentedControlTopWordsLastIndex == 2) {
            maxWords = 10
        }
        for (word, count) in sortedWordCounts {
            if self.stopWords.contains(word) {
                continue
            }
            if maxWords > 0 {
                words.append((word,count))
                maxWords = maxWords - 1
            }
        }
        return words.shuffled()
    }
    
    func getNumberOfDaysLogged() -> Int {
        let iCloudDict = iCloudKeyStore.dictionaryRepresentation
        return iCloudDict.count - 3
    }
    
    func readStopWords() -> [String] {
        let filename = "stop_words.txt"
        if let path = Bundle.main.path(forResource: filename, ofType: nil) {
            do {
                let content = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                var stopWords = [String]()
                content.enumerateLines { line, _ in
                    stopWords.append(line)
                }
                return stopWords
            } catch {
                print("Failed to read text from \(filename)")
            }
        } else {
            print("Failed to load file from app bundle \(filename)")
        }
        return ["nil"]
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
