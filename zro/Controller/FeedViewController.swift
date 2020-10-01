//
//  FeedViewController.swift
//  zro
//
//  Created by rfl3 on 30/09/20.
//  Copyright © 2020 renacio. All rights reserved.
//

import UIKit
import Alamofire

class FeedViewController: UIViewController {

    @IBOutlet weak var header: UIView!
    @IBOutlet weak var filterDate: UITextField!
    @IBOutlet weak var filterFavoritesButton: UIButton!
    @IBOutlet weak var filterOptionsView: UIView!
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var notFiltering: NSLayoutConstraint!
    @IBOutlet weak var isFiltering: NSLayoutConstraint!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var filterView: UIView!

    var collectionView: UICollectionView?

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    var filteredDate = ""
    var filteringFavorites = false

    var page = 1
    var maxPages: Int = Int.max

    var filteredNews: [NewsData]            = []
    var news: [NewsData]                    = []
    var filteredhighlightedNews: [NewsData] = []
    var highlightedNews: [NewsData]         = []

    let datePicker = UIDatePicker()
    let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        self.setupLayout()
        self.requestNews()
        self.createDatePicker()
//        self.createSearchController()

        NotificationCenter.default.addObserver(self, selector: #selector(reloadData),
                                               name: NSNotification.Name("reloadData"),
                                               object: nil)
    }

//    func createSearchController() {
//        self.searchController.searchResultsUpdater = self
//        self.searchController.obscuresBackgroundDuringPresentation = false
//        self.searchController.delegate = self
//        self.searchController.searchBar.barTintColor = UIColor(named: "orange")
//        self.searchController.searchBar.isTranslucent = false
//        self.searchController.searchBar.searchTextField.alpha = 1
//        self.searchController.searchBar.placeholder = "Search by title"
//        self.header.addSubview(searchController.searchBar)
//        self.searchController.searchBar.translatesAutoresizingMaskIntoConstraints = false
//        self.header.addConstraints([
//            NSLayoutConstraint(item: self.searchController.searchBar.superview,
//                               attribute: .trailing,
//                               relatedBy: .equal,
//                               toItem: self.searchController.searchBar,
//                               attribute: .trailing,
//                               multiplier: 1,
//                               constant: 20),
//            NSLayoutConstraint(item: self.searchController.searchBar,
//                               attribute: .leading,
//                               relatedBy: .equal,
//                               toItem: self.filterButton,
//                               attribute: .trailing,
//                               multiplier: 1,
//                               constant: 20),
//            NSLayoutConstraint(item: self.searchController.searchBar,
//                               attribute: .centerY,
//                               relatedBy: .equal,
//                               toItem: self.searchController.searchBar.superview,
//                               attribute: .centerY,
//                               multiplier: 1,
//                               constant: 0),
//            NSLayoutConstraint(item: self.searchController.searchBar,
//                               attribute: .height,
//                               relatedBy: .equal,
//                               toItem: nil,
//                               attribute: .notAnAttribute,
//                               multiplier: 1,
//                               constant: 34)
//
//        ])
//    }

    @IBAction func filterFavorites(_ sender: Any) {
        self.filteringFavorites = !self.filteringFavorites
        if self.filteringFavorites {
            print(self.news.count)
            self.news = self.filterFavorites(self.news)
            self.highlightedNews = self.filterFavorites(self.highlightedNews)
            self.reloadData()
        } else {
            self.clearAndRequestForDate(date: "")
        }
    }

    func filterFavorites(_ news: [NewsData]) -> [NewsData] {
        return news.filter({ CoreDataService.shared.isFav($0.url) })
    }

    @objc
    func reloadData(_ filtering: String = "") {

        self.filteredhighlightedNews = self.highlightedNews
        self.filteredNews = self.news

        if filtering.count > 0 {
            self.filteredNews = self.news.filter({ $0.title.lowercased().contains(filtering.lowercased()) })
        }

        DispatchQueue.main.async {
            self.tableView.reloadData()
            if let collectionView = self.collectionView {
                collectionView.reloadData()
            }
        }

    }

    func createDatePicker() {

        let toolBar = UIToolbar()
        toolBar.sizeToFit()

        let doneBtn = UIBarButtonItem(barButtonSystemItem: .done,
                                      target: self,
                                      action: #selector(self.filterDateSelected))
        let clearBtn = UIBarButtonItem(title: "Clear filter",
                                       style: .done,
                                       target: self, action: #selector(self.clearDateSelected))
        toolBar.setItems([doneBtn, clearBtn], animated: true)
        self.filterDate.inputAccessoryView = toolBar

        self.filterDate.inputView = self.datePicker
        self.datePicker.datePickerMode = .date

    }

    @objc
    func clearDateSelected() {
        self.filteredDate = ""
        self.filterDate.text = ""
        self.clearAndRequestForDate(date: "")

        self.filterDate.endEditing(false)
    }

    @objc
    func filterDateSelected() {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"

        let filteredDate = formatter.string(from: datePicker.date)

        if self.filteredDate != filteredDate {

            self.clearAndRequestForDate(date: filteredDate)

        }

        self.filteredDate = filteredDate

        formatter.dateFormat = "dd-MM-YYYY"
        self.filterDate.text = formatter.string(from: datePicker.date)

        self.filterDate.endEditing(false)
    }

    func clearAndRequestForDate(date: String) {
        self.news = []
        self.highlightedNews = []
        self.maxPages = Int.max
        self.page = 1

        self.requestNews(date: date)
    }

    func requestNews(page: Int = 1, date: String = "") {

        if self.page < self.maxPages {

            APIFacade.shared.requestNews(page, date: date) { response in
                switch response.result {
                    case .failure:
                        break
                    case .success(let data):

                        self.page += 1

                        let newNews = try? JSONDecoder().decode(News.self, from: data)

                        if self.maxPages == Int.max {
                            self.maxPages = newNews!.pagination.totalPages
                        }

                        let sortedNews = newNews?.data.sorted(by: {
                            $0.publishedAt > $1.publishedAt
                        })

                        if self.filteringFavorites {
                            self.news.append(contentsOf: self.filterFavorites(sortedNews ?? []))
                            self.highlightedNews.append(contentsOf: self.filterFavorites(sortedNews?.filter { $0.highlight } ?? []))
                        } else {
                            self.news.append(contentsOf: sortedNews ?? [])
                            self.highlightedNews.append(contentsOf: sortedNews?.filter { $0.highlight } ?? [])
                        }

                        self.reloadData()
                        break
                }
            }

        }

    }

    func setupLayout() {
        self.filterButton.imageView?.contentMode = .scaleAspectFit
        self.filterFavoritesButton.layer.cornerRadius = self.filterFavoritesButton.frame.height / 8
    }

    @IBAction func filter(_ sender: Any) {
        if self.notFiltering.isActive {
            UIView.animate(withDuration: 0.5, animations: {
                self.isFiltering.isActive = true
                self.notFiltering.isActive = false
                self.view.layoutIfNeeded()
            }) { _ in
                self.filterOptionsView.isHidden = false
            }
        } else {
            self.filterOptionsView.isHidden = true
            UIView.animate(withDuration: 0.5, animations: {
                self.isFiltering.isActive = false
                self.notFiltering.isActive = true
                self.view.layoutIfNeeded()
            })
        }
    }
}

extension FeedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.filteredNews.count + 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if indexPath.row == 0 {
            // swiftlint:disable:next force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: "highlighted") as! HighlightCell
            self.collectionView = cell.collectionView
            return cell

        } else {
            // swiftlint:disable:next force_cast
            let cell = tableView.dequeueReusableCell(withIdentifier: "news") as! NewsCell
            cell.news = self.filteredNews[indexPath.row - 1]
            cell.favorite.imageView?.contentMode = .scaleAspectFit
            return cell
        }

    }

}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 300
        } else {
            return 190
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.filteredNews.count - 3 {
            self.requestNews(page: self.page)
        }
    }
}

extension FeedViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == self.filteredhighlightedNews.count - 3 {
            self.requestNews(page: self.page)
        }
    }

}

extension FeedViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 250)
    }
}

extension FeedViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filteredhighlightedNews.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // swiftlint:disable force_cast
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "highlight",
                                                      for: indexPath) as! HighlightNews
        // swiftlint:enable force_cast

        cell.news = self.filteredhighlightedNews[indexPath.row]
        cell.favoriteButton.imageView?.contentMode = .scaleAspectFit
        return cell
    }
}

//extension FeedViewController: UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        if let searchText = searchController.searchBar.text {
//            self.filterCurrentDataSource(searchTerm: searchText)
//        }
//    }
//}
//
//extension FeedViewController: UISearchControllerDelegate {
//
//}
