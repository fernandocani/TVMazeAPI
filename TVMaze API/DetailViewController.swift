//
//  DetailViewController.swift
//  TVMaze API
//
//  Created by Fernando Cani on 6/22/16.
//  Copyright © 2016 com.fernandocani. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class DetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var imgHeader:   UIImageView!
    @IBOutlet weak var txtSummary:  UITextView!
    @IBOutlet weak var lblGenres:   UILabel!
    @IBOutlet weak var lblSchedule: UILabel!
    @IBOutlet weak var segSeasons:  UISegmentedControl!
    @IBOutlet weak var tableView:   UITableView!
    
    var currentShow: Show!
    let allEpisodes = NSMutableArray()
    let seasons  = NSMutableDictionary()
    let cellIdentifier = "episodesCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setLayout()
        self.getSeasons()
    }

    override func viewDidLayoutSubviews() {
        self.txtSummary.setContentOffset(CGPointZero, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setLayout() {
        navigationItem.title = currentShow.name
        self.imgHeader.af_setImageWithURL(NSURL(string: currentShow.imageM!)!)
        self.txtSummary.editable        = true
        self.txtSummary.font            = .systemFontOfSize(15.0)
        self.txtSummary.text            = currentShow.summary
        self.txtSummary.editable        = false
        
        self.lblGenres.text = ""
        if currentShow.genres != nil {
            for item in currentShow.genres! {
                if self.lblGenres.text == "" {
                    self.lblGenres.text = item
                } else {
                    self.lblGenres.text = self.lblGenres.text! + ", " + item
                }
            }
        }
        self.lblSchedule.text = ""
        if currentShow.scheduleD != nil {
            for item in currentShow.scheduleD! {
                if self.lblSchedule.text == "" {
                    self.lblSchedule.text = item
                } else {
                    self.lblSchedule.text = self.lblSchedule.text! + ", " + item
                }
            }
        }
        self.lblSchedule.text = self.lblSchedule.text! + " @ " + currentShow.scheduleT!
        
        self.segSeasons.removeAllSegments()
        self.segSeasons.hidden = true
    }
    
    func getSeasons() {
        Alamofire.request(.GET, baseUrl + showsUrl + "/\(currentShow.id)/episodes", encoding: .JSON).responseJSON {
            response in switch response.result {
            case .Success(let JSON):
                var numberOfSeasons = [Int]()
                for episode in (JSON as! NSArray) {
                    let currentEpisode = Episode()
                    currentEpisode.id       = episode.objectForKey("id")        as? Int
                    currentEpisode.season   = episode.objectForKey("season")    as? Int
                    currentEpisode.number   = episode.objectForKey("number")    as? Int
                    currentEpisode.name     = episode.objectForKey("name")      as? String
                    currentEpisode.summary  = self.cleanSummary((episode.objectForKey("summary") as? String)!)
                    self.allEpisodes.addObject(currentEpisode)
                    if !numberOfSeasons.contains(currentEpisode.season!) {
                        numberOfSeasons.append(currentEpisode.season!)
                    }
                }
                for value in 1...numberOfSeasons.count {
                    let episodes = NSMutableDictionary()
                    for episode in self.allEpisodes {
                        if (episode as! Episode).season == value {
                            episodes.setValue((episode as! Episode), forKey: "\((episode as! Episode).number!)")
                        }
                    }
                    self.seasons.setValue(episodes, forKey: "\(value)")
                    self.segSeasons.insertSegmentWithTitle("\(value)", atIndex: value, animated: false)
                }
                self.segSeasons.hidden = false
                self.segSeasons.selectedSegmentIndex = 0
                self.tableView.reloadData()
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func cleanSummary(summary: String) -> String {
        let regex = try! NSRegularExpression(pattern: "<.*?>", options: [.CaseInsensitive])
        let summaryFixed: String = regex.stringByReplacingMatchesInString(summary, options: [], range: NSMakeRange(0, summary.characters.count), withTemplate: "")
        return summaryFixed
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if self.seasons.count > 0 {
            return 1
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! EpisodesTableViewCell
        let currentEpisode = ((self.seasons.valueForKey("\(self.segSeasons.selectedSegmentIndex + 1)")!).valueForKey("\(indexPath.row + 1)") as! Episode)
        cell.lblNumber.text = "\(currentEpisode.number!)."
        cell.lblTitle.text = currentEpisode.name!
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.seasons.valueForKey("\(self.segSeasons.selectedSegmentIndex + 1)")!.count
    }
    
    @IBAction func segSeasons(sender: UISegmentedControl) {
        self.tableView.reloadData()
    }
}

class EpisodesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblNumber:   UILabel!
    @IBOutlet weak var lblTitle:    UILabel!
    
}
