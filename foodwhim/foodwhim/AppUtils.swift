//
//  AppUtils.swift
//  foodwhim
//
//  Created by Erik Yang on 4/26/17.
//  Copyright © 2017 Erik Yang. All rights reserved.
//

import Foundation
import UIKit

//random array id helper method
func randomArrayId(input: Int) -> Int{
    return Int(arc4random_uniform(UInt32(input)))
}

//ALERT WINDOW
func showAlert(viewController: UIViewController, alertTitle: String, alertMessage: String, alertButtonText: String){
    let alertController = UIAlertController(title: alertTitle, message:
        alertMessage, preferredStyle: UIAlertControllerStyle.alert)
    alertController.addAction(UIAlertAction(title: alertButtonText, style: UIAlertActionStyle.default,handler: nil))
    
    viewController.present(alertController, animated: true, completion: nil)
}
