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

}
