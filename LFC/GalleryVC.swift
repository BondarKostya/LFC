//
//  GalleryVC.swift
//  LFC
//
//  Created by Admin on 22.09.16.
//  Copyright © 2016 bondar. All rights reserved.
//

import UIKit
import FlickrKit
import CoreLocation
import MapKit
import SDWebImage
import MBProgressHUD
enum GalleryState {
    case Gallery
    case GalleryWithSearch
}

class GalleryVC: UIViewController
{
    //MARK: Properties
    @IBOutlet weak var galleryView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var messageLabel: UILabel!
    
    var galleryState = GalleryState.Gallery
    let locationManger:CLLocationManager = CLLocationManager()
    
    var photos = [Photo]()
    var selectedPhoto:Photo?
    
    var page = 1
    var bbox = AppParameters.sharedInstance.standartBBOX
    var searchText = ""
    
    
    //MARK: - LifeCycle
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setBackgroundImage()

        self.galleryView.register(UINib(nibName: "GalleryPhotoCVC", bundle: nil), forCellWithReuseIdentifier: "GalleryPhotoCVC")

        self.galleryInit()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - View Init

    func galleryInit()
    {
        let screenSize = UIScreen.main.bounds
        let screenWidth = screenSize.width
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 0, right: 2)
        layout.itemSize = CGSize(width: screenWidth/3 - 2, height: screenWidth/3 - 2)
        
        layout.minimumInteritemSpacing = 0
        self.galleryView.collectionViewLayout = layout
        
        if(self.tabBarController?.selectedIndex == 0)
        {
            self.galleryState = .Gallery
            self.title = "Nearby"
            self.setupLocation()
        }else
        {
            self.title = "Search Photo"
            self.galleryState = .GalleryWithSearch
            self.searchBar.barTintColor = UIColor.black
            self.searchBar.tintColor = UIColor.white
            let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
            textFieldInsideSearchBar?.textColor = UIColor.white
            self.searchBar.delegate = self
    
            self.hideKeyboardWhenTappedAround()
            let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
            
            UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState.normal)
            self.loadPhotos()
        }
    }
    
    //MARK: - Loading photos
    func loadPhotos()
    {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        //hud.mode = .determinate
        hud.contentColor = UIColor.lightGray
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor.clear
        DataManager.sharedInstance.loadPhotosFromFlickr(withLimit: AppParameters.sharedInstance.pageLimit, page: self.page, bbox: self.bbox ,searchText: self.searchText, callback: { [weak weakSelf = self] (loadedPhotos) in
            MBProgressHUD.hide(for: weakSelf!.view, animated: true)
            guard let strongSelf = weakSelf else
            {
                return
            }
            strongSelf.photos.append(contentsOf: loadedPhotos)
            if(strongSelf.photos.count == 0)
            {
                strongSelf.messageLabel.text = self.galleryState == .Gallery ? "No results\nfor your current location" : "No results"
            }
            strongSelf.galleryView.reloadData()
        })
    }
    

}
extension GalleryVC : CLLocationManagerDelegate
{
    func setupLocation()
    {
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyBest
        if(photos.count == 0)
        {
           if let locationBBOX = self.checkLocation(status: CLLocationManager.authorizationStatus())
           {
                self.bbox = locationBBOX
           }
            
        }
        
    }
    func checkLocation(status: CLAuthorizationStatus) -> String?
    {

        switch status {
        case .authorizedAlways,
             .authorizedWhenInUse:
            guard let location = locationManger.location else
            {
                return nil
            }
            print(location.coordinate.longitude)
            print(location.coordinate.latitude)
            let centerCoord = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
            let region = MKCoordinateRegionMakeWithDistance(centerCoord, 1000, 1000)
            
            let latMin = region.center.latitude - 0.5 * region.span.latitudeDelta;
            let latMax = region.center.latitude + 0.5 * region.span.latitudeDelta;
            let lonMin = region.center.longitude - 0.5 * region.span.longitudeDelta;
            let lonMax = region.center.longitude + 0.5 * region.span.longitudeDelta;
            
            print("\(lonMin),\(latMin),\(lonMax),\(latMax)")
            return "\(lonMin),\(latMin),\(lonMax),\(latMax)"
        default:
            print("Not Authorised")
            locationManger.requestWhenInUseAuthorization()
            return nil
        }

    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus)
    {
        if let locationBBOX = self.checkLocation(status: CLLocationManager.authorizationStatus())
        {
            self.bbox = locationBBOX
            self.photos = [Photo] ()
            self.loadPhotos()
        }
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

extension GalleryVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDataSourcePrefetching
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let galleryPhotoCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryPhotoCVC", for: indexPath) as! GalleryPhotoCVC
        let index = indexPath.section * 3 + indexPath.row
        let photo = self.photos[index]
        if(photo.photoImageThumbnail != nil)
        {
            galleryPhotoCVC.imageView.image = photo.photoImageThumbnail
        }else{
            galleryPhotoCVC.imageView.sd_setImage(with: photo.photoURLThumbnail!, completed: { (image, error, cashetype, url) in
                photo.photoImageThumbnail = image
            })
        }
        
        galleryPhotoCVC.imageView.contentMode = .scaleAspectFill
        
        if ( index == self.photos.count - 1)
        {
            self.page = self.page + 1
            self.loadPhotos()
        }
        
        return galleryPhotoCVC
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return Int(ceil(Double(self.photos.count) / 3.0))
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return (((section + 1) * 3) < self.photos.count ? 3 : 3 - (((section + 1) * 3) - self.photos.count))
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let index = indexPath.section * 3 + indexPath.row
        let photo = self.photos[index]
        self.selectedPhoto = photo
        self.performSegue(withIdentifier: "PhotoDetail", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath])
    {
        print(indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath])
    {
        
    }
}

extension GalleryVC : UISearchBarDelegate
{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.searchText = ""
        searchBar.text = ""
        self.searchAction()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text
        {
            self.searchText = searchText
            self.searchAction()
        }
    }
    
    func searchAction()
    {
        self.page = 1
        self.bbox = AppParameters.sharedInstance.standartBBOX
        self.photos = [Photo]()
        self.galleryView.reloadData()
        self.loadPhotos()
        self.view.endEditing(true)
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
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

extension UIViewController{
    
    func setBackgroundImage(){
        self.navigationController?.navigationBar.barTintColor = UIColor.black
        
        self.tabBarController?.tabBar.barTintColor = UIColor.black
        self.tabBarController?.tabBar.tintColor = UIColor.white
        
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationController?.navigationBar.titleTextAttributes = titleDict as? [String : Any]
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named:"background")!)
        UIApplication.shared.statusBarStyle = .lightContent
    }
}
