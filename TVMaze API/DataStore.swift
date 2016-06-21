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
    
    func createShow(
        id:     String,
        name:   String,
        summary: String,
        imageM: String,
        imageO: String
        ) -> Bool {
        
        let ShowEntity = NSEntityDescription.entityForName("DBShow", inManagedObjectContext: managedContext)
        let show = DBShow(entity: ShowEntity!, insertIntoManagedObjectContext: managedContext)
        
        show.id     = id
        show.name   = name
        show.summary = summary
        show.imageM = imageM
        show.imageO = imageO
        
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
        let sort = NSSortDescriptor(key: "name", ascending: true, selector: #selector(NSString.localizedStandardCompare))
        request.sortDescriptors = [sort]
        let objects: [AnyObject]?
        objects = (try! managedContext.executeFetchRequest(request))
        let result = NSMutableArray()
        for item in objects! {
            let show    = Show()
            show.id     = (item as! DBShow).id!
            show.name   = (item as! DBShow).name!
            show.summary = (item as! DBShow).summary!
            show.imageM = (item as! DBShow).imageM!
            show.imageO = (item as! DBShow).imageO!
            result.addObject(show)
        }
        return result
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
        let fetchRequest1 = NSFetchRequest(entityName: "Show")
        let deleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        (try! managedContext.executeRequest(deleteRequest1))
        
        return true
    }
    
}