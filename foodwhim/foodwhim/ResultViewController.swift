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

class ResultViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //FIELDS
    var yelpClient: YLPClient!
    @IBOutlet weak var restaurantNameUILabel: UILabel!
    @IBOutlet weak var infoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        infoTableView.delegate = self
        infoTableView.dataSource = self
        infoTableView.rowHeight = UITableViewAutomaticDimension
        infoTableView.estimatedRowHeight = 50
        infoTableView.contentInset = UIEdgeInsetsMake(10, 0, 10, 0)
        infoTableView.tableFooterView = UIView()
        infoTableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        infoTableView.reloadData()
        search(queryLocation: "2400 Durant Ave., Berkeley, CA")
    }
    
    
    /* Considers:
     What is open
     Price point
     Time of day/meal
     Number of Reviews
     Distance
     */
    func search(queryLocation: String)->Void{
        updateRestaurantNameUILabel(name: "Searching for food...")
        let query = YLPQuery(location: queryLocation)
        self.yelpClient.search(with: query, completionHandler: {(search: YLPSearch?, error: Error?) -> Void in
            if(error == nil){
                print("Search complete")
                let randomBusinessId = randomArrayId(input: search!.businesses.count)
                let business = search!.businesses[randomBusinessId]
                print(business.name)
                self.updateRestaurantNameUILabel(name: business.name)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contentTableViewCell",
                                                 for: indexPath)
        //cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    @IBAction func newEntryButtonPressed(_ sender: UIButton) {
        search(queryLocation: "2400 Durant Ave., Berkeley, CA")
    }
}
