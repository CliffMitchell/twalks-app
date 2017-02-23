//
//  DetailViewController.swift
//  TWalks
//
//  Created by Cliff Mitchell on 02/12/2015.
//  Copyright © 2015 Cliff Mitchell. All rights reserved.
//

import UIKit
import Kingfisher
import SystemConfiguration

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var detailTableView: UITableView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var detailNavigationBar: UINavigationItem!
    @IBOutlet weak var sectionController: UISegmentedControl!
    @IBOutlet weak var sectionNameLabel: UILabel!


   

    let indicator: UIActivityIndicatorView = UIActivityIndicatorView()

    
    // Route variables
    // Selected route, routeID, routeImageDictArray and routeupdated are passed from master view controller
    var selectedRoute:Route = Route()
    var routeupdated:Bool = false // Flag passed from master view controller to show if the route has been updated
    var routeImageDictArray:[NSDictionary] = [[String:String]]() as [NSDictionary]

    var detailItem: AnyObject? {
        didSet {
            // Update the view.
            //self.configureView()
            routeID = detailItem as! Int
            
        }
    }


    // Route variables
    var routeDownloaded:Bool = false
    var routeDescriptionLabel:String = ""
    var routeDetailLabel:String = ""
    var detailImageFileNameArray:[String] = [String]()
    var detailImageCaptionArray:[String] = [String]()
    var detailImage:UIImage = UIImage()
    var routeID:Int = 0
    
    // Section variables
    var sectionsProcessed:Bool = false
    var currentSection:Int = 0
    var numberOfSections:Int = 0
    var sectionsArray:[Section] = [Section]()
    var sectionImagesDictArray:[NSDictionary] = [NSDictionary]()
    var sectionFileNameArray:[String] = [String]()
    var sectionImageFileNameArray:[String] = [String]()
    var sectionImageCaptionArray:[String] = [String]()
    var sectionImages:[UIImageView] = [UIImageView]()
    var numberOfImagesInSection:[Int] = [Int]()
    var sectionName:String = ""
    var sectionDesc:String = ""
    var chosenImageIndex = 0
    var chosenImage:UIImage = UIImage()
    var chosenImageCaption:String = ""

    // Create new RouteModel
    var routeModel:RouteModel = RouteModel()

    var imageNumber:Int = 0
    let imageHeight:Int = 400
    
    // Create new SectionModel
    var sectionModel:SectionModel = SectionModel()
    
    
    override func viewWillAppear(_ animated: Bool) {
        //detailTableView.reloadData()
        //self.indicator.startAnimating()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set view controller as datasource and delegate
        
        self.detailTableView.delegate = self
        self.detailTableView.dataSource = self
        
        // Register the custom detail table view cell

        self.detailTableView.register(UINib(nibName: "CustomDetailTableViewCell", bundle: nil), forCellReuseIdentifier: "customDetailCell")
        
        self.detailTableView.rowHeight = UITableViewAutomaticDimension
        self.detailTableView.estimatedRowHeight = 50
        
        //print("routeupdated = \(routeupdated)")
        
        // Get the array of route image dictionaries for this route id
        
        var routeImageDictArray:[NSDictionary] = [[String:String]]() as [NSDictionary]
        routeImageDictArray = selectedRoute.routeImageDictArray
        
        // Format the view
        detailNavigationBar.title = selectedRoute.routeName
        routeDescriptionLabel = selectedRoute.routeDesc
        routeDetailLabel = selectedRoute.routeDetails
        numberOfSections = selectedRoute.sectionCount
        
        // Configure the section controller
        configureSectionController(self.sectionController)
        sectionNameLabel.text = "Route overview"
        
        // Loop through the array of route images and add each image to the array of image file names
        var i:Int = 0
        for image in routeImageDictArray {
            i = i+1
            
            // Get the image file name
            var imageFileName:String = String()
            imageFileName = image["imageFile"] as! String
            
            // Handle any spaces etc in the image file name
            imageFileName = imageFileName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            
            // Get the image caption
            var imageCaption:String = String()
            imageCaption = image["imageCaption"] as! String
            
            // Add the caption to the detailImageCaptionArray
            detailImageCaptionArray.append(imageCaption)
            
            // Add the image to the detaiImageArray
            detailImageFileNameArray.append(imageFileName)

        }
    }
    
    
    // Delegate methods for tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Set the number of rows in the table depending on which Section is being displayed
        
        switch self.currentSection {
            
        case 0:
            // Return the route overview number of rows
            return detailImageFileNameArray.count
            
        default:
            // Return the number of rows in the currentSection
            return numberOfImagesInSection[currentSection-1]
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell:CustomDetailTableViewCell = tableView.dequeueReusableCell(withIdentifier: "customDetailCell")! as! CustomDetailTableViewCell
        
        if currentSection == 0 {
            // Display Section 0 (this is the route overview)
            
            switch (indexPath as NSIndexPath).row {
                
            case 0:
                
                cell.setDetailImage(detailImageFileNameArray[0])
                cell.setLabelText(routeDescriptionLabel)
                cell.setDetailImageCaption(detailImageCaptionArray[0])
                
            case 1:
                
               cell.setDetailImage(detailImageFileNameArray[1])
               cell.setLabelText(routeDetailLabel)
               cell.setDetailImageCaption(detailImageCaptionArray[1])
                
            case 2:
                
                cell.setDetailImage(detailImageFileNameArray[2])
                cell.setLabelText("")
                cell.setDetailImageCaption(detailImageCaptionArray[2])
                
            default:
            
                cell.setDetailImage(detailImageFileNameArray[(indexPath as NSIndexPath).row - 3])
                cell.setLabelText("")
                cell.setDetailImageCaption(detailImageCaptionArray[(indexPath as NSIndexPath).row - 3])
       
            } // End of switch indexPath.row
        }
        else {
            // Display the selected section > 0 (i.e. every section other than the route overview
            
            // Select the correct section images from the sectionImageFileNameArray
            // Calculate which parts of the image arrays relate to the current section
            
            var lowerLimit:Int = 0
            var upperLimit:Int = numberOfImagesInSection[0] - 1
            if currentSection > 1 {
                for index in 2...currentSection {
                    lowerLimit = lowerLimit + numberOfImagesInSection[index - 2]
                    upperLimit = (lowerLimit + numberOfImagesInSection[index - 1]) - 1
                }
            
            }
           
            switch (indexPath as NSIndexPath).row {
                
            case 0:
                
                cell.setDetailImage(sectionImageFileNameArray[lowerLimit])
                if upperLimit == lowerLimit {
                    cell.setLabelText(sectionDesc)
                } else {
                    cell.setLabelText("")
                }
                
                cell.setDetailImageCaption(sectionImageCaptionArray[lowerLimit])
                
            case 1:
                
                cell.setDetailImage(sectionImageFileNameArray[lowerLimit + 1])
                cell.setLabelText(sectionDesc)
                cell.setDetailImageCaption(sectionImageCaptionArray[lowerLimit + 1])
                
            case 2:
                
                cell.setDetailImage(sectionImageFileNameArray[lowerLimit + 2])
                cell.setLabelText("")
                cell.setDetailImageCaption(sectionImageCaptionArray[lowerLimit + 2])
                
            default:
                
                cell.setDetailImage(sectionImageFileNameArray[lowerLimit + (indexPath as NSIndexPath).row])
                cell.setLabelText("")
                cell.setDetailImageCaption(sectionImageCaptionArray[lowerLimit + (indexPath as NSIndexPath).row])
                
            } // End of switch indexPath.row
            
        } // End of else = display sections > 0

        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func viewDidAppear(_ animated: Bool) {
        //detailTableView.reloadData()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        //print("Memory warning 2...")
  
    }

    func applySizeConstraintsToImage(_ imageView:UIImageView) {
        
        // set contstraints for the imageview
        let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: CGFloat(imageHeight))
        
        imageView.addConstraint(heightConstraint)
        
    }
    
    
    func configureSectionController(_ segmentController:UISegmentedControl) {
        // Configure the segment controller with the number of route sections etc.
        
        // Create the correct number of segments
        
        segmentController.removeAllSegments()
        
        for index in 0...numberOfSections{
          segmentController.insertSegment(withTitle: String(index), at: index, animated: true)
        }
    }
    
    
    @IBAction func sectionChanged(_ sender: AnyObject) {
        // A section has been selected from the segmented controller
        
        // Track the current section
        currentSection = sectionController.selectedSegmentIndex
        
        if sectionsProcessed {
            // Sections for this Route have already been processed so don't process again
            //NSLog("Sections already processed")
            
        } else {
            // Sections for this Route have not been processed so process them now
            //NSLog("Sections not processed")
            
            // Start activity indicator
            //NSLog("Starting")

            let alert = UIAlertController(title: nil, message: "Loading sections...", preferredStyle: .alert)
            
            alert.view.tintColor = UIColor.black
            let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:10, y:5, width: 50, height: 50)) as UIActivityIndicatorView
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
            loadingIndicator.startAnimating();
            
            alert.view.addSubview(loadingIndicator)
            present(alert, animated: false, completion: nil)

            let globalQueue = DispatchQueue.global(qos: .background)
            globalQueue.sync {
                
                // Process sections for this route

                if connectedToNetwork() {
                    // There is an active internet connection
                    //print ("Internet connection OK")
                    if routeupdated {
                        // The route has been updated so download and store the new sections
                        //print("Route has been updated so download new sections...")
                        
                        // Get the sections for this route
                        self.sectionsArray = sectionModel.getSections(routeID)
                        
                        // Store the new sections in Core Data
                        sectionModel.storeRouteSections(sectionsArray: sectionsArray)
                        
                        // Get the Section Images for this route
                        sectionImagesDictArray = self.sectionModel.getSectionImages4Route(routeID)
                        
                        // Store the section images in Core Data
                        sectionModel.storeRouteSectionImages(sectionImagesArray: sectionImagesDictArray)
                        
                        sectionsProcessed = true
                        
                    } else {
                        // The route has not been updated so see if there is a stored version
                        //print("Route not updated so see if there is a stored version")
                        // Load stored version
                        sectionsArray = sectionModel.getStoredRouteSections(routeID: routeID)
                        
                        // If number of records loaded > 0, display stored version
                        if sectionsArray.count > 0 {
                            // There is a stored version of the sections for this route so load the stored section images
                            //print("Stored version found...")
                            sectionImagesDictArray = sectionModel.getSectionImages4Route(routeID)
                            
                            sectionsProcessed = true
                            
                        } else {
                            // There is no stored version of the sections for this route
                            // No records loaded so download sections from server
                            // Get the sections for this route
                            //print("No stored version found so download the sections for this route...")
                            self.sectionsArray = sectionModel.getSections(routeID)
                            
                            // Store the new sections in Core Data
                            sectionModel.storeRouteSections(sectionsArray: sectionsArray)
                            
                            // Get the Section Images for this route
                            sectionImagesDictArray = self.sectionModel.getSectionImages4Route(routeID)
                            
                            // Store the section images in Core Data
                            sectionModel.storeRouteSectionImages(sectionImagesArray: sectionImagesDictArray)
                            
                            sectionsProcessed = true
                            
                        } // End of if there is a stored version of sections
                        
                    }
                    
                } else {
                    // There is no active internet connection
                    //print("There is no active internet connection...")
                    // Try and load a stored version
                    sectionsArray = sectionModel.getStoredRouteSections(routeID: routeID)
                    // If number of records loaded > 0, display stored version
                    if sectionsArray.count > 0 {
                        // There is a stored version of the sections for this route so load the stored section images
                        sectionImagesDictArray = sectionModel.getStoredRouteSectionImages(routeID: routeID)
                        
                        sectionsProcessed = true
                        
                    } else {
                        // There is no stored version and no internet connection 
                        // An empty sectionsArray will be carried forward
                        //print("No internet, no stored sections...")
                    }
                    
                } // End of test for internet connection
                
                self.numberOfImagesInSection = [Int](repeating: 0, count: self.numberOfSections)

                // Loop through the array of Section images and add each image to the array of image file names
                // and add the captions to the array of image captions
                // and add the image view to the array of image views
                var i:Int = -1
                var sectionID:Int = 0
                var currentSectionID:Int = 0
                for image in sectionImagesDictArray {
                    
                    // Get the section id
                    currentSectionID = Int(image["fk_idSection"] as! String)!
                    
                    // Get the image file name
                    var sectionImageFileName:String = String()
                    sectionImageFileName = image["imageFile"] as! String
                    
                    // Handle any spaces etc in the image file name
                    sectionImageFileName = sectionImageFileName.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
                    
                    // Get the image caption
                    var sectionImageCaption:String = String()
                    sectionImageCaption = image["imageCaption"] as! String
                    
                    // Add the caption to the detailImageCaptionArray
                    self.sectionImageCaptionArray.append(sectionImageCaption)
                    
                    // Add the image to the sectionImageArray
                    self.sectionImageFileNameArray.append(sectionImageFileName)
                    
                    // Add the actual images to the sectionImages array
                    
                    let imageView:UIImageView = UIImageView()
                    imageView.kf_setImage(with: URL(string: "https://www.turuncwalks.com/files/images/" + sectionImageFileName)!, placeholder: UIImage(named: "placeholder50"),
                                          options: [.transition(.fade(1))],
                                          progressBlock: nil,
                                          completionHandler: nil)
                    
                    self.sectionImages.append(imageView)
                    
                    // Count number of images in each section
                    
                    if sectionID == currentSectionID {
                        self.numberOfImagesInSection[i] += 1
                        
                    } else {
                        i = i+1
                        self.numberOfImagesInSection[i] += 1
                        sectionID = currentSectionID
                        
                    }
                    
                }

                // Stop activity indicator
                
                //NSLog("Finished")
                DispatchQueue.main.async {
                    self.indicator.stopAnimating()
                    alert.dismiss(animated: false, completion: nil)
                    }
            } // End of background queue

        
        }  // End of else - Sections have not been downloaded yet
        

        // Get the selected section (unless selectedSection = 0 as this is the route overview)
        if sectionController.selectedSegmentIndex > 0 {
            // Check if any sections have been returned (possible lack of internet connectivity on first time access of sections
            if sectionsArray.count > 0 {
            
            let selectedSection:Section  = self.sectionsArray[currentSection - 1]
            
            sectionName = selectedSection.sectionName
            sectionDesc = selectedSection.sectionDesc
            sectionNameLabel.text = sectionName
        
            // Display the selected section

            self.detailTableView.reloadData()

            } else {
                // No sections have been found so report an error
                //print("No sections returned so go to detail error segue....")
                // This generates a warning about attempting to dismiss while presentation or dismiss is in progress but I can't get rid of this!
                self.dismiss(animated: false, completion: {
                    self.performSegue(withIdentifier: "showDetailErrorSegue", sender: self)
                })
               
            }

       
        } else {
            // Section 0 (route overview) has been selected
            
            sectionNameLabel.text = "Route overview"
            detailTableView.numberOfRows(inSection: detailImageFileNameArray.count)
            self.detailTableView.reloadData()

        }        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        chosenImageIndex = indexPath.row
        let currentCell = tableView.cellForRow(at: indexPath) as! CustomDetailTableViewCell
        chosenImageCaption = currentCell.imageCaption.text!
        chosenImage = currentCell.detailImageView.image!
        self.performSegue(withIdentifier: "imageZoomSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "imageZoomSegue" {
            
            let destinationViewController = segue.destination as! imageZoomViewController
            destinationViewController.title = "Image Pan/Zoom"
            destinationViewController.zoomImageViewLabelText = chosenImageCaption
            destinationViewController.zoomImageViewImage = chosenImage
        }
        
        if segue.identifier == "mapViewSeque" {
            let destinationViewController = segue.destination as! mapViewController
            destinationViewController.title = selectedRoute.routeName
            destinationViewController.routeMarkers = selectedRoute.routeMarkers
    
        }
        
        if segue.identifier == "showDetailErrorSegue" {
            let destinationViewController = segue.destination as! ErrorViewController
            destinationViewController.title = "Connection Error"

            destinationViewController.errorLabelText = "It looks like there is no active internet connection and no stored version of the sections for this route is available. Please try again when you have an internet connection."
        }
        
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

}




