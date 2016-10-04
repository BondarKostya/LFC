//
//  GalleryPhotoCVC.swift
//  LFC
//
//  Created by Admin on 22.09.16.
//  Copyright © 2016 bondar. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD

class GalleryPhotoCVC: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageView.image = nil
        self.imageView.sd_cancelCurrentImageLoad()
        MBProgressHUD.hide(for: self.imageView, animated: true)
    }
    
    func setup(with photo: Photo)
    {
        let photo = photo
        
        if(photo.photoImageThumbnail != nil)
        {
            self.imageView.image = photo.photoImageThumbnail
        }else{
            let hud = MBProgressHUD.showAdded(to: self.imageView, animated: true)
            //hud.mode = .determinate
            hud.contentColor = UIColor.lightGray
            hud.bezelView.style = .solidColor
            hud.bezelView.color = UIColor.clear
            self.imageView.sd_setImage(with: photo.photoURLThumbnail!, completed: { (image, error, cashetype, url) in
                if(error != nil)
                {
                    guard let err = error as? NSError else
                    {
                        return
                    }
                    let notificationName = Notification.Name("ErrorHandler")
                    NotificationCenter.default.post(name: notificationName, object: err)
                }
                guard let img = image else
                {
                    return
                }
                photo.photoImageThumbnail = img
                MBProgressHUD.hide(for: self.imageView, animated: true)
            })
        }
        self.imageView.contentMode = .scaleAspectFill
    }

}
