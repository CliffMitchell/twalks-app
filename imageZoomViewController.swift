//
//  imageZoomViewController.swift
//  
//
//  Created by Cliff Mitchell on 20/09/2016.
//
//

import UIKit
import ImageScrollView

class imageZoomViewController: UIViewController {

    @IBOutlet weak var zoomImageViewLabel: UILabel!
    @IBOutlet weak var zoomImageViewScrollView: ImageScrollView!
    
    
    // Create variables to receive data from the segue
    var zoomImageViewLabelText:String! = nil
    var zoomImageViewImage:UIImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        zoomImageViewLabel.text = zoomImageViewLabelText
        
        
        // Set the image to the image passed on the seque
        // We are using an open source add on called ImageScrollView to handle the zoom/pan functions
        // https://github.com/huynguyencong/ImageScrollView
        
        
        //zoomImageViewScrollView.translatesAutoresizingMaskIntoConstraints = false
        zoomImageViewScrollView.display(image: zoomImageViewImage)

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
