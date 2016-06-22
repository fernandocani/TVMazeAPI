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
    
    @IBOutlet weak var btnSearch: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    let searchController    = UISearchController(searchResultsController: nil)
    
    let cellIdentifier      = "mainCell"
    var shows               = NSMutableArray()
    var loadingData         = false
    var higherIndex         = 0
    var currentPageIndex    = 0
    
    var filteredShowsName   = [Show]()
    var showsForSearch      = [Show]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView = searchController.searchBar
        
        if DataStore.sharedInstance.hasShow() {
            self.populateArray()
            for show in shows {
                showsForSearch.append(show as! Show)
            }
            self.currentPageIndex = Int(floor(Double(shows.count) / 250) + 1)
        } else {
            self.getShows()
        }
        
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getShows() {
        self.createLoading()
        Alamofire.request(.GET, baseUrl + showsUrl, encoding: .JSON).responseJSON {
            response in switch response.result {
            case .Success(let JSON):
                for show in (JSON as! NSArray) {
                    let currentShow = Show()
                    currentShow.id      = show.objectForKey("id")                               as? Int
                    currentShow.name    = show.objectForKey("name")                             as? String
                    currentShow.summary = show.objectForKey("summary")                          as? String
                    currentShow.imageM  = show.objectForKey("image")!.objectForKey("medium")    as? String
                    currentShow.imageO  = show.objectForKey("image")!.objectForKey("original")  as? String
                    if !DataStore.sharedInstance.hasShowByID("\(currentShow.id)") {
                        if DataStore.sharedInstance.createShow(currentShow) {
                            self.showsForSearch.append(DataStore.sharedInstance.getShowByID("\(currentShow.id)"))
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
                    let currentShow = Show()
                    currentShow.id      = show.objectForKey("id")                               as? Int
                    currentShow.name    = show.objectForKey("name")                             as? String
                    currentShow.summary = show.objectForKey("summary")                          as? String
                    currentShow.imageM  = show.objectForKey("image")!.objectForKey("medium")    as? String
                    currentShow.imageO  = show.objectForKey("image")!.objectForKey("original")  as? String
                    if !DataStore.sharedInstance.hasShowByID("\(currentShow.id)") {
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
        self.removeLoading()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if searchController.active && searchController.searchBar.text != "" {
            let filter = filteredShowsName[indexPath.row].id!
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MainTableViewCell
            for item in showsForSearch {
                if item.id! == filter {
                    cell.lblTitle.text = item.name!
                    let summary = item.summary!
                    let regex = try! NSRegularExpression(pattern: "<.*?>", options: [.CaseInsensitive])
                    let summaryFixed: String = regex.stringByReplacingMatchesInString(summary, options: [], range: NSMakeRange(0, summary.characters.count), withTemplate: "")
                    cell.lblSummary.text = summaryFixed
                    cell.imgHeader.af_setImageWithURL(NSURL(string: item.imageM!)!)
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MainTableViewCell
            cell.lblTitle.text = (shows.objectAtIndex(indexPath.row) as! Show).name!
            let summary = (shows.objectAtIndex(indexPath.row) as! Show).summary!
            let regex = try! NSRegularExpression(pattern: "<.*?>", options: [.CaseInsensitive])
            let summaryFixed: String = regex.stringByReplacingMatchesInString(summary, options: [], range: NSMakeRange(0, summary.characters.count), withTemplate: "")
            cell.lblSummary.text = summaryFixed
            cell.imgHeader.af_setImageWithURL(NSURL(string: (shows.objectAtIndex(indexPath.row) as! Show).imageM!)!)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.active && searchController.searchBar.text != "" {
            return filteredShowsName.count
        }
        return shows.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if !searchController.active {
            if (!loadingData && (indexPath.row == (shows.count - 1))) {
                self.loadingData = true
                self.getMoreShows(currentPageIndex)
            }
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredShowsName = showsForSearch.filter{ show in
            return show.name!.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        //        let cell        = sender as! UITableViewCell
        //        let indexPath   = tableView.indexPathForCell(cell)!
        //        if segue.identifier == "toCharacterDetail" {
        //            let vc      = segue.destinationViewController as! CharacterDetailViewController
        //            if searchController.active && searchController.searchBar.text != "" {
        //                vc.char = filteredShowsName[indexPath.row]
        //            } else {
        //                vc.char = self.charactersArray[indexPath.row] as! Character
        //            }
        //        }
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
}
