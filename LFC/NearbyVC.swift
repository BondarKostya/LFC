//
//  NearbyVC.swift
//  LFC
//
//  Created by mini on 10/4/16.
//  Copyright © 2016 bondar. All rights reserved.
//

import UIKit
import MBProgressHUD
import CoreLocation

class NearbyVC : UIViewController {

    @IBOutlet weak var messageLabel: UILabel!

    var galleryVC: GalleryVC?
    var bbox = AppConstants.standartBBOX
    var locationManager: LocationManager?

    override func viewDidLoad()
    {
        self.setBackgroundImage()
        
        self.title = "Nearby"
        self.setupLocation()
        
        if let galleryVC = self.childViewControllers.last as? GalleryVC{
            self.galleryVC = galleryVC
            galleryVC.galleryDelegate = self
            galleryVC.reloadData()
        }
        
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }
    
    deinit {
        self.locationManager?.removeDelegate(delegate: self)
    }

    func errorHandler(_ error: Error)
    {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        MBProgressHUD.hide(for: self.view, animated: true)

    }

    func setupLocation()
    {
        self.locationManager = LocationManager()
        self.locationManager?.addDelegate(delegate: self)
    }

    func loadPhotosFromFlickr(page: Int)
    {
        if self.bbox == AppConstants.standartBBOX
        {
            self.messageLabel.text = "No results\nfor your current location"
            return;
        }else
        {
            self.messageLabel.text = ""
        }
        MBProgressHUD.hide(for: self.view, animated: true)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        hud.contentColor = UIColor.lightGray
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor.clear
        FlickrAPIClient.sharedInstance.searchPhotos(withParameters: .positionSearch(limit: AppConstants.pageLimit, page: page, bbox: self.bbox), callback: { [weak weakSelf = self] (loadedPhotos,error) in
            guard let strongSelf = weakSelf else
            {
                return
            }
            if(error != nil) {
                DispatchQueue.main.async {
                    strongSelf.errorHandler(error!)
                }
                return
            }
            MBProgressHUD.hide(for: weakSelf!.view, animated: true)
            if(loadedPhotos.count == 0 && page == 1)
            {
                strongSelf.messageLabel.text = "No results\nfor your current location"
                return;
            }else
            {
                strongSelf.messageLabel.text = ""
            }
            
            strongSelf.galleryVC!.addPhotos(photos: loadedPhotos)

            strongSelf.galleryVC!.reloadData()
        })
    }

}

extension NearbyVC : GalleryDelegate
{
    func loadPhotos(page: Int)
    {
        self.loadPhotosFromFlickr(page: page)
    }

    func photoDidSelect(_ selectedItem: Photo)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let photoDetailVC = storyboard.instantiateViewController(withIdentifier: "PhotoDetailVC") as! PhotoDetailVC
        photoDetailVC.image = selectedItem
        self.navigationController?.pushViewController(photoDetailVC, animated: true)
    }
}

extension NearbyVC : LocationManagerDelegate
{

    func locationChanged(location: CLLocation?)
    {
        guard let location = location else {
            return
        }
        self.bbox = LocationSquare.calculateLocationSquare(location: location, rangeInMeters: 1000)
        self.galleryVC!.clearPhotos()
        self.galleryVC!.reloadData()
    }
}

extension UIViewController{

    func setBackgroundImage(){
        self.navigationController?.navigationBar.barTintColor = UIColor.black

        self.tabBarController?.tabBar.barTintColor = UIColor.black
        self.tabBarController?.tabBar.tintColor = UIColor.white

        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : Any]
        self.navigationController?.navigationBar.tintColor = UIColor.white

        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "background")!)

        let backgroundImage = UIImageView(frame: self.view.frame)
        backgroundImage.image = UIImage(named: "background")
        self.view.insertSubview(backgroundImage, at: 0)

        UIApplication.shared.statusBarStyle = .lightContent
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    func dismissKeyboard()
    {
        if view.gestureRecognizers != nil {
            for gesture in view.gestureRecognizers! {
                if let recognizer = gesture as? UITapGestureRecognizer {
                    view.removeGestureRecognizer(recognizer)
    }
            }
        }
        view.endEditing(true)
    }
}
