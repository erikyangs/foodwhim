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

class ResultViewController: UIViewController {
    //FIELDS
    var yelpClient: YLPClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        search()
    }
    
    func search()->Void{
        self.yelpClient.search(withLocation: "Berkeley, CA", completionHandler: {(search: YLPSearch?, error: Error?) -> Void in
            print("Search complete")
            let randomBusinessId = randomArrayId(input: search!.businesses.count)
            print(search!.businesses[randomBusinessId].name)
        })
    }
}
