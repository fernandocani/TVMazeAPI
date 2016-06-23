//
//  DataStore.swift
//  TVMaze API
//
//  Created by Fernando Cani on 6/21/16.
//  Copyright © 2016 com.fernandocani. All rights reserved.
//
import UIKit
import CoreData

class DataStore {
    let managedContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    
    // MARK: - Singleton
    class var sharedInstance: DataStore {
        struct Static {
            static let instance: DataStore = DataStore()
        }
        return Static.instance
    }
    
    func createShow(currentShow: Show) -> Bool {
        
        let ShowEntity = NSEntityDescription.entityForName("DBShow", inManagedObjectContext: managedContext)
        let show = DBShow(entity: ShowEntity!, insertIntoManagedObjectContext: managedContext)
        
        show.id         = currentShow.id
        show.name       = currentShow.name
        show.summary    = currentShow.summary!
        show.imageM     = currentShow.imageM!
        show.imageO     = currentShow.imageO!
        show.genres     = currentShow.genres!
        show.scheduleD  = currentShow.scheduleD!
        show.scheduleT  = currentShow.scheduleT!
        (try! managedContext.save())
        return true
    }
    
    func hasShow() -> Bool {
        let request = NSFetchRequest(entityName: "DBShow")
        let objects: [AnyObject]?
        objects = (try! managedContext.executeFetchRequest(request))
        if objects!.count > 0 {
            return true
        }
        return false
    }
    
    func hasShowByID(id: String) -> Bool {
        let request = NSFetchRequest(entityName: "DBShow")
        request.predicate = NSPredicate(format: "id contains[c] %@", id)
        let objects: [AnyObject]?
        objects = (try! managedContext.executeFetchRequest(request))
        if objects!.count > 0 {
            return true
        }
        return false
    }
    
    func getShows() -> NSMutableArray {
        let request = NSFetchRequest(entityName: "DBShow")
//        let sort = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare))
//        request.sortDescriptors = [sort]
        let objects: [AnyObject]?
        objects = (try! managedContext.executeFetchRequest(request))
        let result = NSMutableArray()
        for item in objects! {
            let show        = Show()
            show.id         = Int((item as! DBShow).id)
            show.name       = (item as! DBShow).name
            show.summary    = (item as! DBShow).summary
            show.imageM     = (item as! DBShow).imageM
            show.imageO     = (item as! DBShow).imageO
            show.genres     = (item as! DBShow).genres
            show.scheduleD  = (item as! DBShow).scheduleD
            show.scheduleT  = (item as! DBShow).scheduleT
            result.addObject(show)
        }
        return result
    }
    
    func getShowByID(id: String) -> Show {
        let request = NSFetchRequest(entityName: "DBShow")
        request.predicate = NSPredicate(format: "id contains[c] %@", id)
        let objects: [AnyObject]?
        objects = (try! managedContext.executeFetchRequest(request))
        let show = Show()
        show.id         = Int((objects!.first as! DBShow).id)
        show.name       = (objects!.first as! DBShow).name
        show.summary    = (objects!.first as! DBShow).summary
        show.imageM     = (objects!.first as! DBShow).imageM
        show.imageO     = (objects!.first as! DBShow).imageO
        show.genres     = (objects!.first as! DBShow).genres
        show.scheduleD  = (objects!.first as! DBShow).scheduleD
        show.scheduleT  = (objects!.first as! DBShow).scheduleT
        return show
    }

    
//    func updateCharacter(
//        id: String,
//        name: String,
//        thumbnailURL: String,
//        thumbnail: NSData?,
//        heroDescription: String,
//        comics: String,
//        series: String,
//        stories: String,
//        events: String,
//        urls: String
//        ) -> Bool {
//        let request = NSFetchRequest(entityName: "Show")
//        request.predicate = NSPredicate(format: "id contains[c] %@", id)
//        let objects: [AnyObject]?
//        objects = (try! managedContext.executeFetchRequest(request))
//        if objects!.count > 0 {
//            let ShowToUpdate = objects!.first as! Show
//            ShowToUpdate.id              = id
//            ShowToUpdate.name            = name
//            ShowToUpdate.thumbnailURL    = thumbnailURL
//            ShowToUpdate.heroDescription = heroDescription
//            ShowToUpdate.comics          = comics
//            ShowToUpdate.series          = series
//            ShowToUpdate.stories         = stories
//            ShowToUpdate.events          = events
//            ShowToUpdate.urls            = urls
//            if thumbnail != nil{
//                ShowToUpdate.thumbnail = thumbnail
//            }
//            (try! managedContext.save())
//            return true
//        }
//        return false
//    }
    
    func whipeCD () -> Bool {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: NSFetchRequest(entityName: "DBShow"))
        (try! managedContext.executeRequest(deleteRequest))
        return true
    }
}