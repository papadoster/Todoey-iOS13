//
//  CategoryItem.swift
//  Todoey
//
//  Created by Marina Karpova on 30.01.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import RealmSwift

class CategoryItem: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
