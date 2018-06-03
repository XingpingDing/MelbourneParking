//
//  NetworkTool.swift
//  parking
//
//  Created by Xingping Ding on 2018/3/22.
//  Copyright © 2018 Xingping Ding. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import GoogleMaps

let SERVER_URL = "http://115.146.95.41:8000/parkdata/"

class NetworkTool: Alamofire.SessionManager {
    // Singleton
    internal static let sharedTools: NetworkTool = {
        let configuration = URLSessionConfiguration.default
        var header : Dictionary =  SessionManager.defaultHTTPHeaders
        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
        return NetworkTool(configuration: configuration)
    }()
    
    // Get parking list
    func getParkingList(finished: @escaping (_ parkingList:[RealTimeParkingInfo]?, _ error: Error?) -> ()) {
        let parkingListURL = "https://data.melbourne.vic.gov.au/resource/dtpv-d4pf.json?$limit=5000&$$app_token=aPPduezsSg5xNnsZIsYLvgyLO"
        NSLog(parkingListURL)
        
        request(parkingListURL, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(queue: DispatchQueue.main, options: .mutableContainers) { (response) in
            if response.result.isSuccess {
                if let value = response.result.value {
                    let swiftyJsonVar = JSON(value)
                    var parkingList = [RealTimeParkingInfo]()
                    for (_, dict) : (String, JSON) in swiftyJsonVar {
                            let parking = RealTimeParkingInfo(dict: dict)
                            parkingList.append(parking)
                        }
                        finished(parkingList, nil)
                } else {
                    finished(nil, NSError.init(domain: "Sever Error", code: 44, userInfo: nil))
                }
            } else {
                finished(nil, response.result.error)
            }
        }
    }
    
    // Get analysis data
    func getAnalysisData(bayid: String, finished: @escaping (_ analysisData: JSON?, _ error: Error?) -> ()) {
        let bayDetailsListURL = SERVER_URL + "lastweekdata?bayid=" + bayid
        NSLog(bayDetailsListURL)
        
        request(bayDetailsListURL, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(queue: DispatchQueue.main, options: .mutableContainers) { (response) in
            if response.result.isSuccess {
                if let value = response.result.value {
                    let swiftyJsonVar = JSON(value)
                    finished(swiftyJsonVar, nil)
                } else {
                    finished(nil, NSError.init(domain: "Sever Error", code: 44, userInfo: nil))
                }
            } else {
                finished(nil, response.result.error)
            }
        }
    }
    
    // Get predicted data
    func getPredictedData(streetmarker: String, finished: @escaping (_ predictedData: JSON?, _ error: Error?) -> ()) {
        let bayDetailsListURL = SERVER_URL + "predict?streetMarker=" + streetmarker
        NSLog(bayDetailsListURL)
        
        request(bayDetailsListURL, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(queue: DispatchQueue.main, options: .mutableContainers) { (response) in
            if response.result.isSuccess {
                if let value = response.result.value {
                    let swiftyJsonVar = JSON(value)
                    finished(swiftyJsonVar, nil)
                } else {
                    finished(nil, NSError.init(domain: "Sever Error", code: 44, userInfo: nil))
                }
            } else {
                finished(nil, response.result.error)
            }
        }
    }
    
    // Get Suggest Bays data
    func getSuggestBays(parameters: [String : Any], finished: @escaping (_ suggestBaysData: JSON?, _ error: Error?) -> ()) {
        let suggestBaysURL = SERVER_URL + "suggestbays"
        NSLog(suggestBaysURL)
        
        request(suggestBaysURL, method: HTTPMethod.post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON(queue: DispatchQueue.main, options: .mutableContainers) { (response) in
            if response.result.isSuccess {
                if let value = response.result.value {
                    let swiftyJsonVar = JSON(value)
                    finished(swiftyJsonVar, nil)
                } else {
                    finished(nil, NSError.init(domain: "Sever Error", code: 44, userInfo: nil))
                }
            } else {
                finished(nil, response.result.error)
            }
        }
    }
    
    //Get during data
    func getDuringData(location1: CLLocation, location2: CLLocation, finished: @escaping (_ result: JSON?, _ error: Error?) -> ()) {
        let duringURL = String(format: "https://maps.googleapis.com/maps/api/distancematrix/json?origins=%f,%f&destinations=%f,%f&language=en&key=AIzaSyDd8KmlCHtmJ0YGVdYWrxpZwTrWAoWglCw", location1.coordinate.latitude, location1.coordinate.longitude, location2.coordinate.latitude, location2.coordinate.longitude)
        NSLog(duringURL)
        
        request(duringURL, method: HTTPMethod.get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseJSON(queue: DispatchQueue.main, options: .mutableContainers) { (response) in
            if response.result.isSuccess {
                if let value = response.result.value {
                    let swiftyJsonVar = JSON(value)
                    finished(swiftyJsonVar, nil)
                } else {
                    finished(nil, NSError.init(domain: "Sever Error", code: 44, userInfo: nil))
                }
            } else {
                finished(nil, response.result.error)
            }
        }
    }
}
