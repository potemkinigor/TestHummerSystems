//
//  MainItem.swift
//  HummerSystemsTextApp
//
//  Created by User on 05.03.2021.
//

import Foundation
import UIKit

struct MainItem: Decodable {
    var id: Int
    var category: String
    var name: String
    var topping: [String]?
    var price: Int
    var rank: Int?
}
