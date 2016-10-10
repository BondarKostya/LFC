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
    @IBOutlet weak var messageLabel: UILabel!

    var galleryVC: GalleryVC?
    var searchText = ""

    override func viewDidLoad()
    {
        self.setBackgroundImage()
        
        self.title = "Search Photo"
        self.searchBar.barTintColor = UIColor.black
        self.searchBar.tintColor = UIColor.white
        let textFieldInsideSearchBar = self.searchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        self.searchBar.delegate = self

        self.hideKeyboardWhenTappedAround()
        let cancelButtonAttributes: NSDictionary = [NSForegroundColorAttributeName: UIColor.white]

        UIBarButtonItem.appearance().setTitleTextAttributes(cancelButtonAttributes as? [String : AnyObject], for: UIControlState.normal)

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
        hud.contentColor = UIColor.lightGray
        hud.bezelView.style = .solidColor
        hud.bezelView.color = UIColor.clear
        FlickrAPIClient.sharedInstance.searchPhotos(withParameters: .textSearch(limit: AppConstants.pageLimit, page: page, searchText:self.searchText), callback: { [weak weakSelf = self] (loadedPhotos,error) in
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

            strongSelf.galleryVC?.addPhotos(photos: loadedPhotos)
            strongSelf.galleryVC?.reloadData()
        })
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let photoDetailVC = storyboard.instantiateViewController(withIdentifier: "PhotoDetailVC") as! PhotoDetailVC
        photoDetailVC.image = selectedItem
        self.navigationController?.pushViewController(photoDetailVC, animated: true)
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
        self.galleryVC?.clearPhotos()
        self.galleryVC?.reloadData()
        self.view.endEditing(true)
    }
}
