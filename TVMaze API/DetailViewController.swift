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
    @IBOutlet weak var actLoading: UIActivityIndicatorView!
    
    var currentShow:    Show!
    var selectedImage:  UIImage!
    let allEpisodes     = NSMutableArray()
    let seasons         = NSMutableDictionary()
    let cellIdentifier  = "episodesCell"
    let characters      = NSMutableArray()
    let persons         = NSMutableArray()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = viewBlackColor
        self.setLayout()
        self.getSeasons()
    }
    
    override func viewDidLayoutSubviews() {
        self.txtSummary.setContentOffset(CGPointZero, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func setFav(fav: Bool) {
        var imageName = ""
        if fav { imageName = "fav" } else { imageName = "unfav" }
        let favImage = UIImage(named: imageName)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: favImage, style: .Plain, target: self, action: #selector(DetailViewController.favChange))
    }
    
    func setLayout() {
        navigationItem.title = currentShow.name
        self.setFav(currentShow.favorite!)
        
        self.imgHeader.image = selectedImage//af_setImageWithURL(NSURL(string: currentShow.imageM!)!)
        self.txtSummary.editable        = true
        self.txtSummary.font            = .systemFontOfSize(15.0)
        self.txtSummary.text            = currentShow.summary
        self.txtSummary.editable        = false
        self.txtSummary.backgroundColor = viewBlackColor
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
        self.lblSchedule.text = self.lblSchedule.text! + "'s @ " + currentShow.scheduleT!
        
        self.segSeasons.removeAllSegments()
        self.segSeasons.hidden  = true
        self.tableView.hidden   = true
        self.actLoading.hidden  = false
        self.tableView.backgroundColor = UIColor.clearColor()
    }
    
    func getSeasons() {
        let url = baseUrl + showsUrl + "/\(currentShow.id)" + "/episodes"
        print(url)
        Alamofire.request(.GET, url, encoding: .JSON).responseJSON {
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
                    if let image = episode.objectForKey("image") as? NSDictionary {
                        currentEpisode.imageO = image.objectForKey("original") as? String
                    } else {
                        currentEpisode.imageO = "null"
                    }
                    currentEpisode.airedOn = self.convertDateFormater((episode.objectForKey("airstamp") as? String)!)
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
                self.segSeasons.selectedSegmentIndex = 0
                self.segSeasons.hidden  = false
                self.tableView.hidden   = false
                self.actLoading.hidden  = true
                self.getCurrentSeason()
                self.tableView.reloadData()
                self.getCast()
            case .Failure(let error):
                print("Request failed with error: \(error)")
            }
        }
    }
    
    func getCast() {
//        Alamofire.request(.GET, baseUrl + showsUrl + "/\(currentShow.id)/cast", encoding: .JSON).responseJSON {
//            response in switch response.result {
//            case .Success(let JSON):
//                for currentCast in (JSON as! NSArray) {
//                    print(currentCast)
//                    let currentCharacter    = currentCast.objectForKey("character") as! NSDictionary
//                    let character = Person()
//                    character.id            = currentCharacter.objectForKey("id")                               as! Int
//                    character.name          = currentCharacter.objectForKey("name")                             as? String
//                    character.imageO        = currentCharacter.objectForKey("image")!.objectForKey("original")  as? String
//                    self.characters.addObject(character)
//                    let currentPerson       = currentCast.objectForKey("person")    as! NSDictionary
//                    let person = Person()
//                    person.id               = currentPerson.objectForKey("id")                               as! Int
//                    person.name             = currentPerson.objectForKey("name")                             as? String
//                    person.imageO           = currentPerson.objectForKey("image")!.objectForKey("original")  as? String
//                    self.persons.addObject(person)
//                }
//            case .Failure(let error):
//                print("Request failed with error: \(error)")
//            }
//        }
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
//        let currentEpisode = ((self.seasons.valueForKey("\(self.segSeasons.selectedSegmentIndex + 1)")!).valueForKey("\(indexPath.row + 1)") as! Episode)
        let currentEpisode = currentSeason[indexPath.row]
        cell.lblNumber.text = "\(currentEpisode.number!)."
        cell.lblTitle.text = currentEpisode.name!
        cell.lblAiredOn.text = currentEpisode.airedOn!
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.currentSeason.count
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell        = sender as! UITableViewCell
        let indexPath   = tableView.indexPathForCell(cell)!
        if segue.identifier == "toEpisode" {
            let vc = segue.destinationViewController as! EpisodeViewController
            vc.currentEpisode = ((self.seasons.valueForKey("\(self.segSeasons.selectedSegmentIndex + 1)")!).valueForKey("\(indexPath.row + 1)") as! Episode)
        }
    }
    
    var currentSeason = [Episode]()
    
    @IBAction func segSeasons(sender: UISegmentedControl) {
        self.getCurrentSeason()
        self.tableView.reloadData()
        self.tableView.setContentOffset(CGPointZero, animated: true)
        self.tableView.scrollsToTop = true
    }
    
    func favChange() {
        let id = currentShow.id
        if currentShow.favorite == true {
            if DataStore.sharedInstance.favoriteShowByID("\(id)", favorite: false) {
                self.currentShow = DataStore.sharedInstance.getShowByID("\(id)")
            }
        } else {
            if DataStore.sharedInstance.favoriteShowByID("\(id)", favorite: true) {
                self.currentShow = DataStore.sharedInstance.getShowByID("\(id)")
            }
        }
        self.setFav(self.currentShow.favorite!)
    }
    
    func getCurrentSeason() {
        if currentSeason.count > 0 {
            currentSeason.removeAll()
        }
        let season = (self.seasons.valueForKey("\(self.segSeasons.selectedSegmentIndex + 1)")!) as! NSDictionary
        let seasonDict = season as Dictionary
        let sortedKeys = seasonDict.keys.sort( { (seasonDict[$0] as! Episode).number < (seasonDict[$1] as! Episode).number } )
        
        for value in 0...(sortedKeys.count - 1) {
            currentSeason.append(season.valueForKey("\(sortedKeys[value])") as! Episode)
        }
    }
    
    func convertDateFormater(date: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssSSSZ"
        //        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        
        guard let date = dateFormatter.dateFromString(date) else {
            //            assert(false, "no date from string")
            return "TBA"
        }
        
        dateFormatter.dateFormat = "dd/MMM/yyyy"
        //        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        let timeStamp = dateFormatter.stringFromDate(date)
        
        return timeStamp
    }
    
}

class EpisodesTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblNumber:   UILabel!
    @IBOutlet weak var lblTitle:    UILabel!
    @IBOutlet weak var lblAiredOn: UILabel!
    
}
