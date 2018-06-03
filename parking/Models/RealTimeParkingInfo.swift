//
//  RealTimeParkingInfo.swift
//  parking
//
//  Created by Xingping Ding on 2018/3/22.
//  Copyright © 2018 Xingping Ding. All rights reserved.
//

import UIKit
import SwiftyJSON

// Real Time Parking Info Model
class RealTimeParkingInfo: NSObject {
    
    var bay_id : String?
    var lat : Double = 0
    var lon : Double = 0
    var st_marker_id : String?
    var status : String?
    
    init(dict: JSON) {
        bay_id = dict["bay_id"].stringValue
        lat = dict["lat"].doubleValue
        lon = dict["lon"].doubleValue
        st_marker_id = dict["st_marker_id"].stringValue
        status = dict["status"].stringValue
        
        super.init()
    }
}
