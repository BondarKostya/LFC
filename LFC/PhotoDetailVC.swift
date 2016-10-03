//
//  PhotoDetailVC.swift
//  LFC
//
//  Created by Admin on 22.09.16.
//  Copyright © 2016 bondar. All rights reserved.
//

import UIKit
import MBProgressHUD

class PhotoDetailVC: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    var imageView = UIImageView()
    
    weak var image:Photo?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setBackgroundImage()
        self.automaticallyAdjustsScrollViewInsets = false
        if let photo = self.image {
            if(photo.photoImageOriginal != nil)
            {
                self.imageView.image = photo.photoImageOriginal
                self.initScrollView(self.imageView.image!)
            }else{
                let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
                //hud.mode = .determinate
                hud.contentColor = UIColor.lightGray
                hud.bezelView.style = .solidColor
                hud.bezelView.color = UIColor.clear
                self.imageView.sd_setImage(with: photo.photoURLOriginal!, completed: {[weak weakSelf = self] (image, error, cashetype, url) in
                    guard let strongSelf = weakSelf else
                    {
                        return
                    }
                    photo.photoImageOriginal = image
                    strongSelf.initScrollView(image!)
                    MBProgressHUD.hide(for: strongSelf.view, animated: true)
                })
            }
        }
        
    }
    
    func initScrollView(_ image: UIImage)
    {
        print("image")
        let imageSize = image.size
        
        let scale = imageSize.width / imageSize.height
        self.imageView.frame = CGRect.init(x: 0, y: 0, width: (self.view.bounds.size.width), height: (self.view.bounds.size.width) / scale)
        //self.imageView.center = self.scrollView.center;
        self.scrollView.contentSize = self.imageView.bounds.size
        self.scrollView.frame = self.view.frame
        //self.scrollView.autoresizingMask =
        self.scrollView.delegate = self
        
        self.scrollView.addSubview(self.imageView)
        
        setZoomScale()
        self.reSetInsets(scrollView)
    }
    
    
    
    override func viewWillLayoutSubviews() {
        setZoomScale()
    }

    func setZoomScale() {
        let imageViewSize = self.imageView.bounds.size
        let scrollViewSize = self.scrollView.bounds.size
//        let widthScale = scrollViewSize.width / imageViewSize.width
//        let heightScale = scrollViewSize.height / imageViewSize.height
        
        self.scrollView.minimumZoomScale = 0.1
        self.scrollView.maximumZoomScale = 4.0
        self.scrollView.zoomScale = 1.0
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("layout")
        self.reSetInsets(self.scrollView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension PhotoDetailVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        print(scale)
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView)  {
        print(scrollView.zoomScale)
        self.reSetInsets(scrollView)
        //print(scrollView.contentInset)
    }
    
    func reSetInsets(_ scrollView: UIScrollView)
    {
        
        let imageViewSize = imageView.frame.size
        let scrollViewSize = scrollView.bounds.size
        
        let verticalPadding = imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0
        let horizontalPadding = imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0
        
        
        
        scrollView.contentInset = UIEdgeInsets(top: verticalPadding, left: horizontalPadding, bottom: verticalPadding, right: horizontalPadding)
    }
}
