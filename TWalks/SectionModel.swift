//
//  SectionModel.swift
//  TWalks
//
//  Created by Cliff Mitchell on 31/08/2016.
//  Copyright © 2016 Cliff Mitchell. All rights reserved.
//

import UIKit
import CoreData

class SectionModel: NSObject {

    
    
    func getSections(_ routeID:Int) -> [Section] {
        
        // Function to retrieve a list of all sections for given route from the server
        
        //Arrray of Route objects to return
        var retrievedSections:[Section] = [Section]()
      
        // Get a NSURL object pointing to the URL of the retrieval web service
        let url:URL = URL(string: "https://www.turuncwalks.com/services/twsSelSections4Route.php?id=" + String(routeID))!
        
        
        // Get the JSON array of dictionaries
        let jsonObjects:[NSDictionary] = self.getRemoteJsonFile(url)
        
        //Loop through each dictionary and passing values to our Route objects
        
        for index in 0..<jsonObjects.count {
            
            // Current json dictionary
            let jsonDictionary:NSDictionary = jsonObjects[index]
            
            // Create a Section object
            
            let sectionObject:Section = Section()
            
            // Assign the value of each key value pair to the section object
            
            sectionObject.idRouteSection = Int(jsonDictionary["idRouteSection"] as! String)!
            sectionObject.idRoute = Int(jsonDictionary["idRoute"] as! String)!
            sectionObject.idSection = Int(jsonDictionary["idSection"] as! String)!
            sectionObject.sectionName = jsonDictionary["sectionName"] as! String
            sectionObject.sectionDesc = jsonDictionary["sectionDesc"] as! String
            // Strip out any HTML tags from the description
            sectionObject.sectionDesc = sectionObject.sectionDesc.replacingOccurrences(of: "<[^>]+>", with: "", options:  .regularExpression, range: nil)
            sectionObject.routeSectionSeq = Int(jsonDictionary["routeSectionSeq"] as! String)!
       
            
            // Add the Section to the Section array
            retrievedSections.append(sectionObject)
            
        }
        
        // Sort retrieved Sections array(of dictionaries) by routeSectionSeq
        retrievedSections.sort { (section1:Section, section2:Section) -> Bool in
            section1.routeSectionSeq < section2.routeSectionSeq
        }
        
        return retrievedSections
    }
    
    
    
    func getRemoteJsonFile(_ url:URL) -> [NSDictionary] {
        
        //Function to retrieve the json Route file from the server at the given url
        
        let jsonData:Data? = try? Data(contentsOf: url)
        
        if let actualJsonData = jsonData {
            
            // NSData exists, use the NSJSONSerialization classes to parse the data and create the dictionaries
            
            do {
                let arrayOfSections:[NSDictionary] = try JSONSerialization.jsonObject(with: actualJsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as! [NSDictionary]
                return arrayOfSections
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
    

    func getSectionImages4Route(_ routeID:Int) -> [NSDictionary] {
        
        // Get all of the images associated with each Section in the specified Route and 
        // return an array of dictionary arrays containing the section image details.
        
        // Get a NSURL object poiting to the URL of the retrieval web service
        let url:URL = URL(string: "https://www.turuncwalks.com/services/twsSelImagesBySection4Route.php?id=" + String(routeID))!
        
        //Function to retrieve the json Section image file from the server at the given url
        
        let jsonData:Data? = try? Data(contentsOf: url)
        
        if let actualJsonData = jsonData {
            
            // NSData exists, use the NSJSONSerialization classes to parse the data and create the dictionaries
            
            do {
                let arrayOfSectionImages:[NSDictionary] = try JSONSerialization.jsonObject(with: actualJsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as! [NSDictionary]
                //print("In getSectionImages4Route records returned = \(arrayOfSectionImages.count)")
                return arrayOfSectionImages
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
    
    func getContext() -> NSManagedObjectContext {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func storeRouteSections(sectionsArray:[Section]) {
        // Store the sections for a given route in Core Data
        //print("Storing sections in Core Data...")
        let context = getContext()
        for section in sectionsArray {
            // Retrieve the CoreData entity that stores a route section
            
            let entity = NSEntityDescription.entity(forEntityName: "SavedRouteSections", in: context)
            let thisSection = NSManagedObject(entity: entity!, insertInto: context)
            // Set the entity values
            thisSection.setValue(section.idRouteSection, forKey: "idRouteSection")
            thisSection.setValue(section.idRoute, forKey: "idRoute")
            thisSection.setValue(section.idSection, forKey: "idSection")
            thisSection.setValue(section.sectionName, forKey: "sectionName")
            thisSection.setValue(section.sectionDesc, forKey: "sectionDesc")
            thisSection.setValue(section.routeSectionSeq, forKey: "routeSectionSeq")
            // Save the object
            do {
                try context.save()
                //print("Saved: \(section.sectionName)")
            } catch {
                //print("Could not save section \(error)")
            }
        }
    }
    
    func getStoredRouteSections(routeID:Int) -> [Section] {
        // Get the stored sections array from Core Data for a given route
        //print("Getting stored sections from Core Data...")
        var sectionsArray:[Section] = [Section]()
       
        let context = getContext()
        
        // Retrieve the CoreData entity that stores a route list by category
        let entity = NSEntityDescription.entity(forEntityName: "SavedRouteSections", in: context)
        let predicate1 = NSPredicate(format: "idRoute = " + String(routeID))
        
        // First create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<SavedRouteSections> = SavedRouteSections.fetchRequest()
        fetchRequest.predicate = predicate1
        fetchRequest.entity = entity
        do {
            // Get the results
            let retrievedSectionsArray = try context.fetch(fetchRequest)
        
            for section in retrievedSectionsArray {
                // Create section object
                let sectionObject: Section = Section()
                sectionObject.idRouteSection = Int(section.idRouteSection)
                sectionObject.idRoute = Int(section.idRoute)
                sectionObject.idSection = Int(section.idSection)
                sectionObject.sectionName = section.sectionName!
                sectionObject.sectionDesc = section.sectionDesc!
                sectionObject.routeSectionSeq = Int(section.routeSectionSeq)
                
                // Add the section to the section array
                sectionsArray.append((sectionObject))
            }
            
            
        } catch {
            
            //print("Error retrieving stored sections: \(error)")
        }
        
        
        return sectionsArray
    }
    
    func deleteStoredRouteSections(routeID:Int) {
        // Delete the stored sections from Core Data for a given route
        //print("Deleting stored sections from Core Data...")

        // Get reference to the persistent containeer
        let context = getContext()
        
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedRouteSections")
        let predicate1 = NSPredicate(format: "idRoute = " + String(routeID))
        fetchRequest.predicate = predicate1
        
        // Create batch delete request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            
            try context.execute(batchDeleteRequest)
            //print("Old route sections deleted successfully.")
            
        } catch {
            
            //print("Error deleting the stored route sections. \(error)")
            
        }
    }
    
    func storeRouteSectionImages(sectionImagesArray: [NSDictionary]) {
        // Store the section images in Core Data for a given route
        //print("Storing route section images in Core Data....")
        //print ("Number of records in sectionImagesArray= \(sectionImagesArray.count)")
        let context = getContext()
        for sectionImage in sectionImagesArray {
            // Retrieve the CoreData entity that stores a section image
            let entity = NSEntityDescription.entity(forEntityName: "SavedSectionImages", in: context)
            let thisSectionImage = NSManagedObject(entity: entity!, insertInto: context)
            // Set the entity values
            //print("fk_idSection = \(sectionImage["fk_idSection"])")
            
            thisSectionImage.setValue((sectionImage["fk_idSection"] as! NSString).intValue, forKey: "fk_idSection")
            
            thisSectionImage.setValue((sectionImage["fk_idImage"] as! NSString).intValue, forKey: "fk_idImage")
            thisSectionImage.setValue((sectionImage["idSectionImage"] as! NSString).intValue, forKey: "idSectionImage")
            thisSectionImage.setValue(sectionImage["sectionName"], forKey: "sectionName")
            thisSectionImage.setValue(sectionImage["imageFile"], forKey: "imageFile")
            thisSectionImage.setValue(sectionImage["imageCaption"], forKey: "imageCaption")
            thisSectionImage.setValue(sectionImage["imageDesc"], forKey: "imageDesc")
            thisSectionImage.setValue((sectionImage["fk_idRoute"] as! NSString).intValue, forKey: "fk_idRoute")
            // Save the object
            do {
                try context.save()
                //print("Saved: \(sectionImage["imageFile"])")
            } catch {
                //print("Could not save section image \(error)")
            }
        }
    }
    
    func getStoredRouteSectionImages(routeID:Int) -> [NSDictionary] {
        // Get the stored section images from Core Data for a given route
        //print("Getting stored route section images from Core Data....")
        var sectionImagesDictArray:[NSDictionary] = [NSDictionary]()
        
        let context = getContext()
        // Retrieve the CoreData entity that stores section images
        let entity = NSEntityDescription.entity(forEntityName: "SavedSectionImages", in: context)
        // First create a fetch request, telling it about the entity
        let predicate1 = NSPredicate(format: "fk_idRoute = " + String(routeID))
        let fetchRequest: NSFetchRequest<SavedSectionImages> = SavedSectionImages.fetchRequest()
        fetchRequest.predicate = predicate1
        fetchRequest.entity = entity
        do {
            // Get the results
            // Get the results
            let retrievedSectionImagesArray = try context.fetch(fetchRequest)
            for sectionImage in retrievedSectionImagesArray {
                // Create section image object
                let sectionImageObject: Section = Section()

                // Assign the value of each key value pair to the route object
                var thisSectionImage:[String:String] = [String:String]()
                
                thisSectionImage["fk_idSection"] = String(sectionImage.fk_idSection)
                thisSectionImage["fk_idImage"] = String(sectionImage.fk_idImage)
                thisSectionImage["idSectionImage"] = String(sectionImage.idSectionImage)
                thisSectionImage["sectionName"] = sectionImage.sectionName
                thisSectionImage["imageFile"] = sectionImage.imageFile
                thisSectionImage["imageCaption"] = sectionImage.imageCaption
                thisSectionImage["imageDesc"] = sectionImage.imageDesc
                thisSectionImage["fk_idRoute"] = String(sectionImage.fk_idRoute)
                
                // Add the image to the section images array
                sectionImagesDictArray.append(thisSectionImage as NSDictionary)
        
                }
            } catch {
                //print("Error retrieving stored section images: \(error)")
            }
        
        return sectionImagesDictArray
        
    }
    
    func deleteStoredRouteSectionImages(routeID:Int) {
        // Deleter the stored section images from Core Data for a given route
        //print("Deleting stored route section image from Core Data...")
        
        // Get reference to the persistent containeer
        let context = getContext()
        
        // Create fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedSectionImages")
        let predicate1 = NSPredicate(format: "fk_idRoute = " + String(routeID))
        fetchRequest.predicate = predicate1
        
        // Create batch delete request
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            
            try context.execute(batchDeleteRequest)
            //print("Old route sections images deleted successfully.")
            
        } catch {
            
            //print("Error deleting the stored route section images. \(error)")
            
        }
    }
}

