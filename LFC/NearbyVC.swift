//
//  NearbyVC.swift
//  LFC
//
//  Created by mini on 10/4/16.
//  Copyright © 2016 bondar. All rights reserved.
//

import UIKit
import MBProgressHUD

class NearbyVC : UIViewController {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!

    var galleryView: Gallery!

    var selectedPhoto: Photo?
    var bbox = AppParameters.sharedInstance.standartBBOX

    override func viewDidLoad()
    {
        self.setBackgroundImage()
        let notificationName = Notification.Name("ErrorHandler")

        NotificationCenter.default.addObserver(self, selector: #selector(NearbyVC.errorHandler), name: notificationName, object: nil)

        self.galleryView = Gallery(with: self.collectionView)
        self.galleryView.galleryDelegate = self
        self.title = "Nearby"
        self.setupLocation()
        // Define identifier


    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    func errorHandler(_ notification: NSNotification)
    {

        guard let error = notification.object as? NSError else
        {
            return
        }
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        MBProgressHUD.hide(for: self.view, animated: true)

    }

    func setupLocation()
    {
        LFCLocationManager.sharedInstance.bboxDelegate = self
        LFCLocationManager.sharedInstance.setupLocation()

    }

    func loadPhotosFromFlickr(page: Int)
    {
        if self.bbox == AppParameters.sharedInstance.standartBBOX
        {
            self.messageLabel.text = "No results\nfor your current location"
            return;
        }else
        {
            self.messageLabel.text = ""
        }
        MBProgressHUD.hide(for: self.view, animated: true)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        //hud.mode = .determinate
        hud.contentColor = UIColor.lightGray
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor.clear
        DataManager.sharedInstance.loadPhotosFromFlickr(withLimit: AppParameters.sharedInstance.pageLimit, page: page, bbox: self.bbox ,searchText: "", callback: { [weak weakSelf = self] (loadedPhotos) in
            guard let strongSelf = weakSelf else
            {
                return
    }
            if(loadedPhotos.count == 0 && page == 1)
            {
                strongSelf.messageLabel.text = "No results\nfor your current location"
                return;
            }else
            {
                strongSelf.messageLabel.text = ""
            }
            MBProgressHUD.hide(for: weakSelf!.view, animated: true)
            strongSelf.galleryView.addPhotos(photos: loadedPhotos)

            strongSelf.galleryView.reloadData()
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "PhotoDetail")
        {
            let photoDetailVC = segue.destination as! PhotoDetailVC

            if let photo = self.selectedPhoto {
                photoDetailVC.image = photo
            }

        }
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
        self.selectedPhoto = selectedItem
        self.performSegue(withIdentifier: "PhotoDetail", sender: self)
    }
}

extension NearbyVC : BBOXChangeDelegate
{

    func bboxChanged(bbox: String)
    {
        self.bbox = bbox
        self.galleryView.clearPhotos()
        self.galleryView.reloadData()
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
