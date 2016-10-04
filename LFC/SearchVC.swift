//
//  SearchVC.swift
//  LFC
//
//  Created by mini on 10/4/16.
//  Copyright © 2016 bondar. All rights reserved.
//

import UIKit
import MBProgressHUD

class SearchVC : UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!

    @IBOutlet weak var messageLabel: UILabel!

    var galleryView: Gallery!

    var selectedPhoto: Photo?
    var searchText = ""

    override func viewDidLoad()
    {
        self.setBackgroundImage()
        let notificationName = Notification.Name("ErrorHandler")

        NotificationCenter.default.addObserver(self, selector: #selector(NearbyVC.errorHandler), name: notificationName, object: nil)

        self.title = "Search Photo"
        self.searchBar.barTintColor = UIColor.black
        self.searchBar.tintColor = UIColor.white
        let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        self.searchBar.delegate = self

        self.hideKeyboardWhenTappedAround()
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]

        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState.normal)

        self.galleryView = Gallery(with: self.collectionView)
        self.galleryView.galleryDelegate = self
        self.galleryView.reloadData()


    }

    deinit
    {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
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

    func loadPhotosFromFlickr(page: Int)
    {
        MBProgressHUD.hide(for: self.view, animated: true)
        let hud = MBProgressHUD.showAdded(to: self.view, animated: true)
        //hud.mode = .determinate
        hud.contentColor = UIColor.lightGray
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor.clear
        DataManager.sharedInstance.loadPhotosFromFlickr(withLimit: AppParameters.sharedInstance.pageLimit, page: page, bbox: AppParameters.sharedInstance.standartBBOX ,searchText: self.searchText, callback: { [weak weakSelf = self] (loadedPhotos) in
            guard let strongSelf = weakSelf else
            {
                return
            }
            MBProgressHUD.hide(for: weakSelf!.view, animated: true)
            if(loadedPhotos.count == 0 && page == 1)
            {
                strongSelf.messageLabel.text = "No results"
                return;
            }else
            {
                strongSelf.messageLabel.text = ""
            }

            strongSelf.galleryView.addPhotos(photos: loadedPhotos)
            strongSelf.galleryView.reloadData()
        })
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if(segue.identifier == "PhotoDetail")
        {
            let photoDetailVC = segue.destination as! PhotoDetailVC

            if let photo = self.selectedPhoto
            {
                photoDetailVC.image = photo
            }

        }
    }
}

extension SearchVC : GalleryDelegate
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

extension SearchVC : UISearchBarDelegate
{
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar)
    {
        self.searchText = ""
        searchBar.text = ""
        self.searchAction()
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar)
    {
        if let searchText = searchBar.text
        {
            self.searchText = searchText
            self.searchAction()
        }
    }

    func searchAction()
    {
        self.galleryView.clearPhotos()
        self.galleryView.reloadData()
        self.view.endEditing(true)
    }
}
