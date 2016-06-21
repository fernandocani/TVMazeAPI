//
//  MainViewController.swift
//  TVMaze API
//
//  Created by Fernando Cani on 6/21/16.
//  Copyright © 2016 com.fernandocani. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class MainViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let cellIdentifier = "mainCell"
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getShows()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getShows() {
        Alamofire.request(.GET, baseUrl + showsUrl, encoding: .JSON).responseJSON {
            response in switch response.result {
            case .Success(let JSON):
                for show in (JSON as! NSArray) {
                    let showID      = show.objectForKey("id") as! Int
                    let showName    = show.objectForKey("name") as! String
                    let showImageM  = show.objectForKey("image")!.objectForKey("medium") as! String
                    let showImageO  = show.objectForKey("image")!.objectForKey("original") as! String
                    
                }
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MainTableViewCell
        cell.lblTitle.text = baseUrl
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
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
    
}
