//
//  BannersCollectionViewCell.swift
//  HummerSystemsTextApp
//
//  Created by User on 04.03.2021.
//

import UIKit

class BannersCollectionViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    var images: MainBannerImages!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.imagesCollectionView.delegate = self
        self.imagesCollectionView.dataSource = self
        
        self.imagesCollectionView.register(UINib(nibName: "BannersImagesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "bannersImageCellReusableIdentifier")
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfBanners
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "bannersImageCellReusableIdentifier", for: indexPath) as! BannersImagesCollectionViewCell
        
        if images != nil {
            cell.bannerImageView.image = images.bannerImages[indexPath.row]
            cell.bannerImageView.contentMode = .scaleAspectFill
        }
        
        cell.contentView.layer.cornerRadius = 10
        cell.contentView.layer.masksToBounds = true

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: bannerScreenWidth, height: bannerScreenHeight)
    }

}
