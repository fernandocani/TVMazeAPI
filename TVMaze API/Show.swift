//
//  Show.swift
//  TVMaze API
//
//  Created by Fernando Cani on 6/21/16.
//  Copyright © 2016 com.fernandocani. All rights reserved.
//

import UIKit
import CoreData

@objc(DBShow)
class DBShow: NSManagedObject {
    
    @NSManaged var id:          NSNumber
    @NSManaged var name:        String
    @NSManaged var summary:     String
    @NSManaged var imageM:      String
    @NSManaged var imageO:      String
    @NSManaged var genres:      [String]
    @NSManaged var scheduleD:   [String]
    @NSManaged var scheduleT:   String
    @NSManaged var favorite:    Bool
    
}

class Show {
    
    var id:         Int!
    var name:       String!
    var summary:    String?
    var imageM:     String?
    var imageO:     String?
    var genres:     [String]?
    var scheduleD:  [String]?
    var scheduleT:  String?
    var favorite:   Bool?
    
}