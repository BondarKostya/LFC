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
    
    var photos = [Photo]()
    var selectedPhoto:Photo?
    var bbox = AppParameters.sharedInstance.standartBBOX
    var page = 1
    
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
        layout.sectionInset = UIEdgeInsets(top: 2, left: 2, bottom: 2, right: 2)
        layout.itemSize = CGSize(width: screenWidth/3 - 2, height: screenWidth/3 - 2)
        layout.minimumLineSpacing = 1
        layout.minimumInteritemSpacing = 1
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
    
    func setupLocation()
    {
        LFCLocationManager.sharedInstance.bboxDelegate = self
        LFCLocationManager.sharedInstance.setupLocation()
        
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
extension GalleryVC : BBOXChangeDelegate
{
    
    func bboxChanged(bbox: String) {
        self.bbox = bbox
        self.photos = [Photo] ()
        self.loadPhotos()
    }

    
}

extension GalleryVC : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDataSourcePrefetching
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let galleryPhotoCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryPhotoCVC", for: indexPath) as! GalleryPhotoCVC

        let photo = self.photos[indexPath.row]
        
        if(photo.photoImageThumbnail != nil)
        {
            galleryPhotoCVC.imageView.image = photo.photoImageThumbnail
        }else{
            let hud = MBProgressHUD.showAdded(to: galleryPhotoCVC.imageView, animated: true)
            //hud.mode = .determinate
            hud.contentColor = UIColor.lightGray
            hud.bezelView.style = .solidColor
            hud.bezelView.color = UIColor.clear
            galleryPhotoCVC.imageView.sd_setImage(with: photo.photoURLThumbnail!, completed: { (image, error, cashetype, url) in
                photo.photoImageThumbnail = image
                MBProgressHUD.hide(for: galleryPhotoCVC.imageView, animated: true)
            })
        }
        
        galleryPhotoCVC.imageView.contentMode = .scaleAspectFill
        
        if ( indexPath.row == self.photos.count - 1)
        {
            self.page = self.page + 1
            self.loadPhotos()
        }
        
        return galleryPhotoCVC
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.photos.count
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
    
        let backgroundImage = UIImageView(frame: self.view.frame)
        backgroundImage.image = UIImage(named: "background")
        self.view.insertSubview(backgroundImage, at: 0)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
}
