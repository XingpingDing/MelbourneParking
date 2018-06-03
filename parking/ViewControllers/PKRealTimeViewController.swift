//
//  PKRealTimeViewController.swift
//  parking
//
//  Created by Xingping Ding on 2018/3/22.
//  Copyright © 2018 Xingping Ding. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import SnapKit
import SwiftyJSON

class PKRealTimeViewController: UIViewController {
    
    var parkingList : [RealTimeParkingInfo]?
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 17.0
    
    // A default location to use when location permission is not granted.
    let defaultLocation = CLLocation(latitude: -37.799084, longitude: 144.963097)
    
    var nearByBayList: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize the location manager.
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.distanceFilter = 50
        locationManager.startUpdatingLocation()
        locationManager.delegate = self

        placesClient = GMSPlacesClient.shared()

        // Create a GMSCameraPosition that tells the map to display the coordinate
        let camera = GMSCameraPosition.camera(withLatitude: defaultLocation.coordinate.latitude,
                                              longitude: defaultLocation.coordinate.longitude,
                                              zoom: zoomLevel)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.isMyLocationEnabled = true
        mapView.isIndoorEnabled = false
        mapView.delegate = self
        mapView.settings.myLocationButton = false
        
        // Add the map to the view, hide it until got a location update.
        view = mapView
        mapView.isHidden = true
        
        view.addSubview(searchButton)
        view.addSubview(predictSearchButton)
        view.addSubview(refreshButton)
        
        // Setting of refresh button
        refreshButton.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width : 100, height: 40))
            make.centerX.equalTo(view)
            make.bottom.equalTo(view).offset(-30)
        }
        
        // Setting of search button
        searchButton.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width : 100, height: 40))
            make.right.equalTo(refreshButton.snp.left).offset(-5)
            make.bottom.equalTo(view).offset(-30)
        }
        
        // Setting of predict search button
        predictSearchButton.snp.makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width : 100, height: 40))
            make.left.equalTo(refreshButton.snp.right).offset(5)
            make.bottom.equalTo(view).offset(-30)
        }
        
        // Get paring list from server
        getParkingList()
    }
    
    // Present the Autocomplete view controller when the button is pressed.
    @objc func searchButtonClicked() {
        let acController = GMSAutocompleteViewController()
        acController.view.tag = 888
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    // Present the Autocomplete view controller when the button is pressed.
    @objc func predictSearchButtonClicked() {
        let acController = GMSAutocompleteViewController()
        acController.view.tag = 999
        acController.delegate = self
        present(acController, animated: true, completion: nil)
    }
    
    // Refresh data when the refresh button is pressed.
    @objc func refreshButtonClicked() {
        getParkingList()
    }
    
    // Lazy create search button
    private lazy var searchButton : UIButton = {
        let button:UIButton = UIButton(type: .custom)
        button.setTitle("Search", for: UIControlState.normal)
        button.setBackgroundImage(UIImage(named:"button.png"), for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self,action:#selector(PKRealTimeViewController.searchButtonClicked),for:.touchUpInside)
        return button
    }()
    
    // Lazy create predict search button
    private lazy var predictSearchButton : UIButton = {
        let button:UIButton = UIButton(type: .custom)
        button.setTitle("Recommend", for: UIControlState.normal)
        button.setBackgroundImage(UIImage(named:"button.png"), for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self,action:#selector(PKRealTimeViewController.predictSearchButtonClicked),for:.touchUpInside)
        return button
    }()
    
    // Lazy create refresh button
    private lazy var refreshButton : UIButton = {
        let button:UIButton = UIButton(type: .custom)
        button.setTitle("Refresh", for: UIControlState.normal)
        button.setBackgroundImage(UIImage(named:"button.png"), for: UIControlState.normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        button.addTarget(self,action:#selector(PKRealTimeViewController.refreshButtonClicked),for:.touchUpInside)
        return button
    }()
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Get distance between two locations
    func getDistance(location1: CLLocation, location2: CLLocation) -> CLLocationDistance
    {
        let distance : CLLocationDistance = location1.distance(from: location2)
    
        return distance
    }
    
    // Get parking list from server
    func getParkingList()
    {
        self.view.showHudInView(view: view)
        NetworkTool.sharedTools.getParkingList { (parkingList, error) in
            self.view.hideHud()
            if error == nil {
                self.mapView.clear()
                
                self.parkingList = parkingList
                
                let blueMarkerView = UIImageView(image: UIImage(named: "blue.png"))
                let redMarkerView = UIImageView(image: UIImage(named: "red.png"))
                
                for dict in self.parkingList! {
                    let parkCoordinate = CLLocationCoordinate2D(latitude: dict.lat, longitude: dict.lon)
                    
                    if self.mapView.projection.contains(parkCoordinate) {
                        let marker = GMSMarker()
                        if (dict.status! as NSString).isEqual(to: "Unoccupied") {
                            marker.iconView = blueMarkerView
                        }
                        else {
                            marker.iconView = redMarkerView
                        }
                        marker.position = parkCoordinate
                        marker.title = dict.st_marker_id
                        marker.map = self.mapView
                    }
                }
                
            }else{
                self.view.showTextHud(content: "Network Error")
            }
        }
    }
    
    // Get recommended parking bays
    func getSuggestBays(parameters: [String : Any])
    {
        self.view.showHudInView(view: view)
        NetworkTool.sharedTools.getSuggestBays(parameters: parameters) { (suggestBaysData, error) in
            self.view.hideHud()
            if error == nil {
                self.mapView.clear()
                
                let streetMarkerIDList = suggestBaysData!["sortedstreetmarkers"]
                var haveAnimateToBay: Bool = false
                let blueMarkerView = UIImageView(image: UIImage(named: "blue.png"))
                let redMarkerView = UIImageView(image: UIImage(named: "red.png"))
                
                for (_, streetMarkerID) : (String, JSON) in streetMarkerIDList{
                    for dict in self.parkingList! {
                        if dict.st_marker_id == streetMarkerID.stringValue {
                            let parkCoordinate = CLLocationCoordinate2D(latitude: dict.lat, longitude: dict.lon)

                            if !haveAnimateToBay {
                                self.mapView.animate(toLocation:parkCoordinate)
                                haveAnimateToBay = true
                            }
                            
                            let marker = GMSMarker()
                            if (dict.status! as NSString).isEqual(to: "Unoccupied") {
                                marker.iconView = blueMarkerView
                            }
                            else {
                                marker.iconView = redMarkerView
                            }
                            marker.position = parkCoordinate
                            marker.title = dict.st_marker_id
                            marker.map = self.mapView
                            break
                        }
                    }
                }
            }else{
                self.view.showTextHud(content: "Network Error")
            }
        }
    }
    
    // Get during between two locations
    func getDuringData(location1: CLLocation, location2: CLLocation)
    {
        self.view.showHudInView(view: view)
        NetworkTool.sharedTools.getDuringData(location1 : location1, location2 : location2) { (result, error) in
            self.view.hideHud()
            if error == nil {
                for (_, row) : (String, JSON) in result!["rows"] {
                    for (_, element) : (String, JSON) in row["elements"] {
                        let status = element["status"].stringValue
                        
                        if status == "OK" {
                            let durationValue: Int = element["duration"]["value"].intValue
                            
                            let hour: Int = durationValue / 3600
                            let minute: Int = (durationValue % 3600) / 60
                            
                            let nearbyBayListdata : NSData! = try! JSONSerialization.data(withJSONObject: self.nearByBayList!, options: []) as NSData?
                            let nearbyBaysString = NSString(data:nearbyBayListdata as Data,encoding: String.Encoding.utf8.rawValue)

                            let parameters = ["baylist": nearbyBaysString! as Any, "period_h": hour, "period_m": minute] as [String : Any]
                            
                            self.getSuggestBays(parameters: parameters)
                        }
                        else {
                            self.view.showTextHud(content: status)
                        }
                    }
                }
            }else{
                self.view.showTextHud(content: "Network Error")
            }
        }
    }
}

// Delegates to handle events for the location manager.
extension PKRealTimeViewController: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        self.currentLocation = location
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        
        if mapView.isHidden {
            mapView.isHidden = false
            mapView.camera = camera
            mapView.animate(to: camera)
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
            // Display the map using the default location.
            mapView.isHidden = false
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        print("Error: \(error)")
    }
}

extension PKRealTimeViewController: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        // Normal search 888
        // Predict search 999
        if viewController.view.tag == 888 {
            self.dismiss(animated: false, completion: nil)
            DispatchQueue.main.async(execute: {
                self.mapView.animate(toLocation:place.coordinate)
            })
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.0) {
                self.getParkingList()
            }
        }
        else {
            self.dismiss(animated: false, completion: nil)
            DispatchQueue.main.async(execute: {
                self.mapView.animate(toLocation:place.coordinate)
            })
            
            let placeLocation = CLLocation(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
            
            // Get nearby bay list <= 500m
            self.nearByBayList = [String]()
            for dict in self.parkingList! {
                let bayLocation = CLLocation(latitude: dict.lat, longitude: dict.lon)
                let distance = self.getDistance(location1: placeLocation, location2: bayLocation)
                
                if distance <= 500 {
                    self.nearByBayList?.append(dict.st_marker_id!)
                }
            }
            
            self.getDuringData(location1: self.currentLocation!, location2: placeLocation)
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        // TODO: handle the error.
        print("Error: \(error)")
        dismiss(animated: true, completion: nil)
    }
    
    // User cancelled the operation.
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("Autocomplete was cancelled.")
        dismiss(animated: true, completion: nil)
    }
}

extension PKRealTimeViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        var parkingInfo: RealTimeParkingInfo?
        
        for dict in self.parkingList! {
            if marker.title == dict.st_marker_id {
                parkingInfo = dict
                break
            }
        }
        
        let bayDetailViewController = PKBayDetailViewController()
        bayDetailViewController.parkingInfo = parkingInfo
        let nav =  UINavigationController(rootViewController: bayDetailViewController)
        present(nav, animated: true, completion: nil)
    }
}
