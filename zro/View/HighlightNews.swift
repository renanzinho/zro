//
//  HighlightNews.swift
//  zro
//
//  Created by rfl3 on 30/09/20.
//  Copyright © 2020 renacio. All rights reserved.
//

import UIKit

class HighlightNews: UICollectionViewCell {

    var favoriteNews: Bool = false {
        didSet {
            if self.favoriteNews {
                self.favoriteButton.setImage(UIImage(named: "fullHeart"), for: .normal)
            } else {
                self.favoriteButton.setImage(UIImage(named: "emptyHeart"), for: .normal)
            }
        }
    }

    var news: NewsData? {
        didSet {
            guard let news = self.news,
                let url = URL(string: news.imageURL)
                else { return }

            self.title.text = news.title
            self.newsDescription.text = news.description
            self.headerImage.af.setImage(withURL: url, placeholderImage: UIImage(named: "headerPlaceholder"))

            self.favoriteNews = CoreDataService.shared.isFav(news.url)
        }
    }

    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var newsDescription: UILabel!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var headerImage: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    @IBAction func favorite(_ sender: Any) {
        self.favoriteNews = !self.favoriteNews

        guard let news = self.news else { return }

        if !self.favoriteNews {
            CoreDataService.shared.deleteUrl(news.url)
        } else {
            CoreDataService.shared.insertUrl(news.url)
        }

        NotificationCenter.default.post(name: NSNotification.Name("reloadData"), object: nil)
    }

}
