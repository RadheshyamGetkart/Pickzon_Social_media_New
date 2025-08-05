//
//  StoryDataModel+CoreDataProperties.swift
//  
//
//  Created by gurmukh singh on 10/8/21.
//
//

import Foundation
import CoreData


extension StoryDataModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StoryDataModel> {
        return NSFetchRequest<StoryDataModel>(entityName: "StoryDataModel")
    }

    @NSManaged public var stortyDataArray: Data?

}
