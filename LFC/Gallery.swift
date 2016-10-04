//
//  GalleryVC.swift
//  LFC
//
//  Created by Admin on 22.09.16.
//  Copyright © 2016 bondar. All rights reserved.
//

import UIKit
import FlickrKit
import SDWebImage
import MBProgressHUD

protocol GalleryDelegate {

    func loadPhotos(page: Int)

    func photoDidSelect(_ selectedItem: Photo)

}

class Gallery : NSObject
{
    //MARK: Properties
    private var galleryView: UICollectionView!

    var galleryDelegate: GalleryDelegate?

    internal var photos = [Photo]()
    internal var selectedPhoto: Photo?
    internal var page = 1



    init(with collectionView: UICollectionView!)
    {
        super.init()
        self.galleryView = collectionView

        self.galleryView.delegate = self
        self.galleryView.dataSource = self
        self.galleryView.register(UINib(nibName: "GalleryPhotoCVC", bundle: nil), forCellWithReuseIdentifier: "GalleryPhotoCVC")

        self.galleryInit()
    }

    func clearPhotos()
    {
        self.photos = [Photo] ()
        self.page = 1
    }

    func reloadData()
    {
        self.galleryView.reloadData()
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
    }

    func addPhotos(photos: [Photo])
    {
        self.photos.append(contentsOf: photos)
    }

    internal func loadPhotos()
    {
        guard let delegate = self.galleryDelegate else
        {
            self.photos = [Photo]()
            self.galleryView.reloadData()
            return
        }

        delegate.loadPhotos(page: self.page)
    }

    internal func photoDidSelected(photo: Photo)
    {
        guard let delegate = self.galleryDelegate else
        {
            self.photos = [Photo]()
            self.galleryView.reloadData()
            return
        }

        delegate.photoDidSelect(photo)
    }
}


extension Gallery : UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDataSourcePrefetching
{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let galleryPhotoCVC = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryPhotoCVC", for: indexPath) as! GalleryPhotoCVC

        galleryPhotoCVC.setup(with: self.photos[indexPath.row])

        if ( indexPath.row == self.photos.count - 1)
        {
            self.page = self.page + 1
            self.loadPhotos()
        }

        return galleryPhotoCVC
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if(self.photos.count == 0)
        {
            self.loadPhotos()
        }
        return self.photos.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let photo = self.photos[indexPath.row]
        self.photoDidSelected(photo: photo)
    }

    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath])
    {
        print(indexPaths)
    }

    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath])
    {

    }
}






