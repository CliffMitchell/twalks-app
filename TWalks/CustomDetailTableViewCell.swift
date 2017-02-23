//
//  CustomDetailTableViewCell.swift
//  TWalks
//
//  Created by Cliff Mitchell on 23/04/2016.
//  Copyright © 2016 Cliff Mitchell. All rights reserved.
//

import UIKit
import Kingfisher


class CustomDetailTableViewCell: UITableViewCell, UIScrollViewDelegate {

    @IBOutlet weak var detailDescriptionLabel: UILabel!
    @IBOutlet weak var detailImageView: UIImageView!
    @IBOutlet weak var imageCaption: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!

    let imageHeight:CGFloat = 300.0
    
    override func awakeFromNib() {
       
        super.awakeFromNib()
        // Initialization code

        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
        
    }
    
    func setLabelText(_ text:String) {
        
        // Set the label text and hide the image
        self.detailDescriptionLabel.alpha = 1
        self.detailImageView.alpha = 1
        self.detailDescriptionLabel.text = text
    }
    
    func setDetailImage(_ detailImageFile:String) {

        // Set the image and hide the label
        
        self.detailImageView.kf_setImage(with: URL(string: "https://www.turuncwalks.com/files/images/" + detailImageFile)!, placeholder: UIImage(named: "placeholder400"),
            options: [.transition(.fade(1))],
            progressBlock: nil,
            completionHandler: nil)
        
        self.detailDescriptionLabel.alpha = 1
        self.detailImageView.alpha = 1
            
        // Set translatesautoresizingmask to false
        self.detailImageView.translatesAutoresizingMaskIntoConstraints = false
            
            // set contstraints for the imageview
            let heightConstraint:NSLayoutConstraint = NSLayoutConstraint(item: self.detailImageView, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1, constant: self.imageHeight)
            
            self.detailImageView.addConstraint(heightConstraint)        
        
    }
    
    func setDetailImageCaption (_ caption:String) {
        self.detailDescriptionLabel.alpha = 1
        self.detailImageView.alpha = 1
        self.imageCaption.text = caption
        
    }
    
        
}
