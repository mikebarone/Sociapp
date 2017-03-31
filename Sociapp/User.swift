//
//  User.swift
//  Sociapp
//
//  Created by Mike Barone on 2017-03-25.
//  Copyright © 2017 Mike Barone. All rights reserved.
//

import Foundation
import Firebase

enum Gender: String {
    case Male = "Male"
    case Female = "Female"
    case Unspecified = "Unspecified"
}

class User {
    private var _displayName: String!
    private var _profileImageUrl: String!
    private var _age: Int!
    private var _gender: Gender!
    private var _status: String!
    private var _userKey: String!
    private var _userRef: FIRDatabaseReference!
    
    var displayName: String {
        return _displayName
    }
    
    var profileImageUrl: String {
        return _profileImageUrl
    }
    
    var age: Int {
        return _age
    }
    
    var gender: Gender {
        return _gender
    }
    
    var status: String {
        return _status
    }
    
    init(displayName: String, profileImageUrl: String, age: Int, gemder: Gender, status: String) {
        self._displayName = displayName
        self._profileImageUrl = profileImageUrl
        self._age = age
        self._gender = gender
        self._status = status
    }
    
    init(userKey: String, userData: Dictionary<String, AnyObject>) {
        self._userKey = userKey
        
        if let displayName = userData["displayName"] as? String {
            self._displayName = displayName
        }
        
        if let profileImageUrl = userData["profileImageUrl"] as? String {
            self._profileImageUrl = profileImageUrl
        }
        
        if let age = userData["age"] as? Int {
            self._age = age
        }
        
        if let gender = userData["gender"] as? Gender {
            self._gender = gender
        }
        
        if let status = userData["status"] as? String {
            self._status = status
        }
        
        _userRef = DataService.ds.REF_USERS.child(_userKey)
        
    }
}
