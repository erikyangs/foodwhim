//
//  SearchViewController.swift
//  foodwhim
//
//  Created by Erik Yang on 4/26/17.
//  Copyright © 2017 Erik Yang. All rights reserved.
//

import UIKit
import Foundation
import YelpAPI
import CoreLocation

class ResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate {
    //FIELDS
    var yelpClient: YLPClient!
    let locationManager = CLLocationManager()
    var searchLocation: (latitude: Double, longitude: Double) = defaultCoordinate
    var businessInfo = [[String]]()
    @IBOutlet weak var restaurantNameUILabel: UILabel!
    @IBOutlet weak var infoTableView: UITableView!
    @IBOutlet weak var headerBackgroundUIImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        infoTableView.delegate = self
        infoTableView.dataSource = self
        infoTableView.rowHeight = UITableViewAutomaticDimension
        infoTableView.estimatedRowHeight = 50
        infoTableView.contentInset = UIEdgeInsetsMake(20, 0, 10, 0)
        infoTableView.tableFooterView = UIView()
        infoTableView.separatorStyle = .none
        infoTableView.reloadData()
        
        //LOCATION
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }
    
    //LOCATION
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0]
        let lat = userLocation.coordinate.latitude;
        let long = userLocation.coordinate.longitude;
        searchLocation = (lat, long)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        infoTableView.reloadData()
        
        search()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    
    /* Considers (ideas):
     What is open
     Price point
     Time of day/meal
     Number of Reviews
     Distance
     */
    func search()->Void{
        updateRestaurantNameUILabel(name: "Searching for food...")
        businessInfo = []
        infoTableView.reloadData()
        
        let queryCoordinate = YLPCoordinate(latitude: searchLocation.latitude, longitude: searchLocation.longitude)
        let query = YLPQuery(coordinate: queryCoordinate)
        query.limit = 50
        query.radiusFilter = 300
        query.term = "Food"
        
        self.yelpClient.search(with: query, completionHandler: {(search: YLPSearch?, error: Error?) -> Void in
            if(error == nil){
                print("Search success")
                let randomBusinessId = randomArrayId(input: search!.businesses.count)
                print("Number of businesses found: ", search!.businesses.count)
                let business = search!.businesses[randomBusinessId]
                print(business.name)
                self.updateRestaurantNameUILabel(name: business.name)
                
                if let businessImageUrl = business.imageURL {
                    downloadImage(imageView: self.headerBackgroundUIImageView, url: businessImageUrl)
                }
                else{
                    DispatchQueue.main.async {
                        self.headerBackgroundUIImageView.image = UIImage(named: "Wood")
                    }
                }
                
                if (business.location.address.count > 0){
                    if let lat=business.location.coordinate?.latitude, let lon=business.location.coordinate?.longitude{
                        let businessAddress = business.location.address[0] + ", " + business.location.city + ", " + business.location.stateCode + ", " + business.location.postalCode
                        print(businessAddress)
                        self.businessInfo.append(["heading", "Address"])
                        self.businessInfo.append(["content", "address", String(lat), String(lon), businessAddress])
                        self.businessInfo.append(["padding"])
                    }
                }
                
                if let tempPhoneVar = business.phone{
                    let businessPhone = tempPhoneVar.replacingOccurrences(of: "+", with: "")
                    print(businessPhone)
                    self.businessInfo.append(["heading", "Phone Number"])
                    self.businessInfo.append(["content", "phone", businessPhone])
                    self.businessInfo.append(["padding"])
                }
                
                DispatchQueue.main.async {
                    self.infoTableView.reloadData()
                }
                
                print("Search complete")
            }
            else{
                let msg = String(describing: error!.localizedDescription)
                print("Error: ", msg)
                showAlert(viewController: self, alertTitle: "Error", alertMessage: msg, alertButtonText: "OK")
            }
        })
    }
    
    func updateRestaurantNameUILabel(name: String){
        DispatchQueue.main.async {
            self.restaurantNameUILabel.text = name
        }
    }
    
    //TABLE VIEW
    //address, phone number, open hours, suggested food
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return businessInfo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellInfo = businessInfo[indexPath.row]
        if(cellInfo[0] == "heading"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "headingTableViewCell",
                                                  for: indexPath) as! HeadingTableViewCell
            cell.headingUILabel.text = cellInfo[cellInfo.count - 1]
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else if(cellInfo[0] == "content"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "contentTableViewCell",
                                                     for: indexPath) as! ContentTableViewCell
            cell.contentUILabel.text = cellInfo[cellInfo.count - 1]
            //cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else{ //if(cellInfo[0] == "padding"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "paddingTableViewCell",
                                          for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellInfo = businessInfo[indexPath.row]
        if(cellInfo.count>2){
            if(cellInfo[1] == "address"){
                let coordinate = (cellInfo[2], cellInfo[3])
                let name = restaurantNameUILabel.text!
                showMapsAlert(viewController: self, alertTitle: "Get Directions to \(name)", alertMessage: "", query: name, coordinate: coordinate)
            }
            else if(cellInfo[1] == "phone"){
                print("Calling phone number: ", cellInfo[2])
                callNumber(phoneNumber: cellInfo[2])
            }
        }
    }
    
    @IBAction func newEntryButtonPressed(_ sender: UIButton) {
        search()
    }
}
