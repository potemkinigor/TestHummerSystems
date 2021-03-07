//
//  MainPresenter.swift
//  HummerSystemsTextApp
//
//  Created by User on 05.03.2021.
//

import Foundation
import UIKit
import CoreData

protocol MainViewOutputProtocol {
    func updateNumberOfRownInSections (numberOfRowsInSection: [Int : Int])
    func updateBannersImages(images: MainBannerImages)
    func updateListOfItems(data: [MainItem], sectionsNames: [(String, Int)], itemPhotoData: [Data], errorMessage: String?)
}

protocol MainViewInputProtocol {
    func getNumbersOfRowsInSections()
    func getBannersImages()
    func getPizzaDataFromServer()
    func saveSectionsInCoreData (sectionsNames: [(String, Int)])
    func saveDataInCoreData(data: [MainItem])
    func getCoreData() -> ([MainItem]?, [(String, Int)]?, [Data]?)
}

class MainViewInputImplementation: MainViewInputProtocol {
    
    var view: MainViewOutputProtocol!
    var networkRequest: MainNetworkRequestProtocol!
    var persistanceContainer :PersistanceContainerProtocol
    var bannerImages: MainBannerImages!
    
    
    required init(view: MainViewOutputProtocol, dataRequest: MainNetworkRequestProtocol, bannerImages: MainBannerImages, persistance: PersistanceContainerProtocol) {
        self.view = view
        self.networkRequest = dataRequest
        self.bannerImages = bannerImages
        self.persistanceContainer = persistance
    }
    
    func getNumbersOfRowsInSections() {
        
        var sections: [Int : Int] = [ : ]
        
        sections.removeAll()
        
        sections[0] = 1
        sections[1] = 500
        
        view.updateNumberOfRownInSections(numberOfRowsInSection: sections)
    }
    
    func getBannersImages() {
        
        bannerImages.bannerImages.removeAll()
    
        for index in 1...numberOfBanners {
            let image = UIImage(named: "bannerimage\(index)")
            
            if image != nil {
                self.bannerImages.bannerImages.append(image!)
            }
        }
        self.view.updateBannersImages(images: self.bannerImages)
    }
    
    func getPizzaDataFromServer() {
        let queue = DispatchQueue.global(qos: .background)
        queue.async {
            self.networkRequest.requestData { items, photos in
                if items != nil && photos != nil {
                    var sections: [(String, Int)] = []
    
                    items!.forEach { (item) in
                        for index in 0..<sections.count {
                            if item.category == sections[index].0 {
                                sections[index].1 += 1
                                return
                            }
                        }
                        sections.append((item.category, 1))
                    }
                    
                    self.saveSectionsInCoreData(sectionsNames: sections)
                    self.saveDataInCoreData(data: items!)
                    self.savePhotosDataInCoreData(photosData: photos!)
                    
                    DispatchQueue.main.sync {
                        self.view.updateListOfItems(data: items!, sectionsNames: sections, itemPhotoData: photos!, errorMessage: nil)
                    }
                    
                } else {
                    let sections: [(String, Int)]?
                    let items: [MainItem]?
                    var errorMessage: String!
                    var photosData: [Data]?
                    
                    let fetchResult = self.getCoreData()
                    
                    if (fetchResult.0 == nil || fetchResult.0?.count == 0) && (fetchResult.1 == nil || fetchResult.1?.count == 0) {
                        errorMessage = "Ошибка доступа к сетевым данным. Локальные данные не обнаружены. Просьба подключиться к сети для получения данных"
                    } else if fetchResult.0 == nil || fetchResult.0?.count == 0 {
                        errorMessage = "Ошибка доступа к сетевым данным. Локальные данные по товарам не обнаружены. Просьба подключиться к сети для получения данных"
                    } else if fetchResult.1 == nil || fetchResult.1?.count == 0 {
                        errorMessage = "Ошибка доступа к сетевым данным. Локальные данные по группам товаров не обнаружены. Просьба подключиться к сети для получения данных"
                    } else {
                        errorMessage = "Не удалось получить данные из сети. Использованы локальные данные"
                    }
        
                    sections = fetchResult.1
                    items = fetchResult.0
                    photosData = fetchResult.2
                    
                    DispatchQueue.main.sync {
                        self.view.updateListOfItems(data: items!, sectionsNames: sections!, itemPhotoData: photosData!, errorMessage: errorMessage)
                    }
                }
            }
        }
    }
    
    func saveSectionsInCoreData (sectionsNames: [(String, Int)]) {
        let context = PersistanceContainer.shared.container.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Sections")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
        
        for element in sectionsNames {
            let newElement = Sections(context: context)
            newElement.name = element.0
            newElement.countOfElements = Int64(element.1)
            
            PersistanceContainer.shared.saveContext()
        }
    }
    
    func saveDataInCoreData(data: [MainItem]) {
        let context = PersistanceContainer.shared.container.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Item")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        let deleteFetchToppings = NSFetchRequest<NSFetchRequestResult>(entityName: "Toppings")
        let deleteRequestToppings = NSBatchDeleteRequest(fetchRequest: deleteFetchToppings)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
        
        do {
            try context.execute(deleteRequestToppings)
            try context.save()
        } catch {
            print ("There was an error")
        }
        
        for element in data {
            let newElement = Item(context: context)
            newElement.name = element.name
            newElement.id = Int64(element.id)
            newElement.category = element.category
            newElement.price = Int64(element.price)
            newElement.rank = Int64(element.rank ?? 0)
            
            var toppingsArray: [Toppings] = []
            
            element.topping?.forEach({ topping in
                let newTopping = Toppings(context: context)
                newTopping.name = topping
                toppingsArray.append(newTopping)
            })
            
            newElement.toppings = NSSet.init(array: toppingsArray)
            
            PersistanceContainer.shared.saveContext()
        }
    }
    
    func savePhotosDataInCoreData(photosData: [Data]) {
        let context = PersistanceContainer.shared.container.viewContext
        
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "ItemImages")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
        
        for element in photosData {
            let newElement = ItemImages(context: context)
            newElement.image = element
            
            PersistanceContainer.shared.saveContext()
        }
    }
    
    func getCoreData() -> ([MainItem]?, [(String, Int)]?, [Data]?) {
        
        var dataArray: [MainItem]? = nil
        var blocksArray: [(String, Int)]? = nil
        var imagesData: [Data]? = nil
        
        let context = PersistanceContainer.shared.container.viewContext
        
        let itemsFetchRequest = Item.fetchRequest() as NSFetchRequest<Item>
        let sectionsFetchRequest = Sections.fetchRequest() as NSFetchRequest<Sections>
        let itemImagesDataFetchRequest = ItemImages.fetchRequest() as NSFetchRequest<ItemImages>
        
        let itemsArray = try? context.fetch(itemsFetchRequest)
        let sectionsArray = try? context.fetch(sectionsFetchRequest)
        let itemImagesDataArray = try? context.fetch(itemImagesDataFetchRequest)
        
        if itemsArray != nil {
            
            dataArray = []
            
            itemsArray?.forEach({ item in
                
                var toppingsArray: [String]? = nil
                
                if item.toppings != nil {
                    
                    toppingsArray = []
                    
                    let toppingElements = item.toppings?.allObjects as? [Toppings]
                    
                    toppingElements?.forEach({ topping in
                        toppingsArray?.append(topping.name!)
                    })
                    
                }
                
                dataArray!.append(MainItem(id: Int(item.id), category: item.category!, name: item.name!, topping: toppingsArray, price: Int(item.price), rank: Int(item.rank)))
            })
        }
        
        if sectionsArray != nil {
            
            blocksArray = []
            
            sectionsArray?.forEach({ section in
                blocksArray?.append((section.name!, Int(section.countOfElements)))
            })
        }
        
        if itemImagesDataArray != nil {
            imagesData = []
                
            itemImagesDataArray?.forEach({ item in
                imagesData?.append(item.image!)
            })
            
        }
    
        return (dataArray, blocksArray, imagesData)
    }
    
}

