//
//  Pagination.swift
//  zro
//
//  Created by rfl3 on 30/09/20.
//  Copyright © 2020 renacio. All rights reserved.
//

import Foundation

struct Pagination: Codable {

    var currentPage: Int
    var perPage: Int
    var totalPages: Int
    var totalItems: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case perPage = "per_page"
        case totalPages = "total_pages"
        case totalItems = "total_items"
    }

}
