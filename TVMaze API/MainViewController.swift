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

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UIToolbarDelegate {
    
    @IBOutlet weak var tableView:   UITableView!
    @IBOutlet weak var segAllFav:   UISegmentedControl!
    @IBOutlet weak var toolbar:     UIToolbar!
    
    let searchController    = UISearchController(searchResultsController: nil)
    
    let cellIdentifier      = "mainCell"
    var shows               = NSMutableArray()
    var loadingData         = false
    var currentPageIndex    = 0
    
    var filteredShowsName       = [Show]()
    var showsForSearch          = [Show]()
    var currentShowToSegue:     Show!
    var favoriteShows           = NSMutableArray()
    var selectedImage           = UIImage()
    var searching               = false
    
    // MARK: Layout
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
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

    override func viewWillAppear(animated: Bool) {
        if currentShowToSegue != nil {
            let currentShow = DataStore.sharedInstance.getShowByID("\(currentShowToSegue.id)")
            if currentShowToSegue.favorite != currentShow.favorite {
                var count1 = 0
                for show1 in shows {
                    if (show1 as! Show).id == currentShow.id {
                        self.shows.removeObjectAtIndex(count1)
                        self.shows.insertObject(currentShow, atIndex: count1)
                        break
                    }
                    count1 += 1
                }
                favoriteShows.removeAllObjects()
                for show2 in shows {
                    if (show2 as! Show).favorite == true {
                        self.favoriteShows.addObject((show2 as! Show))
                    }
                }
                self.tableView.reloadData()
            }
        }
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.Top
    }
    
    func setLayout() {
        for parent in self.navigationController!.navigationBar.subviews {
            for childView in parent.subviews {
                if (childView is UIImageView) {
                    childView.removeFromSuperview()
                }
            }
        }
        self.toolbar.backgroundColor    = blackColor
        self.segAllFav.frame.size.width = screenWidth * 0.9
        self.view.backgroundColor       = viewBlackColor
        self.tableView.backgroundColor  = UIColor.clearColor()
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.searchController.searchBar.delegate = self
        self.searchController.searchBar.searchBarStyle = .Minimal
        self.searchController.searchBar.sizeToFit()
        self.tableView.tableHeaderView  = searchController.searchBar
    }
    
    // MARK: Connection
    
    func getShowData(show: NSDictionary) -> Show {
        let currentShow = Show()
        currentShow.id      = show.objectForKey("id")                               as? Int
        currentShow.name    = show.objectForKey("name")                             as? String
        currentShow.summary = self.cleanSummary((show.objectForKey("summary")       as? String)!)
        if let imageArray = show.objectForKey("image") as? NSDictionary {
            currentShow.imageM  = imageArray.objectForKey("medium")                 as? String
            currentShow.imageO  = imageArray.objectForKey("original")               as? String
        } else {
            currentShow.imageM  = "null"
            currentShow.imageO  = "null"
        }
        currentShow.genres  = show.objectForKey("genres")!                          as? [String]
        currentShow.scheduleD = show.objectForKey("schedule")!.objectForKey("days") as? [String]
        currentShow.scheduleT = show.objectForKey("schedule")!.objectForKey("time") as? String
        currentShow.favorite = false
        return currentShow
    }
    
    func getShows() {
        self.createLoading()
        let url = baseUrl + showsUrl
        print(url)
        Alamofire.request(.GET, url, encoding: .JSON).responseJSON {
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
        let url = baseUrl + showsUrlPag + "\(index)"
        print(url)
        Alamofire.request(.GET, url, encoding: .JSON).responseJSON {
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
    
    func searchShows(searchQuery: String) {
        self.searching = true
        let url = baseUrl + showsUrlSearch + searchQuery.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!
        print(url)
        Alamofire.request(.GET, url, encoding: .JSON).responseJSON {
            response in switch response.result {
            case .Success(let JSON):
                var count = 0
                print((JSON as! NSArray).count)
                for show in (JSON as! NSArray) {
                    let currentShow = self.getShowData((show as! NSDictionary).objectForKey("show") as! NSDictionary)
                    if !(self.showsForSearch.contains { return $0.id == currentShow.id }) {
                        self.showsForSearch.append(currentShow)
                    }
                    count += 1
                    print(count)
                }
                self.searching = false
                self.tableView.reloadData()
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    // MARK: Populate
    
    func populateArray() {
        shows = DataStore.sharedInstance.getShows()
        self.tableView.reloadData()
        self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: false)
        self.removeLoading()
    }
    
    func populateCell(indexPath: NSIndexPath, show: Show) -> MainTableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MainTableViewCell
        cell.lblTitle.text      = show.name!
        cell.lblSummary.text    = show.summary!
        cell.imgHeader.af_setImageWithURL(NSURL(string: show.imageM!)!)
        cell.show               = show
        if show.favorite == true {
            cell.lblTitle.textColor = yellowColor
        } else {
            cell.lblTitle.textColor = UIColor.whiteColor()
        }
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
                if item.favorite == true {
                    cell.lblTitle.textColor = yellowColor
                } else {
                    cell.lblTitle.textColor = UIColor.whiteColor()
                }
                cell.show               = item
            }
        }
        return cell
    }
    
    // MARK: Table View
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
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
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let currentShow = (tableView.cellForRowAtIndexPath(indexPath) as! MainTableViewCell).show
        var buttonTitle = ""
        if currentShow.favorite == true {
            buttonTitle = "\u{2605}\n   favorited"
        } else {
            buttonTitle = "\u{2606}\n unfavorited"
        }
        let favAction = UITableViewRowAction(style: .Default, title: buttonTitle, handler: { action, indexpath in
            self.favChange(currentShow)
            if self.segAllFav.selectedSegmentIndex == 0 {
                self.shows.removeObjectAtIndex(indexPath.row)
                self.shows.insertObject(DataStore.sharedInstance.getShowByID("\(currentShow.id)"), atIndex: indexPath.row)
                self.tableView.setEditing(false, animated: true)
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            } else {
                for value1 in 0...(self.favoriteShows.count - 1) {
                    if DataStore.sharedInstance.getShowByID("\((self.favoriteShows[value1] as! Show).id)").favorite == false {
                        var count: Int = 0
                        for current in self.shows {
                            if (current as! Show).id == (self.favoriteShows[value1] as! Show).id {
                                self.shows.removeObjectAtIndex(count)
                                self.shows.insertObject(DataStore.sharedInstance.getShowByID("\(currentShow.id)"), atIndex: count)
                                break
                            } else {
                                count += 1
                            }
                        }
                        self.favoriteShows.removeObjectAtIndex(value1)
                        break
                    }
                }
                self.tableView.setEditing(false, animated: true)
                self.tableView.beginUpdates()
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                self.tableView.endUpdates()
            }
        })
        favAction.backgroundColor = UIColor.grayColor()
        return [favAction]
    }
    
    // MARK: Search
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredShowsName = showsForSearch.filter{ show in
            if searchText != "" && !searching {
                self.searchShows(searchText)
            }
            return show.name!.lowercaseString.containsString(searchText.lowercaseString)
        }
        tableView.reloadData()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        searching = false
        filterContentForSearchText(searchText, scope: "All")
    }
    
    // MARK: Aux
    
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
    
    func favChange(currentShow: Show) {
        let id = "\(currentShow.id)"
        if currentShow.favorite == true {
            if DataStore.sharedInstance.favoriteShowByID(id, favorite: false) {
                //                self.currentShow = DataStore.sharedInstance.getShowByID("\(id)")
            }
        } else {
            if DataStore.sharedInstance.favoriteShowByID(id, favorite: true) {
                //                self.currentShow = DataStore.sharedInstance.getShowByID("\(id)")
            }
        }
    }
    
    // MARK: Segue
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell                = sender as! MainTableViewCell
        let currentID           = "\(cell.show.id)"
        if segue.identifier == "toDetail" {
            let vc              = segue.destinationViewController as! DetailViewController
            if !DataStore.sharedInstance.hasShowByID(currentID) {
                DataStore.sharedInstance.createShow(cell.show)
            }
            self.currentShowToSegue         = DataStore.sharedInstance.getShowByID(currentID)
            vc.currentShow                  = self.currentShowToSegue
            vc.selectedImage                = cell.imgHeader.image!
            self.searchController.active    = false
        }
    }
    
    // MARK: IBAction
    
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for subview in self.subviews {
            for subview2 in subview.subviews {
                if (String(subview2).rangeOfString("UITableViewCellActionButton") != nil) {
                    for view in subview2.subviews {
                        if (String(view).rangeOfString("UIButtonLabel") != nil) {
                            if let label = view as? UILabel {
                                       if label.text! == "\u{2605}\n   favorited" {
                                    label.textColor = UIColor(hex: "#F1C40F")
                                } else if label.text! == "\u{2606}\n unfavorited" {
                                    label.textColor = UIColor.whiteColor()
                                } else {
                                    label.textColor = UIColor.blackColor()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
