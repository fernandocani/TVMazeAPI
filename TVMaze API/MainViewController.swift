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
    
    let cellIdentifier      = "mainCell"
    var shows               = NSMutableArray()
    var loadingData         = false
    var higherIndex         = 0
    var currentPageIndex    = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if DataStore.sharedInstance.hasShow() {
            self.populateArray()
            self.currentPageIndex = Int(floor(Double(shows.count) / 250) + 1)
        } else {
            self.getShows()
        }
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
                    let id      = show.objectForKey("id")                               as! Int
                    let name    = show.objectForKey("name")                             as! String
                    let summary = show.objectForKey("summary")                          as! String
                    let imageM  = show.objectForKey("image")!.objectForKey("medium")    as! String
                    let imageO  = show.objectForKey("image")!.objectForKey("original")  as! String
                    if !DataStore.sharedInstance.hasShowByID("\(id)") {
                        if DataStore.sharedInstance.createShow(id, name: name, summary: summary, imageM: imageM, imageO: imageO) {
                            print("Salvouuu")
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
                    let id      = show.objectForKey("id")                               as! Int
                    let name    = show.objectForKey("name")                             as! String
                    let summary = show.objectForKey("summary")                          as! String
                    let imageM  = show.objectForKey("image")!.objectForKey("medium")    as! String
                    let imageO  = show.objectForKey("image")!.objectForKey("original")  as! String
                    if !DataStore.sharedInstance.hasShowByID("\(id)") {
                        if DataStore.sharedInstance.createShow(id, name: name, summary: summary, imageM: imageM, imageO: imageO) {
                            self.shows.addObject(DataStore.sharedInstance.getShowByID("\(id)"))
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
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MainTableViewCell
        cell.lblTitle.text = (shows.objectAtIndex(indexPath.row) as! Show).name!
        let summary = (shows.objectAtIndex(indexPath.row) as! Show).summary!
        let regex = try! NSRegularExpression(pattern: "<.*?>", options: [.CaseInsensitive])
        let summaryFixed: String = regex.stringByReplacingMatchesInString(summary, options: [], range: NSMakeRange(0, summary.characters.count), withTemplate: "")
        cell.lblSummary.text = summaryFixed
        cell.imgHeader.af_setImageWithURL(NSURL(string: (shows.objectAtIndex(indexPath.row) as! Show).imageM!)!)
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shows.count
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        if !searchController.active {
            if (!loadingData && (indexPath.row == (shows.count - 1))) {
                self.loadingData = true
                self.getMoreShows(currentPageIndex)
            }
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

class MainTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgHeader:   UIImageView!
    @IBOutlet weak var lblTitle:    UILabel!
    @IBOutlet weak var lblSummary:  UILabel!
}
