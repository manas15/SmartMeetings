//
//  File.swift
//  SmartMeetings
//
//  Created by Manas Sharma on 19/06/16.
//  Copyright © 2016 Manas Sharma. All rights reserved.
//

import Foundation
import UIKit

class Recording {
    var startTime: Int?
    var endTime: Int?
    var tagString: String?
    
    init(s: Int, e: Int, t: String) {
        self.startTime = s
        self.endTime = e
        self.tagString = t
    }
    
}