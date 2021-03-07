//
//  MainNetworkRequest.swift
//  HummerSystemsTextApp
//
//  Created by User on 05.03.2021.
//

import Foundation
import UIKit

protocol MainNetworkRequestProtocol {
    func requestData(complition: @escaping ([MainItem]?, [Data]?) -> ())
    func requestPhotos(picturesAmount: Int, complition: @escaping ([Data]?) -> ())
}

class MainNetworkRequestImplementation: MainNetworkRequestProtocol {
    
    func requestData(complition: @escaping ([MainItem]?, [Data]?) -> ()) {
        let url = URL(string: "https://private-anon-a43f40da19-pizzaapp.apiary-mock.com/restaurants/restaurantId/menu")!
        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                complition(nil, nil)
                print("Error \(String(describing: error))")
            } else {
                
                var itemImagesDataArray: [Data]?

                if let items = try? JSONDecoder().decode([MainItem].self, from: data!) {
                    
                    self.requestPhotos(picturesAmount: items.count) { imagesDataArray in
                        itemImagesDataArray = imagesDataArray!
                        complition(items, itemImagesDataArray)
                    }
                }
            }
        }
        
        task.resume()
    }
    
    func requestPhotos(picturesAmount: Int, complition: @escaping ([Data]?) -> ()) {
        
        var imagesDataArray: [Data]? = []
        
        for _ in 0..<picturesAmount {
            let url = URL(string: "https://picsum.photos/200/200")
            let data = try? Data(contentsOf: url!)
            
            if data != nil {
                imagesDataArray!.append(data!)
            }
        }
        
        if imagesDataArray?.count == 0 {
            imagesDataArray = nil
        }
        
        complition(imagesDataArray)
    }
    
}


