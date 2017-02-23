//
//  Route.swift
//  TWalks
//
//  Created by Cliff Mitchell on 13/12/2015.
//  Copyright © 2015 Cliff Mitchell. All rights reserved.
//

import UIKit

class Route: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var routeID:Int = 0
    var routeName:String = ""
    var routeDesc:String = ""
    var routeDetails:String = ""
    var routeImageID:Int = 0
    var routeImageFile:String = ""
    var routeImage:UIImage = UIImage()
    var routeImageCaption:String = ""
    var routeImageDesc:String = ""
    var routeImageDictArray:[NSDictionary] = [[String:String]]() as [NSDictionary]
    var routeCategory:Int = 0
    var routeCategoryName:String = ""
    var routeDistance:Float = 0
    var routeTime:Float = 0
    var sectionCount:Int = 0
    var routeGPXFileName:String = ""
    var routeMarkers:[NSDictionary] = [[String:String]]() as [NSDictionary]
    var dbversionid:Int = 0
    var dbversiondate:String = ""
}
