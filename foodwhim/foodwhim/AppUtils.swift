//
//  AppUtils.swift
//  foodwhim
//
//  Created by Erik Yang on 4/26/17.
//  Copyright © 2017 Erik Yang. All rights reserved.
//

import Foundation
import UIKit

//FIELDS
let defaultCoordinate: (latitude: Double, longitude: Double) = (37.773249, -122.418923)

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

func showMapsAlert(viewController: UIViewController, alertTitle: String, alertMessage: String, query:String="", coordinate:(String, String)){
    let alertController = UIAlertController(title: alertTitle, message:
        alertMessage, preferredStyle: UIAlertControllerStyle.alert)
    alertController.addAction(UIAlertAction(title: "Open in Google Maps", style: UIAlertActionStyle.default,
                                            handler: {action in
                                                print("Selected Google Maps")
                                                openAddressInGoogleMaps(query:query, coordinate: coordinate)
                                            }))
    alertController.addAction(UIAlertAction(title: "Open in Maps", style: UIAlertActionStyle.default,
                                            handler: {action in
                                                print("Selected Apple Maps")
                                                openAddressInAppleMaps(query:query, coordinate: coordinate)
                                            }))
    alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel,handler: nil))
    
    viewController.present(alertController, animated: true, completion: nil)
}

//OPENING EXTERNAL APPS
func callNumber(phoneNumber:String) {
    if let phoneCallURL = URL(string: "telprompt://\(phoneNumber)") {
        openURL(url: phoneCallURL)
    }
}

func openAddressInGoogleMaps(query:String="", coordinate:(String, String)){
    let formattedQuery = query.replacingOccurrences(of: " ", with: "%20").folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: nil)
    if let addressURL = URL(string: "comgooglemaps://?q=\(formattedQuery)&center=\(coordinate.0),\(coordinate.1)"){
        openURL(url: addressURL)
    }
}

func openAddressInAppleMaps(query:String="", coordinate:(String, String)){
    let formattedQuery = query.replacingOccurrences(of: " ", with: "+").folding(options: [.diacriticInsensitive, .widthInsensitive, .caseInsensitive], locale: nil)
    if let addressURL = URL(string: "http://maps.apple.com/?q=\(formattedQuery)&sll=\(coordinate.0),\(coordinate.1)&z=10"){
        openURL(url: addressURL)
    }
}

func openURL(url: URL){
    let application:UIApplication = UIApplication.shared
    if (application.canOpenURL(url)) {
        application.open(url, options: [:], completionHandler: nil)
    }
    else{
        print("Cannot open URL")
    }
}

//DOWNLOADING IMAGES
func getDataFromUrl(url: URL, completion: @escaping (_ data: Data?, _  response: URLResponse?, _ error: Error?) -> Void) {
    URLSession.shared.dataTask(with: url) {
        (data, response, error) in
        completion(data, response, error)
        }.resume()
}

func downloadImage(imageView: UIImageView, url: URL) {
    print("Downloading Image: ", url)
    getDataFromUrl(url: url) { (data, response, error)  in
        guard let data = data, error == nil else { return }
        print(response?.suggestedFilename ?? url.lastPathComponent)
        DispatchQueue.main.async() { () -> Void in
            imageView.image = UIImage(data: data)
        }
    }
}
