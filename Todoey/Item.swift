//
//  Item.swift
//  Todoey
//
//  Created by Marina Karpova on 27.01.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation

class Item: Encodable {
    var title: String = ""
    var done: Bool = false
}
