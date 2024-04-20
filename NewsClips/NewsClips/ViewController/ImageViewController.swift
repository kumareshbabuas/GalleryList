//
//  ImageViewController.swift
//  NewsClips
//
//  Created by Kumaresh on 19/04/24.
//

import UIKit
import AVFoundation

class ImageViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrlView: UIScrollView!
    @IBOutlet weak var imgView: UIImageView!
    var image: UIImage?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        imgView.image = image
        scrlView.minimumZoomScale = 1.0
        scrlView.maximumZoomScale = 3.0
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(_:)))
               doubleTapGesture.numberOfTapsRequired = 2
        scrlView.addGestureRecognizer(doubleTapGesture)
    }
       
    @IBAction func dismissTapped(_ sender: Any) {
        self.dismiss(animated: true)
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
           return imgView
       }

    @objc func handleDoubleTap(_ gestureRecognizer: UITapGestureRecognizer) {
            if scrlView.zoomScale == scrlView.minimumZoomScale {
                // Zoom in to a specific point
                let location = gestureRecognizer.location(in: imgView)
                let zoomRect = CGRect(x: location.x, y: location.y, width: 1, height: 1)
                scrlView.zoom(to: zoomRect, animated: true)
            } else {
                // Zoom out to the minimum zoom scale
                scrlView.setZoomScale(scrlView.minimumZoomScale, animated: true)
            }
        }
}
