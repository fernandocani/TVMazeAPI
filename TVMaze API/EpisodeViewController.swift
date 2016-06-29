//
//  EpisodeViewController.swift
//  TVMaze API
//
//  Created by Fernando Cani on 6/23/16.
//  Copyright © 2016 com.fernandocani. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class EpisodeViewController: UIViewController {

    @IBOutlet weak var imgHeader:   UIImageView!
    @IBOutlet weak var imgActivity: UIActivityIndicatorView!
    @IBOutlet weak var lblTitle:    UILabel!
    @IBOutlet weak var txtSummary:  UITextView!
    
    var currentEpisode: Episode!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = viewBlackColor
        self.setLayout()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidLayoutSubviews() {
        self.txtSummary.setContentOffset(CGPointZero, animated: false)
    }

    func setLayout() {
        if currentEpisode.imageO! != "null" {
            self.imgHeader.af_setImageWithURL(NSURL(string: currentEpisode.imageO!)!)
        } else {
            self.imgHeader.hidden   = true
            self.imgActivity.hidden = true
        }
        
        var seasonName = String()
        if currentEpisode.season! < 10 {
            seasonName = "S0\(currentEpisode.season!)"
        } else {
            seasonName = "S\(currentEpisode.season!)"
        }
        var episodeName = String()
        if currentEpisode.number! < 10 {
            episodeName = "E0\(currentEpisode.number!)"
        } else {
            episodeName = "E\(currentEpisode.number!)"
        }
        self.lblTitle.text = seasonName + episodeName + " - " + currentEpisode.name!
        
        
        self.txtSummary.editable        = true
        self.txtSummary.font            = .systemFontOfSize(15.0)
        self.txtSummary.text            = "No summary :("
        if currentEpisode.summary != "" {
            self.txtSummary.text        = currentEpisode.summary
        }
        self.txtSummary.editable        = false
        self.txtSummary.backgroundColor = viewBlackColor
    }
    
    //http://api.tvmaze.com/shows/1/cast
}