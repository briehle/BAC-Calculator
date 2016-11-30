//
//  Drink.swift
//  BAC Calculator
//
//  Created by Brandon Riehle on 2/23/16.
//  Copyright © 2016 Brandon Riehle. All rights reserved.
//

import UIKit

class Drink: NSObject, NSCoding
{
    // MARK: Properties
    var name: String
    var alcoholContent: Float
    var flozPerServing: Float
    var photo: UIImage?
    var rating: Int
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("drinks")
    
    // MARK: Types
    struct PropertyKey
    {
        static let nameKey = "name"
        static let photoKey = "photo"
        static let ratingKey = "rating"
        static let flozPerServingKey = "flozPerServing"
        static let alcoholContentKey = "alcoholContent"
    }
    
    // MARK: Initialization
    init(name: String, alcoholContent: Float, flozPerServing: Float, photo: UIImage?, rating: Int)
    {
        // Initialize stored properties
        self.name = name
        self.alcoholContent = alcoholContent
        self.flozPerServing = flozPerServing
        self.photo = photo
        self.rating = rating
    }

    // MARK: NSCoding
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(name, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(photo, forKey: PropertyKey.photoKey)
        aCoder.encodeInteger(rating, forKey: PropertyKey.ratingKey)
        aCoder.encodeFloat(flozPerServing, forKey: PropertyKey.flozPerServingKey)
        aCoder.encodeFloat(alcoholContent, forKey: PropertyKey.alcoholContentKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder)
    {
        let name = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        
        // Because photo is an optional property of Drink, use conditional cast.
        let photo = aDecoder.decodeObjectForKey(PropertyKey.photoKey) as? UIImage
        let rating = aDecoder.decodeIntegerForKey(PropertyKey.ratingKey)
        let flozPerServing = aDecoder.decodeFloatForKey(PropertyKey.flozPerServingKey)
        let alcoholContent = aDecoder.decodeFloatForKey(PropertyKey.alcoholContentKey)
        
        // Must call designated initializer.
        self.init(name: name, alcoholContent: alcoholContent, flozPerServing: flozPerServing, photo: photo, rating: rating)
    }
}