//
//  MainViewController.swift
//  TVMaze API
//
//  Created by Fernando Cani on 6/21/16.
//  Copyright © 2016 com.fernandocani. All rights reserved.
//

import UIKit
import Darwin
import Alamofire
import AlamofireImage

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segAllFav: UISegmentedControl!
    
    let searchController    = UISearchController(searchResultsController: nil)
    
    let cellIdentifier      = "mainCell"
    var shows               = NSMutableArray()
    var loadingData         = false
    var higherIndex         = 0
    var currentPageIndex    = 0
    
    var filteredShowsName   = [Show]()
    var showsForSearch      = [Show]()
    var favoriteShows       = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(hex: viewBlackColor)
        self.tableView.backgroundColor = UIColor.clearColor()
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
//        DataStore.sharedInstance.whipeCD()
        if DataStore.sharedInstance.hasShow() {
            self.populateArray()
            for show in shows {
                showsForSearch.append(show as! Show)
            }
            self.currentPageIndex = Int(floor(Double(shows.count) / 250))
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
        } else {
            self.getShows()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
    func getShowData(show: NSDictionary) -> Show {
        let currentShow = Show()
        currentShow.id      = show.objectForKey("id")                               as? Int
        currentShow.name    = show.objectForKey("name")                             as? String
        currentShow.summary = self.cleanSummary((show.objectForKey("summary")       as? String)!)
        currentShow.imageM  = show.objectForKey("image")!.objectForKey("medium")    as? String
        currentShow.imageO  = show.objectForKey("image")!.objectForKey("original")  as? String
        currentShow.genres  = show.objectForKey("genres")!                          as? [String]
        currentShow.scheduleD = show.objectForKey("schedule")!.objectForKey("days") as? [String]
        currentShow.scheduleT = show.objectForKey("schedule")!.objectForKey("time") as? String
        currentShow.favorite = false
        return currentShow
    }
    
    func getShows() {
        self.createLoading()
        Alamofire.request(.GET, baseUrl + showsUrl, encoding: .JSON).responseJSON {
            response in switch response.result {
            case .Success(let JSON):
                for show in (JSON as! NSArray) {
                    let currentShow = self.getShowData(show as! NSDictionary)
                    if !DataStore.sharedInstance.hasShowByID("\(currentShow.id)") {
                        if DataStore.sharedInstance.createShow(currentShow) {
                            let savedShow = DataStore.sharedInstance.getShowByID("\(currentShow.id!)")
                            self.showsForSearch.append(savedShow)
                        }
                    }
                }
                
                self.populateArray()
                self.currentPageIndex = 1
            case .Failure(let error):
                print("Request failed with error: \(error)")
                self.removeLoading()
            }
        }
    }
    
    func getMoreShows(index: Int) {
        Alamofire.request(.GET, baseUrl + showsUrlPag + "\(index)", encoding: .JSON).responseJSON {
            response in switch response.result {
            case .Success(let JSON):
                for show in (JSON as! NSArray) {
                    let currentShow = self.getShowData(show as! NSDictionary)
                    if !DataStore.sharedInstance.hasShowByID("\(currentShow.id!)") {
                        if DataStore.sharedInstance.createShow(currentShow) {
                            self.showsForSearch.append(currentShow)
                            self.shows.addObject(currentShow)
                            self.tableView.beginUpdates()
                            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: self.shows.count-1, inSection: 0)], withRowAnimation: .Automatic)
                            self.tableView.endUpdates()
                        }
                    }
                }
                self.currentPageIndex += 1
                self.loadingData = false
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func populateArray() {
        shows = DataStore.sharedInstance.getShows()
        for show in shows {
            if (show as! Show).id > self.higherIndex {
                self.higherIndex = (show as! Show).id!
            }
        }
        self.tableView.reloadData()
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
        self.removeLoading()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func populateCell(indexPath: NSIndexPath, show: Show) -> MainTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MainTableViewCell
        cell.lblTitle.text      = show.name!
        cell.lblSummary.text    = show.summary!
        cell.imgHeader.af_setImageWithURL(NSURL(string: show.imageM!)!)
        cell.show               = show
        return cell
    }
    
    func populateCellFiltered(indexPath: NSIndexPath) -> MainTableViewCell {
        let filter  = filteredShowsName[indexPath.row].id!
        let cell    = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MainTableViewCell
        for item in showsForSearch {
            if item.id! == filter {
                cell.lblTitle.text      = item.name!
                cell.lblSummary.text    = item.summary!
                cell.imgHeader.af_setImageWithURL(NSURL(string: item.imageM!)!)
                cell.show               = item
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.segAllFav.selectedSegmentIndex == 0 {
            if searchController.active && searchController.searchBar.text != "" {
                return self.populateCellFiltered(indexPath)
            } else {
                return self.populateCell(indexPath, show: shows.objectAtIndex(indexPath.row) as! Show)
            }
        } else {
            if searchController.active && searchController.searchBar.text != "" {
                return self.populateCellFiltered(indexPath)
            } else {
                return self.populateCell(indexPath, show: favoriteShows.objectAtIndex(indexPath.row) as! Show)
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segAllFav.selectedSegmentIndex == 0 {
            if searchController.active && searchController.searchBar.text != "" {
                return filteredShowsName.count
            }
            return shows.count
        } else {
            if searchController.active && searchController.searchBar.text != "" {
                return filteredShowsName.count
            }
            return favoriteShows.count
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if segAllFav.selectedSegmentIndex == 0 {
            if !searchController.active {
                if (!loadingData && (indexPath.row == (shows.count - 1))) {
                    self.loadingData = true
                    self.getMoreShows(currentPageIndex)
                }
            }
        }
    }
    
    var selectedImage = UIImage()
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredShowsName = showsForSearch.filter{ show in
            return show.name!.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell                = sender as! MainTableViewCell
        if segue.identifier == "toDetail" {
            let vc              = segue.destinationViewController as! DetailViewController
            vc.currentShow      = DataStore.sharedInstance.getShowByID("\(cell.show.id)")
            vc.selectedImage    = cell.imgHeader.image!
            self.searchController.active = false
        }
    }
    
    func cleanSummary(summary: String) -> String {
        let regex = try! NSRegularExpression(pattern: "<.*?>", options: [.CaseInsensitive])
        let summaryFixed: String = regex.stringByReplacingMatchesInString(summary, options: [], range: NSMakeRange(0, summary.characters.count), withTemplate: "")
        return summaryFixed
    }
    
    func createLoading() {
        let currentWindow = UIApplication.sharedApplication().keyWindow
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Dark))
        visualEffectView.frame = self.view.bounds
        visualEffectView.tag = 1
        if (currentWindow!.viewWithTag(1) == nil) {
            currentWindow?.addSubview(visualEffectView)
        }
        
        let spinner = UIActivityIndicatorView()
        spinner.center = self.view.center
        spinner.activityIndicatorViewStyle = .WhiteLarge
        spinner.startAnimating()
        spinner.tag = 2
        if (currentWindow!.viewWithTag(2) == nil) {
            currentWindow?.addSubview(spinner)
        }
    }
    
    func removeLoading() {
        let currentWindow = UIApplication.sharedApplication().keyWindow
        if (currentWindow!.viewWithTag(1) != nil) {
            currentWindow!.viewWithTag(1)!.removeFromSuperview()
        }
        if (currentWindow!.viewWithTag(2) != nil) {
            currentWindow!.viewWithTag(2)!.removeFromSuperview()
        }
    }
    
    @IBAction func segAllFav(sender: UISegmentedControl) {
        switch segAllFav.selectedSegmentIndex {
        case 0:
            showsForSearch.removeAll()
            for show in shows {
                showsForSearch.append(show as! Show)
            }
            self.tableView.reloadData()
        case 1:
            self.favoriteShows = DataStore.sharedInstance.getFavoritesShow()
            showsForSearch.removeAll()
            for show in favoriteShows {
                showsForSearch.append(show as! Show)
            }
            self.tableView.reloadData()
        default:
            break
        }
    }
}

extension MainViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

class MainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgHeader:   UIImageView!
    @IBOutlet weak var lblTitle:    UILabel!
    @IBOutlet weak var lblSummary:  UILabel!
    
    var show: Show!
}
