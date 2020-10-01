//
//  NewsData.swift
//  zro
//
//  Created by rfl3 on 30/09/20.
//  Copyright © 2020 renacio. All rights reserved.
//

import UIKit

struct NewsData: Codable {

    var title: String
    var description: String
    var content: String
    var author: String
    var publishedAt: Date
    var url: String
    var imageURL: String
    var highlight: Bool

    enum CodingKeys: String, CodingKey {
        case title, description, content, author, url, highlight
        case publishedAt = "published_at"
        case imageURL = "image_url"
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.title = try container.decode(String.self, forKey: .title)
        self.description = try container.decode(String.self, forKey: .description)
        self.content = try container.decode(String.self, forKey: .content)
        self.author = try container.decode(String.self, forKey: .author)
        self.url = try container.decode(String.self, forKey: .url)
        self.imageURL = try container.decode(String.self, forKey: .imageURL)
        self.highlight = try container.decode(Bool.self, forKey: .highlight)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = try container.decode(String.self, forKey: .publishedAt)
        self.publishedAt = dateFormatter.date(from: date)!

    }

}
