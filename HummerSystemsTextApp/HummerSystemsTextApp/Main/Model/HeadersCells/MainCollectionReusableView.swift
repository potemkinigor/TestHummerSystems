//
//  MainCollectionReusableView.swift
//  HummerSystemsTextApp
//
//  Created by User on 05.03.2021.
//

import UIKit

class MainCollectionReusableView: UICollectionReusableView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var buttonsCollectionView: UICollectionView!
    var sectionNames: [(String, Int)]!
    var sectionSelectedNumber: Int = 0
    var selectedSectionStartRow = 0
    var delegate: PassItemSectionNumberProtocol?
    var parentViewController: UIViewController!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.buttonsCollectionView.delegate = self
        self.buttonsCollectionView.dataSource = self
        
        self.buttonsCollectionView.register(UINib(nibName: "MainButtonsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "MainButtonReusableIdentifier")
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if sectionNames == nil {
            return 0
        } else {
            return sectionNames.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MainButtonReusableIdentifier", for: indexPath) as! MainButtonsCollectionViewCell
        
        if sectionNames != nil {
            cell.sectionButton.setTitle("\(sectionNames[indexPath.row].0)", for: .normal)
        }

        cell.sectionButton.addTarget(self, action: #selector(tapSectonButton), for: .touchDown)

        cell.contentView.layer.cornerRadius = 20
        cell.contentView.layer.masksToBounds = true
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = false
        
        cell.contentView.layer.backgroundColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        cell.sectionButton.setTitleColor(UIColor.gray, for: .normal)
        
        if indexPath.row == sectionSelectedNumber {
            cell.contentView.layer.backgroundColor = UIColor.orange.withAlphaComponent(0.2).cgColor
            cell.sectionButton.setTitleColor(UIColor.orange, for: .normal) 
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.frame.width / 3, height: CGFloat(buttonSectionHeight - 10))
    }
    
    //MARK: - Actions
    
    @objc func tapSectonButton (_sender: UIButton, _ sectionNumber: Int) {
        
        self.selectedSectionStartRow = 0
        
        if _sender.titleLabel!.text != nil {
            for index in 0..<sectionNames.count {
                if sectionNames[index].0 != _sender.titleLabel!.text {
                    self.selectedSectionStartRow += sectionNames[index].1
                } else {
                    self.sectionSelectedNumber = index
                    break
                }
            }
        }

        self.delegate = self.parentViewController as? PassItemSectionNumberProtocol
        self.delegate?.passedItemSectionNumber(selectedSectionStartRow)
        
        self.buttonsCollectionView.reloadSections(IndexSet(integer: 0))
    }
    
}
