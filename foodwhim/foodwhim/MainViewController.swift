//
//  ViewController.swift
//  foodwhim
//
//  Created by Erik Yang on 3/21/17.
//  Copyright © 2017 Erik Yang. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Loaded MainViewController")
        
        //BLACK TRANSPARENCY LAYER
        // get your window screen size
        let screenSize: CGRect = UIScreen.main.bounds
        //create a new view with the same size
        let overlay: UIView = UIView(frame: CGRect(x:0, y:0, width:screenSize.width, height:screenSize.height))
        // change the background color to black and the opacity to 0.6
        overlay.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.5)
        // add this new view to your main view
        self.view.addSubview(overlay)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

