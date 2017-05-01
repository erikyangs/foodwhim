//
//  SettingsViewController.swift
//  foodwhim
//
//  Created by Erik Yang on 5/1/17.
//  Copyright © 2017 Erik Yang. All rights reserved.
//

import UIKit
import Foundation
import YelpAPI

/*
 Set the following:
 Search radius
 Search term
 */
class SettingsViewController: UIViewController{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //NotificationCenter.default.addObserver(self, selector:#selector(SettingsViewController.viewWillEnterForeground), name:NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        updateDistanceSettingButtons()
        searchTermUITextField.text = currentSearchTermSetting
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
        updateDistanceSettingButtons()
        searchTermUITextField.text = currentSearchTermSetting
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.statusBarStyle = UIStatusBarStyle.default
    }
    
    //Search Distance Settings
    @IBOutlet weak var walkingUIButton: UIButton!
    @IBOutlet weak var bikingUIButton: UIButton!
    @IBOutlet weak var drivingUIButton: UIButton!
    
    func updateDistanceSettingButtons() -> Void{
        deselectDistanceButtonStyle(button: walkingUIButton)
        deselectDistanceButtonStyle(button: bikingUIButton)
        deselectDistanceButtonStyle(button: drivingUIButton)
        if(currentSearchDistanceSetting == walkingSetting){
            selectDistanceButtonStyle(button: walkingUIButton)
        }
        else if(currentSearchDistanceSetting == bikingSetting){
            selectDistanceButtonStyle(button: bikingUIButton)
        }
        else if(currentSearchDistanceSetting == drivingSetting){
            selectDistanceButtonStyle(button: drivingUIButton)
        }
    }
    
    @IBAction func walkingUIButtonPressed(_ sender: UIButton) {
        currentSearchDistanceSetting = walkingSetting
        updateDistanceSettingButtons()
        searchTermUITextField.endEditing(true)
    }
    @IBAction func bikingUIButtonPressed(_ sender: UIButton) {
        currentSearchDistanceSetting = bikingSetting
        updateDistanceSettingButtons()
        searchTermUITextField.endEditing(true)
    }
    @IBAction func drivingUIButtonPressed(_ sender: UIButton) {
        currentSearchDistanceSetting = drivingSetting
        updateDistanceSettingButtons()
        searchTermUITextField.endEditing(true)
    }
    
    private func deselectDistanceButtonStyle(button: UIButton){
        button.backgroundColor = UIColor(red: 216/255, green: 27/255, blue: 96/255, alpha: 1)
    }
    private func selectDistanceButtonStyle(button:UIButton){
        button.backgroundColor = UIColor(red: 189/255, green: 189/255, blue: 189/255, alpha: 1)
    }
    
    //Search Term
    @IBOutlet weak var searchTermUITextField: UITextField!
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        searchTermUITextField.endEditing(true)
    }
    
    //SAVE SETTINGS
    @IBAction func saveSettingsUIButtonPressed(_ sender: UIButton) {
        print("Saving settings, unwinding segue...")
        searchTermUITextField.endEditing(true)
        
        if(searchTermUITextField.text != nil && searchTermUITextField.text != ""){
            currentSearchTermSetting = searchTermUITextField.text!
        }
        
        performSegue(withIdentifier: "unwindToResultSegue", sender: nil)
    }
}

