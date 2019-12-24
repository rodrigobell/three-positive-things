//
//  CalendarViewController.swift
//  three-positive-things
//
//  Created by Rodrigo Bell on 4/2/17.
//  Copyright © 2017 Rodrigo Bell. All rights reserved.
//

import UIKit
import CloudKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var weekDayLabels: UIStackView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableViewYConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewCoverHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var calendarViewBottomOffsetConstraint: NSLayoutConstraint!
    let iCloudKeyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore()
    var positiveThings: [NSDictionary] = []
    var currentDate: Date!
    var theme: ThemeController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 13.0, *) {
            // Always adopt a light interface style.
            overrideUserInterfaceStyle = .light
        }
        if (UIScreen.main.bounds.height < 600) {
            headerViewHeightConstraint.constant -= 20
        }
        
        let screenHeight = UIScreen.main.bounds.height
        let headerHeight = self.headerView.bounds.height
        let delta = (screenHeight - headerHeight) / 2
        tableViewHeightConstraint.constant = delta
        tableViewCoverHeightConstraint.constant = delta
        calendarViewBottomOffsetConstraint.constant = delta
        tableView.rowHeight = delta / 3
        
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.registerCellViewXib(file: "DateCellView") // Registering your cell is mandatory
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        calendarView.reloadDates(calendarView.visibleDates().monthDates) // This will take care of loading saved user data upon app reinstall
        goToToday()
        
        tableView.delegate = self
        tableView.dataSource = self
        theme = ThemeManager.currentTheme()
        currentDate = Date()
        
        if #available(iOS 10.3, *) {
            ReviewHandler().showReviewView(atLaunchCounts: [2,5,15,30,60])
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(saveThingsToDate), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        let iCloudDict = iCloudKeyStore.dictionaryRepresentation
        for (key, value) in iCloudDict {
            if let arr = value as? Array<Any> {
                if (arr.isEmpty) {
                    iCloudKeyStore.removeObject(forKey: key)
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        theme = ThemeManager.currentTheme()
        headerView.backgroundColor = theme.mainColor
        backgroundView.backgroundColor = theme.secondaryColor
        tableView.reloadData()
        if currentDate != Date() {
            calendarView.reloadData()
            currentDate = Date()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        endTableViewEditing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // Function to handle the text color of the calendar
    func handleCellTextColor(view: JTAppleDayCellView?, date: Date, cellState: CellState) {
        guard let myCustomCell = view as? DateCellView else {
            return
        }

        if cellState.isSelected {
            myCustomCell.dayLabel.textColor = UIColor.white
        } else {
            if Calendar.current.isDateInToday(date) && cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = UIColor.red
            } else if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = UIColor.black
            } else {
                myCustomCell.dayLabel.textColor = UIColor.gray
            }
        }
    }
    
    // Function to handle the calendar selection
    func handleCellSelection(view: JTAppleDayCellView?, date: Date, cellState: CellState) {
        guard let myCustomCell = view as? DateCellView  else {
            return
        }
        
        if cellState.isSelected {
            if Calendar.current.isDateInToday(date) && cellState.dateBelongsTo == .thisMonth  {
                myCustomCell.selectedView.layer.backgroundColor = UIColor.red.cgColor
            } else {
                myCustomCell.selectedView.layer.backgroundColor = UIColor.black.cgColor
            }
            myCustomCell.selectedView.layer.cornerRadius = 20
            myCustomCell.selectedView.isHidden = false
        } else {
            myCustomCell.selectedView.isHidden = true
        }
    }
    
    // Function to handle displaying dot view for cells with data
    func handleCellDisplayDotView(view: JTAppleDayCellView?, date: Date, cellState: CellState) {
        guard let myCustomCell = view as? DateCellView  else {
            return
        }
        
        myCustomCell.dotView.layer.cornerRadius = 3
        myCustomCell.dotView.isHidden = false
        
        if cellState.isSelected {
            myCustomCell.dotView.layer.backgroundColor  = UIColor.white.cgColor
        } else {
            if Calendar.current.isDateInToday(date) && cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dotView.layer.backgroundColor = UIColor.red.cgColor
            } else if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dotView.layer.backgroundColor = UIColor.black.cgColor
            } else {
                myCustomCell.dotView.layer.backgroundColor = UIColor.gray.cgColor
            }
        }
    }
    
    func endTableViewEditing() {
        saveThingsToDate()
        self.tableViewYConstraint.priority = UILayoutPriority(rawValue: 1)
        self.calendarView.reloadDates(self.calendarView.selectedDates)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.weekDayLabels.isHidden = false
            self.calendarView.isHidden = false
        }

        tableView.endEditing(true)
    }
    
    @objc func saveThingsToDate() {
        let date = calendarView.selectedDates[0]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        var things = [String]()
        for cell in tableView.visibleCells {
            let customCell = cell as! PositiveThingTableViewCell
            let thing = customCell.positiveThingTextView.text as String
            if !(thing.isEmpty) {
                things.append(thing)
            }
        }
        
        if !(things.isEmpty) {
            iCloudKeyStore.set(things, forKey: "\(dateString)")
        } else {
            iCloudKeyStore.removeObject(forKey: "\(dateString)")
        }
        iCloudKeyStore.synchronize()
    }
    
    func goToToday() {
        calendarView.scrollToDate(Date())
        calendarView.selectDates([Date()])
    }
    
    @IBAction func didTapToday(_ sender: Any) {
        endTableViewEditing()
        goToToday()
    }
}

// JTAppleCalendar methods
extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let startDate = formatter.date(from: "2016-01-01")!
        let endDate = Date()
        let calendar = Calendar.current
        
        let parameters = ConfigurationParameters(startDate: startDate,
                                                 endDate: endDate,
                                                 numberOfRows: 6,
                                                 calendar: calendar,
                                                 generateInDates: .forAllMonths,
                                                 generateOutDates: .tillEndOfGrid,
                                                 firstDayOfWeek: .sunday)
        return parameters
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        handleCellTextColor(view: cell, date: date, cellState: cellState)
        handleCellSelection(view: cell, date: date, cellState: cellState)
        
        let myCustomCell = cell as! DateCellView
        
        // Setup Cell text day numbers
        myCustomCell.dayLabel.text = cellState.text
        myCustomCell.dotView.isHidden = true
        
        let isPartOfThisMonth = cellState.dateBelongsTo == .thisMonth
        myCustomCell.isUserInteractionEnabled = isPartOfThisMonth ? true : false
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        if let things = iCloudKeyStore.array(forKey: "\(dateString)") as? [String], things.isEmpty == false {
            handleCellDisplayDotView(view: cell, date: date, cellState: cellState)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, date: date, cellState: cellState)
        handleCellTextColor(view: cell, date: date, cellState: cellState)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        if let things = iCloudKeyStore.array(forKey: "\(dateString)") as? [String], things.isEmpty == false {
            var i = 0
            for thing in things {
                let tableCell = tableView.visibleCells[i]
                let customCell = tableCell as! PositiveThingTableViewCell
                customCell.positiveThingTextView.text = thing
                i += 1
            }
            handleCellDisplayDotView(view: cell, date: date, cellState: cellState)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, date: date, cellState: cellState)
        handleCellTextColor(view: cell, date: date, cellState: cellState)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        if let myCustomCell = cell as? DateCellView {
            if let things = iCloudKeyStore.array(forKey: "\(dateString)") as? [String], things.isEmpty == false {
                myCustomCell.dotView.isHidden = true
            }
        }
        
        if let things = iCloudKeyStore.array(forKey: "\(dateString)") as? [String], things.isEmpty == false {
            handleCellDisplayDotView(view: cell, date: date, cellState: cellState)
        }
    
        for cell in tableView.visibleCells {
            let customCell = cell as! PositiveThingTableViewCell
            customCell.positiveThingTextView.text = nil
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        calendarView.deselectAllDates()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let strDate = formatter.string(from: Date())
        let curDate = formatter.date(from: strDate)!
        
        if visibleDates.monthDates.contains(curDate) {
            calendarView.selectDates([Date()])
        } else {
            calendarView.selectDates([visibleDates.monthDates.first!])
        }
        
        // Update header text month and year labels
        let startDate = visibleDates.monthDates[0]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        let month = dateFormatter.string(from: startDate)
        self.monthLabel.text = month
        
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: startDate)
        yearLabel.text = "\(year)"
    }

}

// TableView methods
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "positive-thing-cell", for: indexPath) as! PositiveThingTableViewCell
        
        cell.selectionStyle = .none
        
        if (indexPath.row == 0) {
            cell.positiveThingNumberLabel.text = "1."
        } else if (indexPath.row == 1) {
            cell.positiveThingNumberLabel.text = "2."
        } else if (indexPath.row == 2) {
            cell.positiveThingNumberLabel.text = "3."
        }
        cell.positiveThingTextView.textContainer.maximumNumberOfLines = 2
        cell.positiveThingTextView.textContainer.lineBreakMode = .byClipping
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = theme.secondaryColor
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        saveThingsToDate()
    }
}

// GestureRecognizer methods
extension CalendarViewController: UIGestureRecognizerDelegate {
    @IBAction func onTableViewCoverTapGesture(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.tableView)
        
        if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
            if let tapCell = self.tableView.cellForRow(at: tapIndexPath) as? PositiveThingTableViewCell {
                tapCell.positiveThingTextView.becomeFirstResponder()
            }
        }
        
        self.tableViewYConstraint.priority = UILayoutPriority(rawValue: 999)
        self.tableViewYConstraint.constant = 0
        if (UIScreen.main.bounds.height < 600) {
            self.tableViewYConstraint.constant = -self.weekDayLabels.bounds.height - 12
        }

        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.calendarView.isHidden = true
        }
        
        UIView.transition(with: self.weekDayLabels, duration: 0.4, options: .transitionCrossDissolve, animations: {() -> Void in
            self.weekDayLabels.isHidden = true
        }, completion: { _ in })
    }
    
    @IBAction func onTableViewSwipeGesture(_ sender: Any) {
        endTableViewEditing()
    }
    
    @IBAction func onHeaderViewTapGesture(_ sender: UITapGestureRecognizer) {
        endTableViewEditing()
    }
}
