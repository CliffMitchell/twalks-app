//
//  RouteModel.swift
//  TWalks
//
//  Created by Cliff Mitchell on 13/12/2015.
//  Copyright © 2015 Cliff Mitchell. All rights reserved.
//

import UIKit
import CoreData

class RouteModel: NSObject, XMLParserDelegate {
    
    var nameFound:Bool = false
    var dataFound:Bool = false
    var wpName:String = ""
    var wpSeq:Int = 0
    var routeMarkers:[NSDictionary] = [NSDictionary]()  // Array of all route way markers
    var routeMarker:[String:String] = [String:String]() // To hold a route way marker
    
func getRoutes() -> [[Route]] {
        
        // Function to retrieve a list of all routes from the server
        
        //Arrray of Route objects to return
        var retrievedRoutes:[Route] = [Route]()
        var routesByCategory:[[Route]] = [[Route]]()
        var currentCategory:Int = 0
        var thisRow:Int = -1
    
        // Get a NSURL object pointing to the URL of the retrieval web service
        let url:URL = URL(string: "https://www.turuncwalks.com/services/twsSelRoutes.php")!

        // Get the JSON array of dictionaries
        let jsonObjects:[NSDictionary] = self.getRemoteJsonFile(url)
        
        //Loop through each dictionary and passing values to our Route objects

        //var index:Int
        for index in 0..<jsonObjects.count {
            
            // Current json dictionary
            let jsonDictionary:NSDictionary = jsonObjects[index]
            
            // Create a route object
            
            let routeObject:Route = Route()
            
            // Assign the value of each key value pair to the route object
            
            routeObject.routeID = Int(jsonDictionary["routeID"] as! String)!
            routeObject.routeName = jsonDictionary["routeName"] as! String
            routeObject.routeImageFile = jsonDictionary["routeImageFile"] as! String
            routeObject.routeCategoryName = jsonDictionary["routeCategoryName"] as! String
            routeObject.routeCategory = Int(jsonDictionary["routeCategory"] as! String)!
            routeObject.routeDistance = Float(jsonDictionary["routeDistance"] as! String)!
            routeObject.routeTime = Float(jsonDictionary["routeTime"] as! String)!

            // Add the route to the route array
            retrievedRoutes.append(routeObject)

        }
        
        // Sort retrieved routes array(of dictionaries) by route Category
        retrievedRoutes.sort { (route1:Route, route2:Route) -> Bool in
            route1.routeCategoryName < route2.routeCategoryName
        }
        
        // Create a separate array of routes of each category and add to an array of routes by section
        routesByCategory = arrangeRoutesByCategory(routesArray: retrievedRoutes)
    
        return routesByCategory
    }
    
    
    func getRoute(_ routeID:Int) -> Route{
        
        // Function to get a specified route from the server
        
        //Route object to return
        var retrievedRoute:Route = Route()
        
        // Get a NSURL object poiting to the URL of the retrieval web service
        let url:URL = URL(string: "https://www.turuncwalks.com/services/twsGetRoute.php?id=" + String(routeID))!
        
        // Get the JSON array of dictionaries
        let jsonObjects:[NSDictionary] = self.getRemoteJsonFile(url)
        
        if jsonObjects.count < 1 {
            // Nothing has been returned - possible inernet connection problems
            //NSLog("No jsonObjects returned")
            return retrievedRoute
        }
        
        // Loop through each dictionary and passing values to our Route objects
        

        for index in 0..<jsonObjects.count {
            
            // Current json dictionary
            let jsonDictionary:NSDictionary = jsonObjects[index]
            
            // Create a route object
            
            let routeObject:Route = Route()
            
            // Assign the value of each key value pair to the route object
            
            routeObject.routeID = Int(jsonDictionary["routeID"] as! String)!
            routeObject.routeName = jsonDictionary["routeName"] as! String
            routeObject.routeImageFile = jsonDictionary["routeImageFile"] as! String
            routeObject.routeCategoryName = jsonDictionary["routeCategoryName"] as! String
            routeObject.routeDistance = Float(jsonDictionary["routeDistance"] as! String)!
            routeObject.routeTime = Float(jsonDictionary["routeTime"] as! String)!
            routeObject.routeDesc = jsonDictionary["routeDesc"] as! String!
            // Strip out any HTML from the route description
            routeObject.routeDesc = routeObject.routeDesc.replacingOccurrences(of: "<[^>]+>", with: "", options:  .regularExpression, range: nil)
            // Replace &#39 characters with apostrophes
            routeObject.routeDesc = routeObject.routeDesc.replacingOccurrences(of: "&#39", with: "'", options:  .regularExpression, range: nil)
            
            routeObject.routeDetails = jsonDictionary["routeDetails"] as! String!
            // Strip out any HTML from the route details
            routeObject.routeDetails = routeObject.routeDetails.replacingOccurrences(of: "<[^>]+>", with: "", options:  .regularExpression, range: nil)
            routeObject.routeImageCaption = jsonDictionary["routeImageCaption"] as! String!
            routeObject.routeImageDesc = jsonDictionary["routeImageDesc"] as! String!
            routeObject.sectionCount = Int(jsonDictionary["sectionCount"] as! String)!
            routeObject.routeGPXFileName = jsonDictionary["gpxfilename"] as! String!

            // Add the route to the route array
            retrievedRoute = routeObject
            
        }
        return retrievedRoute
        
    }

    
    func getRemoteJsonFile(_ url:URL) -> [NSDictionary] {
        
        //Function to retrieve the json Route file from the server at the given url
        
        let jsonData:Data? = try? Data(contentsOf: url)
        
        if let actualJsonData = jsonData {
            
            // NSData exists, use the NSJSONSerialization classes to parse the data and create the dictionaries
            do {
                let arrayOfRoutes:[NSDictionary] = try JSONSerialization.jsonObject(with: actualJsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as! [NSDictionary]
                return arrayOfRoutes
            }
            catch {
                
                // There was an error parsing the json file
                //NSLog("Error parsing json file")
            }
        }
        else {
            
            // NSData doesn't exist. Possibly no internet connection
    
            //NSLog("NSData cannot be found - possible loss of internet connection")
        }
        // Return an empty array
        return [NSDictionary]()
    }
    
    
    func getRouteCategories(_ routesArray:[[Route]]) -> NSDictionary {
        
       // Loop throught the array of routes and create an array of dictionaries
        var categoryDict:[String:Int] = [String:Int]()
        

        var row:Int = 0
        var col:Int = 0
        var categoryName:String = ""
        var categoryCount:Int = 0
       
        for row in 0..<routesArray.count {
            
            for col in 0..<routesArray[row].count {
                categoryName = routesArray[row][0].routeCategoryName
            
                // If category already exists in dictionary, increment the value (route count for category)
           
                if categoryDict[categoryName] != nil {
            
                        categoryCount = categoryDict[categoryName]! + 1
                categoryDict.updateValue(categoryCount, forKey: categoryName)
                }
                else {
                
                    // Category does no exist in the dictionay so add the key:value pair for this category
                    // with value = 1
                
                    categoryDict[categoryName] = 1
                }
            }
        }
        
        return categoryDict as NSDictionary
    }
    
    
    func getRouteImages(_ routeID:Int) -> [NSDictionary] {
        
        // Get all of the images associated with a specified route and return an array of dictionaries
        // containing the route image details.
        
        // Get a NSURL object poiting to the URL of the retrieval web service
        let url:URL = URL(string: "https://www.turuncwalks.com/services/twsSelImages4Route.php?id=" + String(routeID))!
        
        //Function to retrieve the json Route file from the server at the given url
        
        let jsonData:Data? = try? Data(contentsOf: url)
        
        if let actualJsonData = jsonData {
            
            // NSData exists, use the NSJSONSerialization classes to parse the data and create the dictionaries
            
            do {
                let arrayOfRouteImages:[NSDictionary] = try JSONSerialization.jsonObject(with: actualJsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as! [NSDictionary]
                return arrayOfRouteImages
            }
            catch {
                
                // There was an error parsing the json file
                //NSLog("Error parsing json file")
            }
        }
        else {
            
            // NSData doesn't exist. Possibly no internet connection
            
            //NSLog("NSData doesn't exist")
            
        }
        
        // Return an empty array
        return [NSDictionary]()
   
    }

    func getMarkers(gpxfilename:String) -> [NSDictionary] {
        // Using the provided routeID, get the .gpx file from the server
        // and parse it into an array of dictionaries
        routeMarkers = [NSDictionary]() 
        wpSeq = 0

        // Get the named .gpx file from the server
        let urlString:String = "https://www.turuncwalks.com/files/downloads/" + gpxfilename
        guard let url:URL = URL(string: urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)!
            else {
            //NSLog(".gpx URL not defined properly")
            return [NSDictionary]()
        }
        
        var parser = XMLParser()
        parser = XMLParser(contentsOf: url)!

            parser.delegate = self
            if parser.parse() {
                //here are the results
                return routeMarkers
            }
            else {
                //NSLog("Failed to parse the .gpx file.")
        }
        
        // Return the arrary of dictionaries
        return [NSDictionary]()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "trkpt" || elementName == "wpt" || elementName == "rtept" {
            let lat = attributeDict["lat"]
            let lon = attributeDict["lon"]

            wpSeq = wpSeq + 1
            routeMarker["seq"] = String(wpSeq)
            routeMarker["lat"] = lat
            routeMarker["lon"] = lon
        }
        
        if elementName == "name" {
            nameFound = true
        }
        dataFound=true
        
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "wpt"  {
            routeMarkers.append(routeMarker as NSDictionary)
        }
        
        if elementName == "name" {
            nameFound = false
            routeMarker["name"] = wpName
            wpName = ""
        }
        dataFound=false
    
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        // Get characters (for the name)
        if (nameFound) {
            wpName = wpName + string
        }
    }

    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        // Handle parse errors
        //NSLog("Parser failure: " + String(describing: parseError))
    }
    
    func getdbversion() -> (dbversionid: Int, dbversiondate: String) {
        // Function to get the current database version from the remote server
        var dbversionid:Int = 0
        var dbversiondate:String = ""
        
        // Get a NSURL object pointing to the URL of the retrieval web service
        let url:URL = URL(string: "https://www.turuncwalks.com/services/twsGetDBversion.php")!
 
        // Get the JSON array of dictionaries from the remote server
        let jsonObjects:[NSDictionary] = self.getRemoteJsonFile(url)
        
        if jsonObjects.count < 1 {
            // Nothing has been returned - possible inernet connection problems
            //NSLog("No jsonObjects returned")
            return (dbversionid,dbversiondate)
        }

            // We have a json object so extract the db version id and date
            let jsonDictionary:NSDictionary = jsonObjects[0]
                dbversionid = Int(jsonDictionary["iddbversion"] as! String)!
                dbversiondate = jsonDictionary["dbversiondate"] as! String
        
       return(dbversionid,dbversiondate)
    }
    
    
    func arrangeRoutesByCategory(routesArray:[Route]) -> [[Route]] {
    
        // Create a separate array of routes of each category and add to an array of routes by category
        
        var currentCategory:Int = 0
        var routesByCategory:[[Route]] = [[Route]]()
        var thisRow:Int = -1
        
        // Sort the routes array(of dictionaries) by route Category
        routesArray.sorted { (route1:Route, route2:Route) -> Bool in
            route1.routeCategory < route2.routeCategory
        }
        
        for index in 0..<routesArray.count {
            if routesArray[index].routeCategory != currentCategory {
                // New category so create a new route array
                //print("category = \(routesArray[index].routeCategory)")
                var newRow:[Route] = [Route]()
                newRow.append(routesArray[index])
                routesByCategory.append(newRow)
                
                currentCategory = routesArray[index].routeCategory
                thisRow += 1
            }
            else {
                // Same as current category so add route to this route array
                
                routesByCategory[thisRow].append(routesArray[index])
            }
        }
        return routesByCategory
        
    }
    
    func getContext() -> NSManagedObjectContext {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
        
    }
    
    func storeRouteList(routes:[[Route]]) {
        // Store a list of routes grouped by category to Core Data
        
        let context = getContext()
        
        // Loop through [[Routes]] to save each route in category order
        for category in routes {
            for route in category {
                //print(route.routeName)
                
                // Retrieve the CoreData entity that stores a route list by category
                
                let entity = NSEntityDescription.entity(forEntityName: "SavedRouteList", in: context)
                
                let thisRoute = NSManagedObject(entity: entity!, insertInto: context)
                
                // Set the entity values
                thisRoute.setValue(route.routeID, forKey: "routeID")
                thisRoute.setValue(route.routeName, forKey: "routeName")
                thisRoute.setValue(route.routeImageFile, forKey: "routeImageFile")
                thisRoute.setValue(route.routeCategoryName, forKey: "routeCategoryName")
                thisRoute.setValue(route.routeCategory, forKey: "routeCategory")
                thisRoute.setValue(route.routeDistance, forKey: "routeDistance")
                thisRoute.setValue(route.routeTime, forKey: "routeTime")
                
                
                // Save the object
                do {
                    try context.save()
                    //print("Saved: \(route.routeName)")
                } catch {
                    //print("Could not save \(error)")
                }
            }
        }
    }
    
    func getStoredRouteList() -> [[Route]] {
        // Retrieve a route list from Core Data (sorted by category)
        //print("Retrieving stored routes...")
        var routeListArray:[Route] = [Route]()
        var routesByCategory:[[Route]] = [[Route]]()
        
        
        let context = getContext()
        // Retrieve the CoreData entity that stores a route list by category
        let entity = NSEntityDescription.entity(forEntityName: "SavedRouteList", in: context)
        // First create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<SavedRouteList> = SavedRouteList.fetchRequest()
        //let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedRouteList")
        fetchRequest.entity = entity
        
        do {
            // Get the results
            let retrievedRouteArray = try context.fetch(fetchRequest)
            
            //print("number of results = \(retrievedRouteArray.count)")
            
            for route in retrievedRouteArray {
                // Create a route object
                
                let routeObject:Route = Route()
                
                // Assign the value of each key value pair to the route object
                routeObject.routeID = Int(route.routeID)
                routeObject.routeName = route.routeName!
                routeObject.routeImageFile = route.routeImageFile!
                routeObject.routeCategoryName = route.routeCategoryName!
                routeObject.routeCategory = Int(route.routeCategory)
                routeObject.routeDistance = route.routeDistance
                routeObject.routeTime = route.routeTime
                
                //print("\(Int(route.routeID))")
                //print("\(route.routeName)")
                
                // Add the route to the route array
                routeListArray.append(routeObject)
            }
            
            
            // We have the list of routes sorted in Category order
            // Now we need to split each category into a separate array
            //print("routeListArray.count = \(routeListArray.count)")
            
            routesByCategory = arrangeRoutesByCategory(routesArray: routeListArray)
            
        } catch {
            print("Error retrieving the stored route list. \(error)")
        }
        return routesByCategory
        
        
    }
    
    func deleteStoredRouteList() {
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedRouteList")
        
        // Create batch delete request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        // Get reference to the persistent containeer
        let context = getContext()
        
        do {
            
            try context.execute(batchDeleteRequest)
            //print("Old list deleted successfully")
            
        } catch {
            
            //print("Error deleting the stored route list. \(error)")
            
        }
        
        
    }
    
    func getrouteversion(routeid: Int) -> (routeversion: Int, routeversiondate: String) {
        // Function to get the current database version from the remote server
        var routeversion:Int = 0
        var routeversiondate:String = ""
        
        // Get a NSURL object pointing to the URL of the retrieval web service
        let url:URL = URL(string: "https://www.turuncwalks.com/services/twsGetrouteversion.php?id=" + String(routeid))!
        
        // Get the JSON array of dictionaries from the remote server
        let jsonObjects:[NSDictionary] = self.getRemoteJsonFile(url)
        
        if jsonObjects.count < 1 {
            // Nothing has been returned - possible inernet connection problems
            //NSLog("No jsonObjects returned")
            return (routeversion,routeversiondate)
        }
        
        // We have a json object so extract the db version id and date
        let jsonDictionary:NSDictionary = jsonObjects[0]
        routeversion = Int(jsonDictionary["routeversion"] as! String)!
        routeversiondate = jsonDictionary["routeversiondate"] as! String
        
        return(routeversion,routeversiondate)
    }

    func storeRoute(route:Route) {
        // Function to store a selected route in Core Data
        
        let context = getContext()
                
                // Retrieve the CoreData entity that stores a route list by category
                
                let entity = NSEntityDescription.entity(forEntityName: "SavedRoute", in: context)
                
                let thisRoute = NSManagedObject(entity: entity!, insertInto: context)
                
                // Set the entity values
                thisRoute.setValue(route.routeID, forKey: "routeID")
                thisRoute.setValue(route.routeName, forKey: "routeName")
                thisRoute.setValue(route.routeImageFile, forKey: "routeImageFile")
                thisRoute.setValue(route.routeCategoryName, forKey: "routeCategoryName")
                thisRoute.setValue(route.routeDistance, forKey: "routeDistance")
                thisRoute.setValue(route.routeTime, forKey: "routeTime")
                thisRoute.setValue(route.routeDesc, forKey: "routeDesc")
                thisRoute.setValue(route.routeDetails, forKey: "routeDetails")
                thisRoute.setValue(route.routeImageCaption, forKey: "routeImageCaption")
                thisRoute.setValue(route.routeImageDesc, forKey: "routeImageDesc")
                thisRoute.setValue(route.sectionCount, forKey: "sectionCount")
                thisRoute.setValue(route.routeGPXFileName, forKey: "routeGPXFileName")
                
                
                // Save the object
                do {
                    try context.save()
                    //print("Route saved to Core Data: \(route.routeName)")
                } catch {
                    //print("Could not save \(error)")
                }
        
    }

    
    func getStoredRoute(routeID: Int) -> Route {
        // Function to get a stored route from Core Data
        var retrievedRoute:Route = Route()
        //print ("Retrieving stored route...")
        
        let context = getContext()
        // Retrieve the CoreData entity that stores a route list by category
        let entity = NSEntityDescription.entity(forEntityName: "SavedRoute", in: context)
        // First create a fetch request, telling it about the entity
        let predicate1 = NSPredicate(format: "routeID = " + String(routeID))
        
        let fetchRequest: NSFetchRequest<SavedRoute> = SavedRoute.fetchRequest()
        fetchRequest.predicate = predicate1
        fetchRequest.entity = entity
        
        do {
            // Get the results
            let route:Route = Route()
            let retrievedroute = try context.fetch(fetchRequest)
            
            //print("number of results = \(retrievedroute.count)")
            
            for route in retrievedroute {
                // Assign the value of each key value pair to the route object
                retrievedRoute.routeID = Int(route.routeID)
                retrievedRoute.routeName = route.routeName!
                retrievedRoute.routeImageFile = route.routeImageFile!
                retrievedRoute.routeCategoryName = route.routeCategoryName!
                retrievedRoute.routeDistance = route.routeDistance
                retrievedRoute.routeTime = route.routeTime
                retrievedRoute.routeDesc = route.routeDesc!
                retrievedRoute.routeDetails = route.routeDetails!
                retrievedRoute.routeImageCaption = route.routeImageCaption!
                retrievedRoute.sectionCount = Int(route.sectionCount)
                retrievedRoute.routeGPXFileName = route.routeGPXFileName!

                //print("Local route retrieved: \(route.routeName)")
            }

            
            
            
        } catch {
            //print("Error retrieving the stored route. \(error)")
        }
        
        return retrievedRoute
    }
    
    func deleteStoredRoute (routeid: Int) {
        // Delete the stored route from Core Data for a given route
        //print("Deleting stored route images from Core Data...")
        
        // Get reference to the persistent containeer
        let context = getContext()
        
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedRoute")
        let predicate1 = NSPredicate(format: "routeID = " + String(routeid))
        fetchRequest.predicate = predicate1
        
        // Create batch delete request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            
            try context.execute(batchDeleteRequest)
            //print("Old route deleted successfully.")
            
        } catch {
            
            //print("Error deleting the stored route. \(error)")
            
        }
        
    }
    
    func storeRouteMarkers(routeID: Int,routeMarkers: [NSDictionary]) {
        // Store the route markers for a specified route in Core Data
        
        let context = getContext()
        //print("Storing: \(routeMarkers.count) route markers for route: \(routeID).")
        for routeMarker in routeMarkers {
            // Retrieve the CoreData entity that stores a route list by category
            //print("routemarkerseq: \(routeMarker["seq"])")
            let entity = NSEntityDescription.entity(forEntityName: "SavedRouteMarkers", in: context)
            
            let thisMarker = NSManagedObject(entity: entity!, insertInto: context)
            
            // Set the entity values
            thisMarker.setValue(routeID, forKey: "routeID")
            thisMarker.setValue((routeMarker["seq"] as! NSString).integerValue, forKey: "markerseq")
            thisMarker.setValue(routeMarker["lat"], forKey: "markerlat")
            thisMarker.setValue(routeMarker["lon"], forKey: "markerlon")
            thisMarker.setValue(routeMarker["name"], forKey: "markername")
            
            // Save the object
            do {
                try context.save()
                //print("Route markers saved to Core Data. ")
                } catch {
                //print("Could not save route markers \(error)")
                }
            
        }
        
    }
    
    func getStoredRouteMarkers(routeID: Int) -> ([NSDictionary]) {
        // Get the route markers for a specified route from Core Data
        var routeMarkers:[NSDictionary] = [NSDictionary]()
        
        //var retrievedRoute:Route = Route()
        //print ("Retrieving stored route markers...")
        
        let context = getContext()
        // Retrieve the CoreData entity that stores the route markers for a specified route
        let entity = NSEntityDescription.entity(forEntityName: "SavedRouteMarkers", in: context)
        // First create a fetch request, telling it about the entity
        let predicate1 = NSPredicate(format: "routeID = " + String(routeID))
        
        let fetchRequest: NSFetchRequest<SavedRouteMarkers> = SavedRouteMarkers.fetchRequest()
        fetchRequest.predicate = predicate1
        
        fetchRequest.entity = entity
        
        do {
            // Get the results
            let retrievedroutemarkers = try context.fetch(fetchRequest)
            
            //print("number of results = \(retrievedroutemarkers.count)")
            
            for routeMarker in retrievedroutemarkers {
                // Assign the value of each key value pair to the route object
                var thisroutemarker:[String:String] = [String:String]()
                
                thisroutemarker["routeID"] = String(routeMarker.routeID)
                thisroutemarker["seq"] = String(routeMarker.markerseq)
                thisroutemarker["lat"] = routeMarker.markerlat
                thisroutemarker["lon"] = routeMarker.markerlon
                thisroutemarker["name"] = routeMarker.markername
                routeMarkers.append(thisroutemarker as NSDictionary)
                //print("Route marker lat: \(thisroutemarker["lat"])")
            }
            
        } catch {
            print("Error retrieving the stored route. \(error)")
        }
        
        return routeMarkers
    }
    
    func deleteStoredRouteMarkers(routeID:Int) {
        // Delete the stored route markers from Core Data for the specified route
         // Get reference to the persistent containeer
        let context = getContext()
        
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedRouteMarkers")
        let predicate1 = NSPredicate(format: "routeID = " + String(routeID))
        fetchRequest.predicate = predicate1
        
        // Create batch delete request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
       
        do {
            
            try context.execute(batchDeleteRequest)
            //print("Old route markers deleted successfully")
            
        } catch {
            
            //print("Error deleting the stored route markers. \(error)")
            
        }
   
    }
    
    func storeRouteImages(routeImagesArray: [NSDictionary]) {
        // Store the section images in Core Data for a given route
        //print("Storing route images in Core Data....")
        //print ("Number of records in routeImagesArray= \(routeImagesArray.count)")
        let context = getContext()
        for routeImage in routeImagesArray {
            // Retrieve the CoreData entity that stores a section image
            let entity = NSEntityDescription.entity(forEntityName: "SavedRouteImages", in: context)
            let thisRouteImage = NSManagedObject(entity: entity!, insertInto: context)
            // Set the entity values
            
            thisRouteImage.setValue((routeImage["fk_idRoute"] as! NSString).intValue, forKey: "fk_idRoute")
            thisRouteImage.setValue((routeImage["fk_idImage"] as! NSString).intValue, forKey: "fk_idImage")
            thisRouteImage.setValue((routeImage["idRouteImage"] as! NSString).intValue, forKey: "idRouteImage")
            thisRouteImage.setValue((routeImage["appImage"] as! NSString).intValue, forKey: "appImage")
            thisRouteImage.setValue(routeImage["routeName"], forKey: "routeName")
            thisRouteImage.setValue(routeImage["routeDesc"], forKey: "routeDesc")
            thisRouteImage.setValue(routeImage["imageFile"], forKey: "imageFile")
            thisRouteImage.setValue(routeImage["imageCaption"], forKey: "imageCaption")
            thisRouteImage.setValue(routeImage["imageDesc"], forKey: "imageDesc")
            
            // Save the object
            do {
                try context.save()
                //print("Saved: \(routeImage["imageFile"])")
            } catch {
                //print("Could not save route image \(error)")
            }
        }
    }
    
    func getStoredRouteImages(routeID:Int) -> [NSDictionary] {
        // Get the stored images from Core Data for a given route
        //print("Getting stored route images from Core Data....")
        var routeImagesDictArray:[NSDictionary] = [NSDictionary]()
        
        let context = getContext()
        // Retrieve the CoreData entity that stores route images
        let entity = NSEntityDescription.entity(forEntityName: "SavedRouteImages", in: context)
        // First create a fetch request, telling it about the entity
        let predicate1 = NSPredicate(format: "fk_idRoute = " + String(routeID))
        let fetchRequest: NSFetchRequest<SavedRouteImages> = SavedRouteImages.fetchRequest()
        fetchRequest.predicate = predicate1
        fetchRequest.entity = entity
        do {
            // Get the results
            let retrievedRouteImagesArray = try context.fetch(fetchRequest)
            for routeImage in retrievedRouteImagesArray {
                // Create route image object
                let routeImageObject: [NSDictionary] = [NSDictionary]()
                
                // Assign the value of each key value pair to the route object
                var thisRouteImage:[String:String] = [String:String]()
                
                thisRouteImage["fk_idRoute"] = String(routeImage.fk_idRoute)
                thisRouteImage["fk_idImage"] = String(routeImage.fk_idImage)
                thisRouteImage["idRouteImage"] = String(routeImage.idRouteImage)
                thisRouteImage["appImage"] = String(routeImage.appImage)
                thisRouteImage["routeName"] = routeImage.routeName
                thisRouteImage["routeDesc"] = routeImage.routeDesc
                thisRouteImage["imageFile"] = routeImage.imageFile
                thisRouteImage["imageCaption"] = routeImage.imageCaption
                thisRouteImage["imageDesc"] = routeImage.imageDesc
                
                // Add the image to the section images array
                routeImagesDictArray.append(thisRouteImage as NSDictionary)
                
            }
        } catch {
            //print("Error retrieving stored route images: \(error)")
        }
        
        return routeImagesDictArray
        
    }
 
    func deleteStoredRouteImages(routeID:Int) {
        // Delete the stored route images from Core Data for a given route
        //print("Deleting stored route images from Core Data...")
        
        // Get reference to the persistent containeer
        let context = getContext()
        
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedRouteImages")
        let predicate1 = NSPredicate(format: "fk_idRoute = " + String(routeID))
        fetchRequest.predicate = predicate1
        
        // Create batch delete request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            
            try context.execute(batchDeleteRequest)
            //print("Old route images deleted successfully.")
            
        } catch {
            
            //print("Error deleting the stored route images. \(error)")
            
        }
    }

    
}
