//
//  customRouteCell.swift
//  TWalks
//
//  Created by Cliff Mitchell on 06/12/2015.
//  Copyright © 2015 Cliff Mitchell. All rights reserved.
//

import UIKit
import Kingfisher

class customRouteCell: UITableViewCell {

    @IBOutlet weak var routeCellLabel: UILabel!
    @IBOutlet weak var routeCellImage: UIImageView!
    @IBOutlet weak var routeCellDistance: UILabel!
    @IBOutlet weak var routeCellTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
 
    
    func setLabelText(_ text:String){
        // Set the route text
        self.routeCellLabel.text = text

    }
    
    func setLabelBackground(_ routeCategoryID:Int) {
        // Set the background colour for the route based on the route category
        
        switch routeCategoryID {
        case 1:
            self.backgroundColor = UIColor(red: 77/255, green: 1.0, blue: 82/255, alpha: 0.05)
        case 2:
            self.backgroundColor = UIColor(red: 265/265 , green: 200/255, blue: 0.0, alpha: 0.1)
        case 3:
            self.backgroundColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.05)
        default:
            self.backgroundColor = UIColor.clear
        }
    }
    
    func setCellImage(_ imageName:String) {
       // Set the route image
        
        self.routeCellImage.kf_setImage(with: URL(string: "https://www.turuncwalks.com/files/images/" + imageName)!, placeholder: UIImage(named: "placeholder50"),
            options: [.transition(.fade(1))],
            progressBlock: nil,
            completionHandler: nil)

    }
    
    func setCellTime(_ routeTime:Float) {
        // Set the route time
        
        self.routeCellTime.text = String(format: "%.1f", routeTime)
        
    }
    
    func setCellDistance(_ routeDistance:Float) {
        // Set the route distance
        
        self.routeCellDistance.text = String(format: "%.1f", routeDistance)

        
    }
    
}
