//
//  RecordCell.swift
//  SmartMeetings
//
//  Created by Manas Sharma on 19/06/16.
//  Copyright © 2016 Manas Sharma. All rights reserved.
//

import UIKit

class RecordCell: UITableViewCell {
    @IBOutlet weak var playBtn: UIButton!
    
    @IBOutlet weak var tagLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
