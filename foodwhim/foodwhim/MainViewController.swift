//
//  ViewController.swift
//  foodwhim
//
//  Created by Erik Yang on 3/21/17.
//  Copyright © 2017 Erik Yang. All rights reserved.
//

import UIKit
import QuartzCore
import AVFoundation
import YelpAPI

class MainViewController: UIViewController {
    //FIELDS
    let appId = "lQwRGkdMNvY6e_Zo1RSDVQ"
    let appSecret = "HcCAjvHOhKIpSt0yh5qGh8zeAMpK6dTwKMFYWRVoeEvXwG25AOD4Gs31oHoNJJP8"
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var isYelpClientReady:Bool = false
    var yelpClient: YLPClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        print("Loaded MainViewController")
        
        setupBackgroundVideo()
        
        //GREETING TEXT
        let greeting = self.view.viewWithTag(1) as! UILabel
        var greetingList = ["Welcome Back.", "Hungry?", "Be Decisive Today.", "Welcome to FoodWhim.", "Satisfy Your Cravings."]
        let greetingListRandomIndex = randomArrayId(input: greetingList.count)
        greeting.text = greetingList[greetingListRandomIndex]
        
        //YELP FUSION API
        YLPClient.authorize(withAppId: appId, secret: appSecret,
                            completionHandler: {(client: YLPClient?, error: Error?) -> Void in
                                self.yelpClient = client!
                                self.isYelpClientReady = true
                                print("Yelp API authorized for app")
                            })
    }
    
    func setupBackgroundVideo(){
        // Find UIImageView background (used in place of background video if it doesn't work)
        let background = self.view.viewWithTag(-1) //tag set to -1 in storyboard
        
        //BLACK TRANSPARENCY LAYER
        // get your window screen size
        let screenSize: CGRect = UIScreen.main.bounds
        //create a new view with the same size
        let overlay: UIView = UIView(frame: CGRect(x:0, y:0, width:screenSize.width, height:screenSize.height))
        // change the background color to black and the opacity to 0.6
        overlay.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.7)
        // add this new view to your main view
        self.view.addSubview(overlay)
        self.view.insertSubview(overlay, aboveSubview: background!)
        
        //VIDEO LAYER
        //Credits to: (http://stackoverflow.com/questions/32888378/adding-a-video-background-to-ios-app-signup-like-instagram-and-vine)
        let vidURL = Bundle.main.url(forResource:"Food", withExtension: "mp4")
        avPlayer = AVPlayer(url: vidURL!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        avPlayerLayer.frame = view.layer.bounds
        self.view.layer.insertSublayer(avPlayerLayer, above: background?.layer)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                               object: avPlayer.currentItem)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //if background video goes to beginning, loop
    func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.play()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        avPlayer.pause()
    }
    
    //random array id helper method
    func randomArrayId(input: Int) -> Int{
        return Int(arc4random_uniform(UInt32(input)))
    }
    
    //SUGGEST BUTTON PRESS
    @IBAction func pressedSuggestButton(_ sender: UIButton) {
        if(isYelpClientReady){
            self.yelpClient.search(withLocation: "Berkeley, CA", completionHandler: {(search: YLPSearch?, error: Error?) -> Void in
                print("Search complete")
                let randomBusinessId = self.randomArrayId(input: search!.businesses.count)
                print(search!.businesses[randomBusinessId].name)
                //segue needs fixing
                self.performSegue(withIdentifier: "segueToResult", sender: nil)
            })
        }
    }
}

