//
//  Section.swift
//  TWalks
//
//  Created by Cliff Mitchell on 31/08/2016.
//  Copyright © 2016 Cliff Mitchell. All rights reserved.
//

import UIKit

class Section: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

    var idRouteSection:Int = 0
    var idRoute:Int = 0
    var idSection:Int = 0
    var sectionName:String = ""
    var sectionDesc:String = ""
    var routeSectionSeq:Int = 0
    //var idSectionImage:Int = 0
    //var sectionImageFile:String = ""
    //var sectionImage:UIImage = UIImage()
    //var sectionImageCaption:String = ""
    var sectionImageDictArray:[NSDictionary] = [[String:String]]() as [NSDictionary]
    
}
