//
//  PositiveThingTableViewCell.swift
//  three-positive-things
//
//  Created by Rodrigo Bell on 4/7/17.
//  Copyright © 2017 Rodrigo Bell. All rights reserved.
//

import UIKit

class PositiveThingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var positiveThingTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
