//
//  FeedsModel+CoreDataProperties.swift
//  
//
//  Created by gurmukh singh on 10/8/21.
//
//

import Foundation
import CoreData


extension FeedsModel {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FeedsModel> {
        return NSFetchRequest<FeedsModel>(entityName: "FeedsModel")
    }

    @NSManaged public var feedsDataArray: Data?

}
