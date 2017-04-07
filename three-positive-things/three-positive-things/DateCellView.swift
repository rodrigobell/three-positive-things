//
//  DateCellView.swift
//  three-positive-things
//
//  Created by Rodrigo Bell on 4/2/17.
//  Copyright © 2017 Rodrigo Bell. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateCellView: JTAppleDayCellView {
    @IBOutlet weak var selectedView: DateCellView!
    @IBOutlet weak var dayLabel: UILabel!
}
