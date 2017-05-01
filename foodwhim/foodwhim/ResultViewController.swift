//
//  SearchViewController.swift
//  foodwhim
//
//  Created by Erik Yang on 4/26/17.
//  Copyright © 2017 Erik Yang. All rights reserved.
//
/*
 TODO:
 Search Considers:
    What is open
    Price point
    Time of day/meal
    Number of Reviews
    Distance
 URL link to actual review
 Format Phone Number
 Pictures
 Preferences/Settings
 Price
 */

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
        
        disableNewEntryButton()
        
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
    
    //SEARCH
    func search()->Void{
        updateRestaurantNameUILabel(name: "Searching for food...")
        businessInfo = []
        infoTableView.reloadData()
        
        let queryCoordinate = YLPCoordinate(latitude: searchLocation.latitude, longitude: searchLocation.longitude)
        let query = YLPQuery(coordinate: queryCoordinate)
        query.limit = 50
        query.radiusFilter = currentSearchDistanceSetting
        query.term = currentSearchTermSetting
        
        self.yelpClient.search(with: query, completionHandler: {(search: YLPSearch?, error: Error?) -> Void in
            if(error == nil){
                print("Search success")
                
                //No business found for query
                if (search!.businesses.count == 0){
                    self.updateRestaurantNameUILabel(name: "No Businesses Found with Current Settings")
                    self.headerBackgroundUIImageView.image = UIImage(named: "Wood")
                    self.enableNewEntryButton()
                    return
                }
                
                let randomBusinessId = randomArrayId(input: search!.businesses.count)
                print("Number of businesses found: ", search!.businesses.count)
                let business = search!.businesses[randomBusinessId]
                
                //BUSINESS NAME
                print(business.name)
                self.updateRestaurantNameUILabel(name: business.name)
                
                //BG IMAGE
                if let businessImageUrl = business.imageURL {
                    downloadImage(imageView: self.headerBackgroundUIImageView, url: businessImageUrl)
                }
                else{
                    DispatchQueue.main.async {
                        self.headerBackgroundUIImageView.image = UIImage(named: "Wood")
                    }
                }
                
                //OVERALL REVIEWS
                self.businessInfo.append(["heading", "Rating"])
                self.businessInfo.append(["total-reviews", String(business.rating), String(business.reviewCount)])
                self.businessInfo.append(["padding-sm"])
                
                //ADDRESS
                if (business.location.address.count > 0){
                    if let lat=business.location.coordinate?.latitude, let lon=business.location.coordinate?.longitude{
                        let businessAddress = business.location.address[0] + ", " + business.location.city + ", " + business.location.stateCode + ", " + business.location.postalCode
                        print(businessAddress)
                        self.businessInfo.append(["heading", "Address"])
                        self.businessInfo.append(["content", "address", String(lat), String(lon), businessAddress])
                        self.businessInfo.append(["padding"])
                    }
                }
                
                //PHONE
                if let tempPhoneVar = business.phone{
                    let businessPhone = tempPhoneVar.replacingOccurrences(of: "+", with: "")
                    print(businessPhone)
                    self.businessInfo.append(["heading", "Phone Number"])
                    self.businessInfo.append(["content", "phone", businessPhone])
                    self.businessInfo.append(["padding"])
                }
                    
                //SEARCH FOR INDIVIDUAL REVIEWS
                self.searchReviews(business: business)
                
                //RELOAD TABLE DATA
                DispatchQueue.main.async {
                    self.infoTableView.reloadData()
                    //self.enableNewEntryButton()
                }
                
                print("Search complete")
            }
            else{
                let msg = String(describing: error!.localizedDescription)
                print("Error: ", msg)
                showAlert(viewController: self, alertTitle: "Error", alertMessage: msg, alertButtonText: "OK")
                DispatchQueue.main.async {
                    self.enableNewEntryButton()
                }
            }
        })
    }
    
    func searchBusiness(business: YLPBusiness)->Void{
        self.yelpClient.business(withId: business.identifier, completionHandler: {(yelpBusiness:YLPBusiness?, error:Error?) -> Void in
            if(error == nil){
                if let imgURL = yelpBusiness?.imageURL?.absoluteString{
                    self.businessInfo.append(["heading", "Selected Photos"])
                    self.businessInfo.append(["image", imgURL])
                    self.businessInfo.append(["padding"])
                }
                
                //RELOAD TABLE DATA
                DispatchQueue.main.async {
                    self.infoTableView.reloadData()
                    self.enableNewEntryButton()
                }
            }
            else{
                let msg = String(describing: error!.localizedDescription)
                print("Error: ", msg)
                showAlert(viewController: self, alertTitle: "Error", alertMessage: msg, alertButtonText: "OK")
                DispatchQueue.main.async {
                    self.enableNewEntryButton()
                }
            }
        })
    }
    
    func searchReviews(business: YLPBusiness)->Void{
        //REVIEWS
        self.yelpClient.reviewsForBusiness(withId: business.identifier, completionHandler: {(yelpReviews: YLPBusinessReviews?, error:Error?) -> Void in
            if(error == nil){
                self.businessInfo.append(["heading", "Selected Reviews"])
                let reviews = yelpReviews?.reviews
                for review in reviews!{
                    if let imgURL = review.user.imageURL?.absoluteString{
                        self.businessInfo.append(["review", imgURL, review.user.name, String(review.rating), review.excerpt])
                    }
                    else{
                        self.businessInfo.append(["review", review.user.name, String(review.rating), review.excerpt])
                    }
                }
                self.businessInfo.append(["padding-sm"])
                
                //SEARCH WITH YELP BUSINESS API
                self.searchBusiness(business: business)
                
                //RELOAD TABLE DATA
                DispatchQueue.main.async {
                    self.infoTableView.reloadData()
                    //self.enableNewEntryButton()
                }
            }
            else{
                let msg = String(describing: error!.localizedDescription)
                print("Error: ", msg)
                showAlert(viewController: self, alertTitle: "Error", alertMessage: msg, alertButtonText: "OK")
                DispatchQueue.main.async {
                    self.enableNewEntryButton()
                }
            }
        })
    }
    
    func updateRestaurantNameUILabel(name: String){
        DispatchQueue.main.async {
            self.restaurantNameUILabel.text = name
        }
    }
    
    //Convert double to appropriate rating image
    func doubleToRatingImage(rating: Double) -> UIImage{
        if(rating==0){
            return UIImage(named: "0stars")!
        }
        else if (rating==0.5){
            return UIImage(named: "0-5stars")!
        }
        else if (rating==1){
            return UIImage(named: "1stars")!
        }
        else if (rating==1.5){
            return UIImage(named: "1-5stars")!
        }
        else if (rating==2){
            return UIImage(named: "2stars")!
        }
        else if (rating==2.5){
            return UIImage(named: "2-5stars")!
        }
        else if (rating==3){
            return UIImage(named: "3stars")!
        }
        else if (rating==3.5){
            return UIImage(named: "3-5stars")!
        }
        else if (rating==4){
            return UIImage(named: "4stars")!
        }
        else if (rating==4.5){
            return UIImage(named: "4-5stars")!
        }
        else if (rating==5){
            return UIImage(named: "5stars")!
        }
        else{
            return UIImage(named: "emptystars")!
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
        else if(cellInfo[0] == "review"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "reviewTableViewCell",
                                                     for: indexPath) as! ReviewTableViewCell
            cell.contentUILabel.text = cellInfo[cellInfo.count - 1]
            cell.ratingUIImageView.image = doubleToRatingImage(rating: Double(cellInfo[cellInfo.count-2])!)
            cell.userNameUILabel.text = cellInfo[cellInfo.count - 3]
            //userImage
            if(cellInfo.count > 4){
                cell.userUIImageView.layer.cornerRadius = cell.userUIImageView.frame.size.width/2
                downloadImage(imageView: cell.userUIImageView, url: URL(string: cellInfo[1])!)
            }
            
            //cell.layer.borderWidth = 1.0
            //cell.layer.borderColor = UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1).cgColor
            //cell.contentView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else if(cellInfo[0] == "total-reviews"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "totalReviewsTableViewCell",
                                                     for: indexPath) as! TotalReviewsTableViewCell
            cell.numReviewsUILabel.text = cellInfo[cellInfo.count-1] + " Reviews"
            cell.ratingUIImageView.image = doubleToRatingImage(rating: Double(cellInfo[cellInfo.count-2])!)
            
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else if (cellInfo[0] == "image"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageTableViewCell",
                                                     for: indexPath) as! ImageTableViewCell
            downloadImage(imageView: cell.firstUIImage, url: URL(string: cellInfo[1])!)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            return cell
        }
        else if(cellInfo[0] == "padding-sm"){
            let cell = tableView.dequeueReusableCell(withIdentifier: "paddingsmTableViewCell",
                                                     for: indexPath)
            cell.selectionStyle = UITableViewCellSelectionStyle.none
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
    
    //NEW SEARCH BUTTON
    @IBAction func newEntryButtonPressed(_ sender: UIButton) {
        disableNewEntryButton()
        search()
    }
    
    @IBOutlet weak var newEntryButton: UIButton!
    func enableNewEntryButton()->Void{
        newEntryButton.isEnabled = true
        let textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        newEntryButton.setTitleColor(textColor, for: UIControlState.normal)
    }
    func disableNewEntryButton()->Void{
        newEntryButton.isEnabled = false
        let textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.3)
        newEntryButton.setTitleColor(textColor, for: UIControlState.normal)
    }
    
    //SETTINGS BUTTON
    @IBAction func settingsButtonPressed(_ sender: UIButton) {
        updateRestaurantNameUILabel(name: "Searching for food...")
        businessInfo = []
        infoTableView.reloadData()
        self.performSegue(withIdentifier: "segueToSettings", sender: nil)
    }
    
    //UNWIND SEGUE
    @IBAction func unwindToResult(segue: UIStoryboardSegue){
    }
}
