//
//  ItemCollectionViewCell.swift
//  HummerSystemsTextApp
//
//  Created by User on 05.03.2021.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var itemContentLabel: UILabel!
    @IBOutlet weak var itemPurchaseButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.itemPurchaseButton.layer.cornerRadius = 10
        self.itemPurchaseButton.layer.borderWidth = 1
        self.itemPurchaseButton.layer.borderColor = UIColor.orange.cgColor
        
    }
    
    //MARK: - Actions
    
    @IBAction func pressPriceButton(_ sender: Any) {
        let alert = UIAlertController(title: "Добавлено", message: "Товар добавлен в корзину", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        
    }
    

}
