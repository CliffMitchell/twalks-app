//
//  MasterViewController.swift
//  TWalks
//
//  Created by Cliff Mitchell on 02/12/2015.
//  Copyright © 2015 Cliff Mitchell. All rights reserved.
//

import UIKit
import SystemConfiguration


class MasterViewController: UITableViewController {
    
    var detailViewController: DetailViewController? = nil
    
    
    // Create new RouteModel
    var routeModel:RouteModel = RouteModel()
    var routes:[[Route]]=[[Route]]()
    var categoriesDict:[String:Int] = [String:Int]()
    var selectedRoute:Route = Route()
    var remotedbversionid:Int = 0
    var remotedbversiondate:String = ""
    var routeupdated:Bool = false
    var storedLabelText:String = ""
    
    // Create new SectionModel
    var sectionModel:SectionModel = SectionModel()
    var sectionsArray:[Section] = [Section]()
    var sectionImagesDictArray:[NSDictionary] = [NSDictionary]()

    let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add an Info button to the navigation bar
        let infoButton = UIButton(type: .infoLight )
        infoButton.addTarget(self, action: #selector(infoButtonTapped(sender:)), for: .touchDown)
        let navButtonItem = UIBarButtonItem(customView: infoButton )
        navigationItem.rightBarButtonItem = navButtonItem
        
        self.splitViewController?.preferredDisplayMode = .allVisible
        
        // Check to see if this is the first time the app has been used
        if launchedBefore  {
            //print("Not first launch.")
        } else {
            //print("First launch, setting UserDefault.")
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
        
        // See if there is an active internet connection
        if connectedToNetwork() {
            //print ("Internet connection OK")
            
            // Get the latest db version from the remote server
            remotedbversionid = routeModel.getdbversion().dbversionid
            remotedbversiondate = routeModel.getdbversion().dbversiondate
            //print(remotedbversiondate)
            //print(remotedbversionid)
            
            if  launchedBefore {
                // Compare current db version with saved db version
                let dbversionid = UserDefaults.standard.integer(forKey: "dbversionid")
                //print("id= \(dbversionid)")
                //print("remoteid= \(remotedbversionid)")
                if remotedbversionid == dbversionid {
                    // The stored db version is the latest version so load the stored list
                    routes = routeModel.getStoredRouteList()
                    //print("Database is up to date")
                } else {
                    // There is an updated version of the database on the server so download it
                    //print("Database needs updating")
                    
                    // Delete any old stored list just in case
                    routeModel.deleteStoredRouteList()
                    
                    // Get list of routes by category from remote server
                    self.routes = self.routeModel.getRoutes()
                    
                    // Save route
                    routeModel.storeRouteList(routes: routes)
                    
                    // Record the new database version in UserDefaults
                    UserDefaults.standard.set(remotedbversionid, forKey: "dbversionid")
                    UserDefaults.standard.set(remotedbversiondate, forKey: "dbversiondate")
                    routeupdated = true
                }
                
            } else {
                // Not launched before but active internet connection so get route list from server
               
                // Delete any old stored list just in case
                routeModel.deleteStoredRouteList()
                
                // Get list of routes by category from remote server
                self.routes = self.routeModel.getRoutes()

                // Save route
                routeModel.storeRouteList(routes: routes)
                
                // Record the database version in UserDefaults
                UserDefaults.standard.set(remotedbversionid, forKey: "dbversionid")
                UserDefaults.standard.set(remotedbversiondate, forKey: "dbversiondate")
                routeupdated = true
                
            } // End of if launchedBefore
            
        } else {

            // There is no active internet connection
            //print ("No active internet connection")
            
            // Check if this is first use
            if !launchedBefore {
                // No internet connection and not launched before so app cannot be used
                // Either display new view or display alert to user
                //print("No internet connection and not launched before.")
                DispatchQueue.main.async(execute: {
                    let alertController:UIAlertController = UIAlertController(title: "First use error", message: "This is the first time you have used Turunç Walks and an internet connection is required to download the list of walks.", preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                        
                        // Actions to take when OK is pressed.
                        // Reload the view and try again
                        
                        self.viewDidLoad()
                        self.viewWillAppear(true)
                        self.tableView.reloadData()
                        
                    })
                    alertController.addAction(cancelAction)
                    
                    UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
                })
                
            } else {
                // No internet connection but app has been launched before so used stored route list
                
                // Get the saved route list
                routes = routeModel.getStoredRouteList()
                
            }

        }
        
        // Make sure the delegate is correctly set
        tableView.delegate = self
        
        // Add a footer to the table to hide the unnecessary separator lines
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // Check if there is at least one route
        if self.routes.count > 0 {
            
            // Get the route categories from the route model
            self.categoriesDict = self.routeModel.getRouteCategories(self.routes) as! [String : Int]
            
            // Display the routes

            if let split = self.splitViewController {
                let controllers = split.viewControllers
                self.detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
                }
        
                // Register the custom table view cell (customRouteCell)
                self.tableView.register(UINib(nibName: "customRouteCell", bundle: nil) , forCellReuseIdentifier: "customRouteCell")
         }
            else {
            // No routes were retrieved
            //NSLog("No routes found")
            
            DispatchQueue.main.async(execute: {
                let alertController:UIAlertController = UIAlertController(title: "Connection Error", message: "It looks like there's no internet connection so we can't load the list of routes.", preferredStyle: UIAlertControllerStyle.alert)
                let cancelAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                    
                    // Actions to take when OK is pressed.
                    // Reload the view and try again
                    
                    self.viewDidLoad()
                    self.viewWillAppear(true)
                    self.tableView.reloadData()
                    
                })
                alertController.addAction(cancelAction)
                
                UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
            })
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        self.clearsSelectionOnViewWillAppear = self.splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //print("Memory warning 1 ...")
        
        DispatchQueue.main.async(execute: {
            let alertController:UIAlertController = UIAlertController(title: "Memory Error", message: "It looks like there is insufficient storage on your device to store the route details. Please free up some space and try again.", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction:UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
                
                // Actions to take when OK is pressed.
                // Reload the view and try again
                
                self.viewDidLoad()
                self.viewWillAppear(true)
                self.tableView.reloadData()
                
            })
            alertController.addAction(cancelAction)
            
            UIApplication.shared.keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        })
        
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //NSLog("going to detail")
        
        if segue.identifier == "showDetail" {

            // A route (table row) has been selected so pass the selected route to the DetailViewController
            
            if self.tableView.indexPathForSelectedRow != nil {
               
                // Set the destination as the DetailViewController
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                // Pass the selected route to the destination view controller
                controller.detailItem = selectedRoute.routeID as AnyObject?
                controller.selectedRoute = selectedRoute
                controller.routeupdated = routeupdated
                controller.sectionsArray = sectionsArray
                controller.sectionImagesDictArray = sectionImagesDictArray
                controller.storedLabelText = storedLabelText
                
                
                controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
               
            }
            
        } else if segue.identifier == "showErrorSegue" {
            
            let destinationViewController = segue.destination as! ErrorViewController
            destinationViewController.title = "Connection Error"
            //let errorText:String = "It looks like there is no active internet connection and no stored version of this route, so we are unable to display your selected route."
            destinationViewController.errorLabelText = "It looks like there is no internet connection and no stored version of this route."
        }
        else if segue.identifier == "showMainInfoSegue" {
            let destinationViewController = segue.destination as! InfoViewController
            destinationViewController.title = "TWalks Info"
            
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // A row (route) has been selected so prepare to segue to the DetailViewController
        
        let alert = UIAlertController(title: nil, message: "Loading route...", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:10, y:5, width: 50, height: 50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
        
        DispatchQueue.global(qos: .userInitiated).async(execute: {
            
            if let indexPath = self.tableView.indexPathForSelectedRow {
                // Get the selected route
                let currentRoute = self.routes[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
                let selectedRouteID = currentRoute.routeID
                
                // Now get the full route details for the selected route
                // (we only have summary details from the list of routes)
                
                // Check if there is an internet connection
                if self.connectedToNetwork() {
                // There is an internet connection
                    
                    // Check if there is a stored copy of the route and if so, is it the latest version
                    //print ("Internet connection OK")
                    
                    // Get the latest version number of this route from the server
                    let remoterouteversion = self.routeModel.getrouteversion(routeid: selectedRouteID).routeversion
                    //print("Route version number = \(remoterouteversion)")
                    
                    let localrouteversion = UserDefaults.standard.integer(forKey: "routeversion" + String(selectedRouteID))
                    
                    //print("local route id= \(localrouteversion)")
                    //print("remote id= \(remoterouteversion)")
                    if remoterouteversion == localrouteversion {
                        // The stored route is the latest version, so use the stored version
                        self.selectedRoute = self.routeModel.getStoredRoute(routeID: selectedRouteID)
                        //print("Loaded stored route.")
                        //print ("Retrieved route name = \(self.selectedRoute.routeName)")
                        //print ("Retrieved gpx file name = \(self.selectedRoute.routeGPXFileName)")
                        // Get the stored route markers
                        self.selectedRoute.routeMarkers = self.routeModel.getStoredRouteMarkers(routeID: selectedRouteID)
                        // Get the stored route image array
                        self.selectedRoute.routeImageDictArray = self.routeModel.getStoredRouteImages(routeID: selectedRouteID)
                        
                        // Get the sections for this route
                        // Get Sections
                        self.sectionsArray = self.sectionModel.getSections(selectedRouteID)
                        // Get Section Images
                        self.sectionImagesDictArray = self.sectionModel.getSectionImages4Route(selectedRouteID)
                        
                        self.routeupdated = false
                        self.storedLabelText = "Using existing saved route."
                        
                        alert.dismiss(animated: true, completion: {
                            self.performSegue(withIdentifier: "showDetail", sender: self)
                        })
                        
                    } else {
                        
                        // The stored route is NOT the latest version so download the latest version from the server
                        
                        // Do NOT delete the current version until a new version has been completely downloaded. This avoids problems with intermittent data connections
                        //print("Downloading latest version...")
                        
                        // Download all parts of route
                        // Download the route iteself
                        self.selectedRoute  = self.routeModel.getRoute(selectedRouteID)
                        
                        // Download the associated route GPX file
                        // Get the gpx file and parse into the selected route model
                        
                        let gpxfilename = self.selectedRoute.routeGPXFileName
                        //print("gpx file name = \(gpxfilename)")
                        self.selectedRoute.routeMarkers = [NSDictionary]()
                        self.selectedRoute.routeMarkers = self.routeModel.getMarkers(gpxfilename: gpxfilename) 
                        
                        // Get the route images array
                        self.selectedRoute.routeImageDictArray = self.routeModel.getRouteImages(selectedRouteID)
                        
                        // Get the sections for this route
                        // Get Sections
                        self.sectionsArray = self.sectionModel.getSections(selectedRouteID)
                        // Get Section Images
                        self.sectionImagesDictArray = self.sectionModel.getSectionImages4Route(selectedRouteID)
                        

                        // Check if everything has downloaded successfully before deleting the stored route
                        if ((self.selectedRoute.routeID > 0) && (self.selectedRoute.routeMarkers.count > 0) && (self.selectedRoute.routeImageDictArray.count > 0) && (self.sectionsArray.count > 0) && (self.sectionImagesDictArray.count > 0) ){
                            // Everything appears to be downloaded successfully so delete the old verions and save the new version
                            //print("Everything downloaded OK.")
                            
                            // Delete any existing version of this route in Core Data
                            self.routeModel.deleteStoredRoute(routeid: selectedRouteID)
                            // Delete the previous version of the route markers
                            self.routeModel.deleteStoredRouteMarkers(routeID: selectedRouteID)
                            // Delete any existing version of the route images array from Core Data
                            self.routeModel.deleteStoredRouteImages(routeID: selectedRouteID)
                            // Delete any existing version of the route sections from Core Data
                            self.sectionModel.deleteStoredRouteSections(routeID: selectedRouteID)
                            // Delete any existing version of the route section images from Core Data
                            self.sectionModel.deleteStoredRouteSectionImages(routeID: selectedRouteID)
                            
                            // Now store the new version...
                            // Store the downloaded version and update the version in UserDefaults
                            self.routeModel.storeRoute(route: self.selectedRoute)
                        
                            // Save the new route markers
                            self.routeModel.storeRouteMarkers(routeID: selectedRouteID, routeMarkers: self.selectedRoute.routeMarkers)
                        
                            // Store the route images array in Core Data
                            self.routeModel.storeRouteImages(routeImagesArray: self.selectedRoute.routeImageDictArray)
                            
                            // Store the sections for this route in Core Data
                            self.sectionModel.storeRouteSections(sectionsArray: self.sectionsArray)
                            
                            // Store the section images for this route in Core Data
                            self.sectionModel.storeRouteSectionImages(sectionImagesArray: self.sectionImagesDictArray)
                        
                            // Update the stored route verions in UserDefaults
                            UserDefaults.standard.set(remoterouteversion, forKey: "routeversion" + String(selectedRouteID))
                            self.storedLabelText = "Using new saved route."
                            self.routeupdated = true
                            
                            
                        } else {
                            // Something has NOT downloaded successfully so use the stored version even though it is out of date...
                            //print("Something did not download properly.")
                            
                            // Handle the case where things did NOT download correctly...
                            //print("Using stored route version...")
                            
                            // Get the stored route
                            self.selectedRoute = self.routeModel.getStoredRoute(routeID: selectedRouteID)

                            // Get the stored route markers
                            self.selectedRoute.routeMarkers = self.routeModel.getStoredRouteMarkers(routeID: selectedRouteID)
                            // Get the stored route image array
                            self.selectedRoute.routeImageDictArray = self.routeModel.getStoredRouteImages(routeID: selectedRouteID)
                            
                            // Get the sections for this route
                            self.sectionsArray = self.sectionModel.getSections(selectedRouteID)
                            
                            // Get the section images for this route
                            self.sectionImagesDictArray = self.sectionModel.getSectionImages4Route(selectedRouteID)
                            
                            self.storedLabelText = "Using existing saved route."
                            self.routeupdated = false
                            
                        }
                                               
                        alert.dismiss(animated: true, completion: {
                            self.performSegue(withIdentifier: "showDetail", sender: self)
                        })
                        
                    } // End of if local version == remote version with an active data connection
                    
                    
                } else {
                // There is no internet connection
                    
                    //print("No internet connection.")
                    // Check if there is a stored version of this route
                    let localrouteversion = UserDefaults.standard.integer(forKey: "routeversion" + String(selectedRouteID))
                    if localrouteversion > 0 {
                        // There is a local stored version of the selected route so use this
                        
                        //print("local version exists: \(localrouteversion)")
                        self.selectedRoute = self.routeModel.getStoredRoute(routeID: selectedRouteID)

                        self.selectedRoute.routeMarkers = self.routeModel.getStoredRouteMarkers(routeID: selectedRouteID)
                        
                        self.selectedRoute.routeImageDictArray = self.routeModel.getStoredRouteImages(routeID: selectedRouteID)
                        
                        self.sectionsArray = self.sectionModel.getStoredRouteSections(routeID: selectedRouteID)
                        
                        self.sectionImagesDictArray = self.sectionModel.getStoredRouteSectionImages(routeID: selectedRouteID)
                        
                        self.routeupdated = false
                        self.storedLabelText = "Using existing saved route."
                        alert.dismiss(animated: true, completion: {
                        self.performSegue(withIdentifier: "showDetail", sender: self)
                        })
                        
                    } else {
                        // There is no local stored version of this route and no internet connection
                        // Display a message to the user
                        
                        //print("Display a message to the user - no stored version and no data connection!")
                        alert.dismiss(animated: true, completion: {
                            self.performSegue(withIdentifier: "showErrorSegue", sender: self)
                        })
                    }
                }
            }
        })
    }

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        let numberOfCategories:Int = self.categoriesDict.count
        
        return numberOfCategories
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // The number of rows in each section is the number of routes in each category
        // This is held in the categoriesDict dictionary [String:Int] (but remember a dictionary is unordered)
        
        var dictValues:[Int] = [Int](repeating: 0, count: 3)
        for (myKey,myValue) in categoriesDict {

            switch myKey {
            case "Easy":
                dictValues[0] = myValue
            case "Moderate":
                dictValues[1] = myValue
            case "Strenuous":
                dictValues[2] = myValue
            default:
                dictValues.append(0)
            }
        }

        return dictValues[section]

    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Get a cell
        let routeCell:customRouteCell = tableView.dequeueReusableCell(withIdentifier: "customRouteCell") as! customRouteCell!
        
        routeCell.layer.borderWidth = 0.5
        routeCell.layer.borderColor = UIColor.lightGray.cgColor
        
        // Get the next route
        let currentRoute:Route = routes[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).row]
        
        // Configure the cell
        routeCell.setLabelText(currentRoute.routeName)
        routeCell.setLabelBackground(currentRoute.routeCategory)
        routeCell.setCellImage(currentRoute.routeImageFile.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)

        routeCell.setCellDistance(currentRoute.routeDistance)
        routeCell.setCellTime(currentRoute.routeTime)
        
        // Return the cell
        return routeCell        
        
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var dictKeys:[String] = [String](repeating: "", count: 3)
        for myKey in categoriesDict.keys {
            switch myKey {
            case "Easy":
                dictKeys[0] = myKey
            case "Moderate":
                dictKeys[1] = myKey
            case "Strenuous":
                dictKeys[2] = myKey
            default:
                dictKeys.append("")
            }
        }
        return dictKeys[section]
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 15.0
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView  // recast view as UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.gray
        header.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        switch section {
        case 0:
            header.contentView.backgroundColor = UIColor(red: 77/255, green: 1.0, blue: 82/255, alpha: 0.2)
        case 1:
            header.contentView.backgroundColor = UIColor(red: 265/265 , green: 200/255, blue: 0.0, alpha: 0.2)
        case 2:
            header.contentView.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.2)
        default:
            header.contentView.backgroundColor = UIColor.red
        }
        
    }


    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    
    func connectedToNetwork() -> Bool {
        // Function to check if there is an active internet connection
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }

    func infoButtonTapped(sender: UIBarButtonItem) {
        
        self.performSegue(withIdentifier: "showMainInfoSegue", sender: self)
        
    }
    
    
}

