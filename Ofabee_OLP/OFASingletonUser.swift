//
//  OFASingletonUser.swift
//  Ofabee_OLP
//
//  Created by Administrator on 8/9/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFASingletonUser: NSObject {
    class var ofabeeUser : OFASingletonUser {
        struct user {
            static var instance = OFASingletonUser()
        }
        return user.instance
    }
    
    var user_name : String?
    var user_email : String?
    var user_imageURL : String?
    var user_phone : String?
    var user_about : String?
    var user_id : String?
    
    func initWithDictionary(dicData:NSDictionary){
        self.user_name = HandleNullValues.string(toCheckNull: dicData["us_name"] as? String)
        self.user_email = HandleNullValues.string(toCheckNull: dicData["us_email"] as? String)
        self.user_imageURL = HandleNullValues.string(toCheckNull: dicData["us_image"] as? String)
        self.user_phone = HandleNullValues.string(toCheckNull: dicData["us_phone"] as? String)
        self.user_about = HandleNullValues.string(toCheckNull: dicData["us_about"] as? String)
        self.user_id = "\(dicData["id"]!)"
    }
    
    func updateUserDetailsFromCoreData(dicData:NSDictionary){
        self.user_name = HandleNullValues.string(toCheckNull: dicData["us_name"] as? String)
        self.user_email = HandleNullValues.string(toCheckNull: dicData["us_email"] as? String)
        self.user_imageURL = "\(dicData["us_image"]!)"
        self.user_phone = HandleNullValues.string(toCheckNull: dicData["us_phone"] as? String)
        self.user_about = HandleNullValues.string(toCheckNull: dicData["us_about"] as? String)
        self.user_id = "\(dicData["user_id"]!)"
    }
    
    func updateProfileDetails(dicData:NSDictionary){
        self.user_name = HandleNullValues.string(toCheckNull: dicData["us_name"] as? String)
        self.user_phone = HandleNullValues.string(toCheckNull: dicData["us_phone"] as? String)
        self.user_imageURL = "\(dicData["us_image"]!)"
    }
}
