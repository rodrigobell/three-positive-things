//
//  CalendarViewController.swift
//  three-positive-things
//
//  Created by Rodrigo Bell on 4/2/17.
//  Copyright © 2017 Rodrigo Bell. All rights reserved.
//

//
// TODO:
// > save empty table view cell if user deletes their data for a given day
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var weekDaysLabel: UILabel!
    @IBOutlet weak var headerView: UIView!
    
    let userDefaults = UserDefaults.standard
//    let iCloudKeyStore: NSUbiquitousKeyValueStore = NSUbiquitousKeyValueStore()
    var positiveThings: [NSDictionary] = []
    var bottomPositionTableView: CGPoint?
    var topPositionTableView: CGPoint?
    var theme: Theme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.delegate = self
        calendarView.dataSource = self
        calendarView.registerCellViewXib(file: "DateCellView") // Registering your cell is mandatory
        calendarView.cellInset = CGPoint(x: 0, y: 0)
        goToToday()
        
        tableView.delegate = self
        tableView.dataSource = self
        bottomPositionTableView = tableView.center
        topPositionTableView = CGPoint(x: tableView.center.x, y: tableView.center.y - 258)
        theme = ThemeManager.currentTheme()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        theme = ThemeManager.currentTheme()
        headerView.backgroundColor = theme.mainColor
        ThemeManager.applyTheme(theme: theme)
        tableView.reloadData()
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
        UIView.animate(withDuration: 0.3) {
            self.tableView.center = self.bottomPositionTableView!
            self.weekDaysLabel.isHidden = false
        }
        tableView.endEditing(true)
        
        saveThingsToDate()
    }
    
    func saveThingsToDate() {
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
            print("saving \(things) to date \(dateString)")
            userDefaults.set(things, forKey: "\(dateString)")
//            iCloudKeyStore.set(things, forKey: "\(dateString)")
        } else {
            userDefaults.set(nil, forKey: "\(dateString)")
//            iCloudKeyStore.set([], forKey: "\(dateString)")
        }
//        iCloudKeyStore.synchronize()
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
        
        if userDefaults.stringArray(forKey: "\(dateString)") != nil {
            handleCellDisplayDotView(view: cell, date: date, cellState: cellState)
        }
//        if let things = iCloudKeyStore.value(forKey: "\(dateString)") as? [String], things.isEmpty == false {
//            handleCellDisplayDotView(view: cell, date: date, cellState: cellState)
//        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, date: date, cellState: cellState)
        handleCellTextColor(view: cell, date: date, cellState: cellState)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: date)
        
        if let things = userDefaults.stringArray(forKey: "\(dateString)") {
            print("found \(things) for \(dateString)")
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
            if userDefaults.stringArray(forKey: "\(dateString)") == nil {
                myCustomCell.dotView.isHidden = true
            }
        }
        
        if userDefaults.stringArray(forKey: "\(dateString)") != nil {
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = theme.secondaryColor
    }
}

// GestireRecognizer methods
extension CalendarViewController: UIGestureRecognizerDelegate {
    @IBAction func onTableViewCoverTapGesture(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: self.tableView)
        
        if let tapIndexPath = self.tableView.indexPathForRow(at: tapLocation) {
            if let tapCell = self.tableView.cellForRow(at: tapIndexPath) as? PositiveThingTableViewCell {
                tapCell.positiveThingTextView.becomeFirstResponder()
            }
        }
        
        UIView.animate(withDuration: 0.3) {
            self.tableView.center = self.topPositionTableView!
        }
        
        UIView.transition(with: self.weekDaysLabel, duration: 0.4, options: .transitionCrossDissolve, animations: {() -> Void in
            self.weekDaysLabel.isHidden = true
        }, completion: { _ in })
    }
    
    @IBAction func onTableViewSwipeGesture(_ sender: Any) {
        endTableViewEditing()
    }
    
    @IBAction func onHeaderViewTapGesture(_ sender: UITapGestureRecognizer) {
        endTableViewEditing()
    }
}
