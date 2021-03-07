//
//  MainViewController.swift
//  HummerSystemsTextApp
//
//  Created by User on 04.03.2021.
//

import UIKit

class MainViewController: UIViewController, PassItemSectionNumberProtocol {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var presenterProtocol: MainViewInputProtocol!
    
    var bannerImages: MainBannerImages!
    var numberOfRowsInSection: [Int : Int]!
    var listOfItems: [MainItem]!
    var sections: [(String, Int)]!
    var itemImagesData: [Data]!
    var sectionSelectedNumber: Int = 0 {
        didSet {
            moveToOtherItemsSection()
        }
    }
    var selectedSectionStartRow = 0
    var fetchErrorMessage: String? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.register(UINib(nibName: "BannersCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "BannersCollectionViewCellReusableIdentifier")
        self.collectionView.register(UINib(nibName: "MainCollectionReusableView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "buttonsMainHeaderReusableIdentifier")
        
        
        self.collectionView.register(UINib(nibName: "ItemCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "itemCellReusableIdentifir")
        
        presenterProtocol.getNumbersOfRowsInSections()
        presenterProtocol.getBannersImages()
        presenterProtocol.getPizzaDataFromServer()
        
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
        }
    }
    
    //MARK: - Actions
    
    @IBAction func cityTap(_ sender: Any) {
        let alert = UIAlertController(title: "Выбор города", message: "Вы переходите на экран выбора города", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func passedItemSectionNumber(_ rowNumber: Int) {
        self.sectionSelectedNumber = rowNumber
    }
    
    func moveToOtherItemsSection() {
        let indexPath = IndexPath(row: self.sectionSelectedNumber, section: 1)
        self.collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
    }
    
    func printError() {
        let alert = UIAlertController(title: "Ошибка", message: fetchErrorMessage, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
        
        self.fetchErrorMessage = nil
    }
}

//MARK: - Collection View Data Source

extension MainViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return 1
        } else {
            if self.listOfItems != nil {
                return self.listOfItems.count
            } else { return 0 }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if indexPath.section == 0 {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BannersCollectionViewCellReusableIdentifier", for: indexPath) as! BannersCollectionViewCell
            
            cell.images = self.bannerImages
            cell.imagesCollectionView.reloadData()
            
            return cell
            
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCellReusableIdentifir", for: indexPath) as! ItemCollectionViewCell
            
            if self.listOfItems != nil {
                cell.itemNameLabel.text = self.listOfItems[indexPath.row].name
                
                cell.itemContentLabel.text = self.listOfItems[indexPath.row].topping?.joined(separator: ", ")
                
                if self.listOfItems[indexPath.row].topping != nil {
                    cell.itemContentLabel.text = self.listOfItems[indexPath.row].topping?.joined(separator: ", ")
                } else {
                    cell.itemContentLabel.text = ""
                }
                
                cell.itemPurchaseButton.setTitle(String(self.listOfItems[indexPath.row].price), for: .normal)
                
                
                if self.itemImagesData != nil {
                    cell.itemImageView.image = UIImage(data: self.itemImagesData[indexPath.row])
                }
                
            }
            
            if fetchErrorMessage != nil {
                self.printError()
            }
            
            return cell
        }
    }
    
}

//MARK: - Delegates

protocol PassItemSectionNumberProtocol {
    func passedItemSectionNumber(_ rowNumber: Int)
}

//MARK: - Extetions

extension MainViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Детали", message: "Переход к деталям позиции", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if indexPath.section == 0 {
            return CGSize(width: collectionView.frame.width, height: CGFloat(bannerScreenHeight))
        } else {
            return CGSize(width: collectionView.frame.width, height: 130)
        }

    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "buttonsMainHeaderReusableIdentifier", for: indexPath) as! MainCollectionReusableView
        
        view.sectionNames = self.sections
        view.parentViewController = self
        
        
        view.buttonsCollectionView.reloadData()
        
        if fetchErrorMessage != nil {
            self.printError()
        }
        
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if section == 1 {
            return CGSize(width: collectionView.frame.width, height: CGFloat(buttonSectionHeight))
        }
        return .zero
    }
    
}

//MARK: - Presenter

extension MainViewController: MainViewOutputProtocol {
    func updateNumberOfRownInSections(numberOfRowsInSection: [Int : Int]) {
        self.numberOfRowsInSection = numberOfRowsInSection
        self.collectionView.reloadData()
    }
    
    func updateBannersImages(images: MainBannerImages) {
        self.bannerImages = images
        self.collectionView.reloadData()
    }
    
    func updateListOfItems(data: [MainItem],sectionsNames: [(String, Int)], itemPhotoData: [Data], errorMessage: String?) {
        self.itemImagesData = itemPhotoData
        self.fetchErrorMessage = errorMessage
        self.sections = sectionsNames
        self.listOfItems = data
        self.collectionView.reloadData()
    }
}

