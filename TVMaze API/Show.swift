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
    
    @NSManaged var id:      String?
    @NSManaged var name:    String?
    @NSManaged var summary:  String?
    @NSManaged var imageM:  String?
    @NSManaged var imageO:  String?
    
}

class Show {
    
    var id:      String?
    var name:    String?
    var summary:  String?
    var imageM:  String?
    var imageO:  String?
    
}