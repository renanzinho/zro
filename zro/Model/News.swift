//
//  News.swift
//  zro
//
//  Created by rfl3 on 30/09/20.
//  Copyright © 2020 renacio. All rights reserved.
//

import Foundation

struct News: Codable {

    var pagination: Pagination
    var data: [NewsData]

}
