//
//  InfoViewController.swift
//  TWalks
//
//  Created by Cliff Mitchell on 02/03/2017.
//  Copyright © 2017 Cliff Mitchell. All rights reserved.
//

import UIKit

class InfoViewController: UIViewController {

    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var howMuchButton: UIButton!
    @IBOutlet weak var usingAppButton: UIButton!
    @IBOutlet weak var gettingUpdatesButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        infoTextView.text = "What do you want to know?\n Tap one of the buttons above..."
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    @IBAction func howMuchButtonTapped(_ sender: Any) {
        var fullText:String = "Nothing - it's FREE!\n\nThe TWalks app is FREE to download and FREE to use on a walk. "
        fullText += "The first time you view a route you need an active internet connection so the route can be downloaded to the app. This requires a mobile data connection or a wifi connection for which normal charges (if any) apply. The route is saved on your phone so next time you view that route NO internet connection is required and NO charges are incurred."
        fullText += "\n\nWhen you use the MAP option in TWalks you can follow your position on the map as you move between the route's waymarkers. This uses your devices GPS/Location Services functionality which is completely FREE to use - it does not incur any network or wifi charges."
        
        infoTextView.text = fullText
        
        setActiveButton(selectedButton: howMuchButton)

        
    }
    
    @IBAction func usingAppButtonTapped(_ sender: Any) {
        var fullText:String = "Is easy!\n\nFirst you select (tap) a route from the Route List. This shows you the full route details, broken down into a number of sections.\n\nSections View\nThe first page is an overview of the route. "
        fullText += "Swipe up or down to scroll through the text. You can enlarge any image by tapping once on the image to go to the Image Pan/Zoom screen where you can pinch to zoom and drag to move around the image. Swipe left to move to the next section of the route and swipe right to move back. The red (current section) and blue dots at the bottom of the screen show where you are in the sections. "
        fullText += "Tap the 'i' (Info) icon at the top right of the screen to view these information pages. "
        fullText += "\n\nMap view\nTapping the 'Map' button at the bottom left of the screen takes you to Apple Maps showing a map of the route shown as a series of blue waymarkers connected by a blue line. The first time you use the map view you will be asked to confirm that TWalks can 'access your location'. If you 'Allow' this your actual location will be shown on the map as a pulsing blue circle so you can SEE WHERE YOU ARE relative to the waymarkers. If you 'Don't Allow' location services you can still follow the waymarkers on the map but your actual location will NOT be shown. "
        fullText += "You can drag to scroll around the Map View and pinch to zoom in and out. You can also select between the basic Map view, a Satellite view and a combination Hybrid view by tapping the buttons at the top of the map. "
        
        infoTextView.text = fullText
        
        setActiveButton(selectedButton: usingAppButton)
    }
    
    @IBAction func gettingUpdatesButtonTapped(_ sender: Any) {
        var fullText:String = "You don't need to do anything!\n\nAny updates to the list of routes, or to individual route details, will be downloaded automatically when they become available. "
        fullText += "\n\nThe first time you use this app you need an active internet connection so the list of routes can be downloaded. Once downloaded the route list is saved in the app and will only be downloaded again if an updated version becomes available."
        fullText += "\n\nWhen you select a route from the list the app will download the full route details and save them on your device (iPhone/iPad) - this requires an active internet connection."
        fullText += "\n\nEach time you then select a route the app will use the version saved on your device so no internet conncection is required. If there is an active internet connection the app will check to see if there is an updated version available. Updated versions are then downloaded automatically. If this is the first time you've selected this route there will be no saved version, and if there is no internet connection the details of the route cannot be displayed. "
        fullText += "\n\nBefore going on a walk make sure you select the route at least once while you have an internet connection to make sure a copy is saved in the app. You should also access the Map View and make sure the FULL route is visible in the map view. This will ensure the route is available and the necessary map segments are ALL available on your device even without an internet connection."
        
        infoTextView.text = fullText
        
        setActiveButton(selectedButton: gettingUpdatesButton)
    }
    
    func setActiveButton(selectedButton: UIButton) {
        switch selectedButton {
            
        case howMuchButton:
            
            howMuchButton.backgroundColor = UIColor.red
            howMuchButton.setTitleColor(UIColor.black, for: .normal)
            howMuchButton.alpha = 1
            
            usingAppButton.backgroundColor = UIColor.init(red: 0/255, green: 130/255, blue: 129/255, alpha: 0.62)
            usingAppButton.setTitleColor(UIColor.white, for: .normal)
            usingAppButton.alpha = 1.0
            
            gettingUpdatesButton.backgroundColor = UIColor.init(red: 0/255, green: 130/255, blue: 129/255, alpha: 0.62)
            gettingUpdatesButton.setTitleColor(UIColor.white, for: .normal)
            gettingUpdatesButton.alpha = 1.0

            
        case usingAppButton:
            
            usingAppButton.backgroundColor = UIColor.red
            usingAppButton.setTitleColor(UIColor.black, for: .normal)
            usingAppButton.alpha = 1
            
            howMuchButton.backgroundColor = UIColor.init(red: 0/255, green: 130/255, blue: 129/255, alpha: 0.62)
            howMuchButton.setTitleColor(UIColor.white, for: .normal)
            howMuchButton.alpha = 1.0
            
            gettingUpdatesButton.backgroundColor = UIColor.init(red: 0/255, green: 130/255, blue: 129/255, alpha: 0.62)
            gettingUpdatesButton.setTitleColor(UIColor.white, for: .normal)
            gettingUpdatesButton.alpha = 1.0
        case gettingUpdatesButton:
            
            gettingUpdatesButton.backgroundColor = UIColor.red
            gettingUpdatesButton.setTitleColor(UIColor.black, for: .normal)
            gettingUpdatesButton.alpha = 1
            
            howMuchButton.backgroundColor = UIColor.init(red: 0/255, green: 130/255, blue: 129/255, alpha: 0.62)
            howMuchButton.setTitleColor(UIColor.white, for: .normal)
            howMuchButton.alpha = 1.0
            
            usingAppButton.backgroundColor = UIColor.init(red: 0/255, green: 130/255, blue: 129/255, alpha: 0.62)
            usingAppButton.setTitleColor(UIColor.white, for: .normal)
            usingAppButton.alpha = 1.0
        default:
            
            gettingUpdatesButton.backgroundColor = UIColor.init(red: 0/255, green: 130/255, blue: 129/255, alpha: 0.62)

            gettingUpdatesButton.setTitleColor(UIColor.white, for: .normal)
            gettingUpdatesButton.alpha = 1
            
            howMuchButton.backgroundColor = UIColor.init(red: 0/255, green: 130/255, blue: 129/255, alpha: 0.62)
            howMuchButton.setTitleColor(UIColor.white, for: .normal)
            howMuchButton.alpha = 1
            
            usingAppButton.backgroundColor = UIColor.init(red: 0/255, green: 130/255, blue: 129/255, alpha: 0.62)
            usingAppButton.setTitleColor(UIColor.white, for: .normal)
            usingAppButton.alpha = 1
            
        }
        
            
            
        
        
    }
    
}
