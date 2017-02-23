//
//  ErrorViewController.swift
//  TWalks
//
//  Created by Cliff Mitchell on 15/02/2017.
//  Copyright © 2017 Cliff Mitchell. All rights reserved.
//

import UIKit

class ErrorViewController: UIViewController {

    @IBOutlet weak var errorLabel: UILabel!

    @IBOutlet weak var errorDetailsLabel: UILabel!
    // Create variables to receive data from the segue
    var errorLabelText:String! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        errorLabel.text = errorLabelText
        
        var helpText:String = "The first time you use this app you need an active internet connection so the list of routes can be downloaded. Once downloaded the route list is saved in the app and will only be downloaded again if an updated version becomes available.\n\n "
        helpText += "When a route is selected from the list the app will download the full route details and save them on your device - this requires an active internet connection.\n\n "
        helpText += "Each time a route is selected subsequently the app will use the version stored on your device unless there is an updated version available. Updated versions are downloaded automatically when you have an internet connection. "
        helpText += "If there is no stored version, and there is no internet connection, the details of the route cannot be displayed. "
        helpText += "\n\nBefore going on a walk make sure you select that route at least once while you have an internet connection. The route will then be available on your device even without an internet connection. "
        errorDetailsLabel.text = helpText
        
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

}
