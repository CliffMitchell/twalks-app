//
//  mapViewController.swift
//  TWalks
//
//  Created by Cliff Mitchell on 21/12/2016.
//  Copyright © 2016 Cliff Mitchell. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class mapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {


    @IBOutlet weak var mapView: MKMapView!
    let locationManager:CLLocationManager = CLLocationManager()
    
    var routeMarkers:[NSDictionary] = [[String:String]]() as [NSDictionary]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set self as delegate for the map view
        mapView.delegate = self
        
        // Set self as delegate for the location manager
        self.locationManager.delegate = self
        
        // Set distance filter
        self.locationManager.distanceFilter = 5
        
        // Manage user permission to use location services
        
        let authorizationstatus:CLAuthorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationstatus {
        case CLAuthorizationStatus.denied:
            // Tell the user their location cannot be shown
            let alertController:UIAlertController = UIAlertController(title: "Dismiss", message: "You have denied access to location services so we cannot show your location.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            
        case CLAuthorizationStatus.notDetermined:
            // Prompt the user for permission
            locationManager.requestWhenInUseAuthorization()
            
        case CLAuthorizationStatus.authorizedWhenInUse:
            // Start updating locations
            self.locationManager.startUpdatingLocation()
            
        default:
            // Start updating locations
            self.locationManager.startUpdatingLocation()
        }
        
        // Show user location
        self.mapView.showsUserLocation = true

        
        // Set the map view to be the location of the first route marker
        // Get location of first route marker.
        let startwaypoint = routeMarkers[0]
        let startlat:Double = (startwaypoint["lat"] as! NSString).doubleValue
        let startlon:Double = (startwaypoint["lon"] as! NSString).doubleValue
        
        var location = CLLocationCoordinate2D(latitude: startlat, longitude: startlon)
        
        // Create a span
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        
        // Create region
        let region = MKCoordinateRegion(center: location, span: span)
        
        // Set the region for the map
        self.mapView.setRegion(region, animated: true)
        
        // Loop through the way points array of dictionaries and add map pins for each way point
        var pathList = [CLLocationCoordinate2D]() // array to hold the path coordinates
        for wayPoint in routeMarkers {
            
            let lat:Double = (wayPoint["lat"] as! NSString).doubleValue
            let lon:Double = (wayPoint["lon"] as! NSString).doubleValue
            location = CLLocationCoordinate2DMake(lat as CLLocationDegrees, lon as CLLocationDegrees)
            
            let pin = MKPointAnnotation()
            pin.coordinate = location
            pin.title = wayPoint["name"] as? String
            pin.subtitle = wayPoint["seq"] as? String
            self.mapView.addAnnotation(pin)
            //print(lat,lon, wayPoint["name"]!)
            
            // Add the location to the array of coordinates for the MKPolyline
            pathList.append(location)

        }
        
        let path = MKPolyline(coordinates: pathList, count: pathList.count)
        
        self.mapView.add(path)

    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay.isKind(of: MKPolyline.self) {
            // Draw the track
            let polyLine = overlay
            let polyLineRenderer = MKPolylineRenderer(polyline: polyLine as! MKPolyline)
            polyLineRenderer.strokeColor = UIColor.blue
            polyLineRenderer.lineWidth = 2.0
            return polyLineRenderer
        }
        return MKPolylineRenderer()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // If it's the user location, just use the default annotation
        if (annotation .isKind(of: MKUserLocation.self)) {
            return nil
        }
        // Define the custom annotation
        
        if(annotation.isKind(of: MKPointAnnotation.self)) {
            let annotationView = MKPinAnnotationView()
            // Add label to pin
            
            let lbl:UILabel = UILabel.init(frame: CGRect(x: 10, y: 10, width: 30, height: 30))
            lbl.backgroundColor = UIColor.white
            lbl.textColor = UIColor.black
            lbl.alpha = 0.5
            lbl.tag = 1
            lbl.text = annotation.subtitle!
            annotationView.addSubview(lbl)

            // Set pin details
            annotationView.pinTintColor = UIColor.blue
            annotationView.isEnabled = true
            annotationView.canShowCallout = true
            annotationView.frame = lbl.frame
            return annotationView
             }
       return nil
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
    
    @IBAction func segmentedControlAction(_ sender: UISegmentedControl) {
        // Select map type to display
        switch (sender.selectedSegmentIndex) {
        case 0:
            mapView.mapType = MKMapType.standard
        case 1:
            mapView.mapType = MKMapType.satellite
        case 2:
            mapView.mapType = MKMapType.hybrid
        default:
            mapView.mapType = MKMapType.standard
        }
    
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // NSLog("Found")
        if locations.count > 0 {
            // Update the map with the location
            // Get the coordinate
            let location = locations[0] as CLLocation
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // Handle location errors
        //NSLog("Error in locating")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.denied {
            // Tell the user their location cannot be tracked
            let alertController:UIAlertController = UIAlertController(title: "Dismiss", message: "You have denied access to location services so we cannot show your location.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertController, animated: true, completion: nil)
   
        }
        else if status == CLAuthorizationStatus.authorizedWhenInUse  || status == CLAuthorizationStatus.authorizedAlways {
            // Enable location updating
            self.locationManager.startUpdatingLocation()
        }
        
    }
}
