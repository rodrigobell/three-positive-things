//
//  CalendarViewController.swift
//  three-positive-things
//
//  Created by Rodrigo Bell on 4/2/17.
//  Copyright © 2017 Rodrigo Bell. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController {
    
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var yearLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let userDefaults = UserDefaults.standard
    
    var positiveThings: [NSDictionary] = []
    
    let black = UIColor.black
    let gray = UIColor.gray
    let white = UIColor.white
    let red = UIColor.red
    
    var bottomPositionTableView: CGPoint?
    var topPositionTableView: CGPoint?
    
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
        topPositionTableView = CGPoint(x: tableView.center.x, y: tableView.center.y - 262)
    
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
            myCustomCell.dayLabel.textColor = white
        } else {
            if Calendar.current.isDateInToday(date) && cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = red
            } else if cellState.dateBelongsTo == .thisMonth {
                myCustomCell.dayLabel.textColor = black
            } else {
                myCustomCell.dayLabel.textColor = gray
            }
        }
    }
    
    // Function to handle the calendar selection
    func handleCellSelection(view: JTAppleDayCellView?, date: Date, cellState: CellState) {
        guard let myCustomCell = view as? DateCellView  else {
            return
        }
        
        if Calendar.current.isDateInToday(date) && cellState.dateBelongsTo == .thisMonth  {
            myCustomCell.selectedView.layer.backgroundColor = red.cgColor
        }
        
        if cellState.isSelected {
            myCustomCell.selectedView.layer.cornerRadius = 20
            myCustomCell.selectedView.isHidden = false
        } else {
            myCustomCell.selectedView.isHidden = true
        }
    }
    
    func goToToday() {
        calendarView.scrollToDate(Date())
        calendarView.selectDates([Date()])
    }
    
    @IBAction func didTapToday(_ sender: Any) {
        goToToday()
    }
}

// JTAppleCalendar methods
extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = formatter.date(from: "2016 01 01")! // You can use date generated from a formatter
        let endDate = Date()                                // You can also use dates created from this function
        let calendar = Calendar.current                     // Make sure you set this up to your time zone. We'll just use default here
        
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
        let myCustomCell = cell as! DateCellView
        
        // Setup Cell text
        myCustomCell.dayLabel.text = cellState.text
        
        if cellState.dateBelongsTo == .thisMonth {
            myCustomCell.isUserInteractionEnabled = true
        } else {
            myCustomCell.isUserInteractionEnabled = false
        }
        
        handleCellTextColor(view: cell, date: date, cellState: cellState)
        handleCellSelection(view: cell, date: date, cellState: cellState)
        
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, date: date, cellState: cellState)
        handleCellTextColor(view: cell, date: date, cellState: cellState)
        
        if let tempThing = userDefaults.string(forKey: "test") {
            let tempCell = tableView.visibleCells.first as! PositiveThingTableViewCell
            tempCell.positiveThingTextView.text = tempThing
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleCellSelection(view: cell, date: date, cellState: cellState)
        handleCellTextColor(view: cell, date: date, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didScrollToDateSegmentWith visibleDates: DateSegmentInfo) {
        // TODO: Deselect cell if part of different than current month
//        let lastSelectedDate = calendarView.selectedDates.last
//        let cellState = calendarView.cellStatus(for: lastSelectedDate)
        
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
    }
    
    @IBAction func onHeaderViewTapGesture(_ sender: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3) {
            self.tableView.center = self.bottomPositionTableView!
        }
        tableView.endEditing(true)
        
        saveThingsToDate()
    }
    
    func saveThingsToDate() {
        for cell in tableView.visibleCells {
            let customCell = cell as! PositiveThingTableViewCell
            let thing = customCell.positiveThingTextView.text as String
            print(customCell.positiveThingTextView.text)
            print(thing)
            
            userDefaults.set(thing, forKey: "test")
        }
    }
}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}

