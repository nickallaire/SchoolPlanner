//
//  AssignmentTableViewCell.swift
//  School Planner
//
//  Created by Nick Allaire on 8/22/17.
//  Copyright © 2017 Nick Allaire. All rights reserved.
//

import UIKit

class AssignmentTableViewCell: UITableViewCell {

    @IBOutlet weak var assignmentCategoryText: UILabel!
    @IBOutlet weak var assignmentGradeText: UILabel!
    @IBOutlet weak var assignmentNameText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if editing == true && editingStyle == .none {
            self.assignmentGradeText.frame.origin.x = 160
        } else {
            self.assignmentGradeText.frame.origin.x = 205
        }
    }

}
