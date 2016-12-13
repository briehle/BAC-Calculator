//
//  User.swift
//  BAC Calculator
//
//  Created by Brandon Riehle on 2/23/16.
//  Copyright © 2016 Brandon Riehle. All rights reserved.
//

import UIKit

class User: NSObject, NSCoding
{
    // MARK: Properties
    var userName: String
    var password: String
    var gender: String
    var weight: String
    var currentBac: Float
    var alcoholConsumedInGrams: Float
    var drinkNumber: Int
    var beginTime: Int64
    var endTime: Int64
    var isCurrentlyDrinking: Bool
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("users")
    
    // MARK: Types
    struct PropertyKey
    {
        static let nameKey = "userName"
        static let passwordKey = "password"
        static let genderKey = "gender"
        static let weightKey = "weight"
        static let currentBacKey = "currentBac"
        static let drinkNumberKey = "drinkNumber"
        static let alcoholConsumedInGramsKey = "alcoholConsumedInGrams"
        static let beginTimeKey = "beginTime"
        static let endTimeKey = "endTime"
        static let isCurrentlyDrinkingKey = "isCurrentlyDrinking"
        static let lastDrinkKey = "lastDrink"
    }
    
    // MARK: Initialization
    init?(userName: String, password: String, gender: String, weight: String)
    {
        self.userName = userName
        self.password = password
        self.gender = gender
        self.weight = weight
        currentBac = 0.0
        alcoholConsumedInGrams = 0.0
        drinkNumber = 0
        endTime = 0
        beginTime = 0
        isCurrentlyDrinking = false
        super.init()
        
        // Initialization should fail if there is no name or if the rating is negative.
        if userName.isEmpty || password.isEmpty || weight.isEmpty
        {
            return nil
        }
    }
    
    init(userName: String, password: String, gender: String, weight: String, currentBac: Float, drinkNumber: Int, alcoholConsumedInGrams: Float, beginTime: Int64, endTime: Int64, isCurrentlyDrinking: Bool)
    {
        self.userName = userName
        self.password = password
        self.gender = gender
        self.weight = weight
        self.drinkNumber = drinkNumber
        self.currentBac = currentBac
        self.alcoholConsumedInGrams = alcoholConsumedInGrams
        self.beginTime = beginTime
        self.endTime = endTime
        self.isCurrentlyDrinking = isCurrentlyDrinking
    }
    
    // MARK: NSCoding
    //method prepares the class’s information to be archived
    func encodeWithCoder(aCoder: NSCoder)
    {
        aCoder.encodeObject(userName, forKey: PropertyKey.nameKey)
        aCoder.encodeObject(password, forKey: PropertyKey.passwordKey)
        aCoder.encodeObject(gender, forKey: PropertyKey.genderKey)
        aCoder.encodeObject(weight, forKey: PropertyKey.weightKey)
        aCoder.encodeInteger(drinkNumber, forKey: PropertyKey.drinkNumberKey)
        aCoder.encodeFloat(currentBac, forKey: PropertyKey.currentBacKey)
        aCoder.encodeFloat(alcoholConsumedInGrams, forKey: PropertyKey.alcoholConsumedInGramsKey)
        aCoder.encodeInt64(beginTime, forKey: PropertyKey.beginTimeKey)
        aCoder.encodeInt64(endTime, forKey: PropertyKey.endTimeKey)
        aCoder.encodeBool(isCurrentlyDrinking, forKey: PropertyKey.isCurrentlyDrinkingKey)
    }
    
    required convenience init(coder aDecoder: NSCoder)
    {
        //unarchives the stored information stored about an object
        let userName = aDecoder.decodeObjectForKey(PropertyKey.nameKey) as! String
        let password = aDecoder.decodeObjectForKey(PropertyKey.passwordKey) as! String
        let gender = aDecoder.decodeObjectForKey(PropertyKey.genderKey) as! String
        let weight = aDecoder.decodeObjectForKey(PropertyKey.weightKey) as! String
        let drinkNumber = aDecoder.decodeIntegerForKey(PropertyKey.drinkNumberKey) as Int
        let currentBac = aDecoder.decodeFloatForKey(PropertyKey.currentBacKey) as Float
        let alcoholConsumedInGrams = aDecoder.decodeFloatForKey(PropertyKey.alcoholConsumedInGramsKey) as Float
        let beginTime = aDecoder.decodeInt64ForKey(PropertyKey.beginTimeKey) as Int64
        let endTime = aDecoder.decodeInt64ForKey(PropertyKey.endTimeKey) as Int64
        let isCurrentlyDrinking = aDecoder.decodeBoolForKey(PropertyKey.isCurrentlyDrinkingKey) as Bool
        
        // Must call designated initilizer.
        self.init(userName: userName, password: password, gender: gender, weight: weight, currentBac: currentBac, drinkNumber: drinkNumber, alcoholConsumedInGrams: alcoholConsumedInGrams, beginTime: beginTime, endTime: endTime, isCurrentlyDrinking: isCurrentlyDrinking)
    }
}

func == (user1: User, user2: User) -> Bool
{
    return (user1.userName == user2.userName)
}


