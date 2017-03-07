//
//  imageZoomViewController.swift
//  
//
//  Created by Cliff Mitchell on 20/09/2016.
//
//

import UIKit
//import ImageScrollView

class imageZoomViewController: UIViewController {

    @IBOutlet weak var zoomImageViewLabel: UILabel!
    @IBOutlet weak var zoomImageViewScrollView: UIScrollView!
    @IBOutlet weak var chosenImageView: UIImageView!
    
    // Create size constraints outlets
    
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    
    
    
    // Create variables to receive data from the segue
    var zoomImageViewLabelText:String! = nil
    var zoomImageViewImage:UIImage = UIImage()
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        zoomImageViewLabel.text = zoomImageViewLabelText

        
        // Set the image to the image passed on the seque

        chosenImageView.image = zoomImageViewImage
        view.layoutIfNeeded()
        
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
    
    
    private func updateMinZoomScaleForSize(_ size: CGSize) {
        
        let widthScale = size.width / chosenImageView.bounds.width
        let heightScale = size.height / chosenImageView.bounds.height
        let minScale = min(widthScale, heightScale)
        zoomImageViewScrollView.minimumZoomScale = minScale
        zoomImageViewScrollView.zoomScale = minScale
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        
        let yOffset = max(0, (size.height - chosenImageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - chosenImageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }

}

extension imageZoomViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return chosenImageView
    }


    func scrollViewDidZoom(_ scrollView: UIScrollView) {
    updateConstraintsForSize(view.bounds.size)
    }
}
