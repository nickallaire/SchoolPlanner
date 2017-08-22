//
//  CustomTableViewCell.swift
//  School Planner
//
//  Created by Nick Allaire on 8/22/17.
//  Copyright © 2017 Nick Allaire. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var classNameText: UILabel!
    @IBOutlet weak var classDayAndTimeText: UILabel!
    @IBOutlet weak var classLocationText: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
