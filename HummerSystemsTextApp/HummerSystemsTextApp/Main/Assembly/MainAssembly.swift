//
//  MainAssembly.swift
//  HummerSystemsTextApp
//
//  Created by User on 05.03.2021.
//

import Foundation
import UIKit

class MainAssebley: NSObject {
    
    @IBOutlet var viewController: UIViewController!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        guard let view = viewController as? MainViewController else { return }
        let persistanceContainer = PersistanceContainer()
        let networkRequest = MainNetworkRequestImplementation()
        let bannerImages = MainBannerImages(bannerImages: [])
        let presenter = MainViewInputImplementation(view: view, dataRequest: networkRequest, bannerImages: bannerImages, persistance: persistanceContainer)
        
        view.presenterProtocol = presenter
        
    }
    
    
}


