//
//  Post.swift
//  Sociapp
//
//  Created by Mike Barone on 2017-03-23.
//  Copyright © 2017 Mike Barone. All rights reserved.
//

import Foundation
import Firebase

class Post {
    private var _caption: String!
    private var _imageUrl: String!
    private var _likes: Int!
    private var _userId: String!
    private var _postKey: String!
    private var _postRef: FIRDatabaseReference!
    private var _comments: Dictionary<String, AnyObject>!
    
    var commentsExpanded: Bool = false
    
    var caption: String {
        return _caption
    }
    
    var imageUrl: String {
        return _imageUrl
    }
    
    var likes: Int {
        return _likes
    }
    
    var userId: String {
        return _userId
    }
    
    var postKey: String {
        return _postKey
    }
    
    var comments: Dictionary<String, AnyObject> {
        if _comments == nil {
            return Dictionary()
        }
        return _comments
    }
    
    
    init(caption: String, imageUrl: String, likes: Int, userId: String) {
        self._caption = caption
        self._imageUrl = caption
        self._likes = likes
        self._userId = userId
    }
    
    init(postKey: String, postData: Dictionary<String, AnyObject>) {
        self._postKey = postKey
        
        if let caption = postData["caption"] as? String {
            self._caption = caption
        }
        
        if let imageUrl = postData["imageUrl"] as? String {
            self._imageUrl = imageUrl
        }
        
        if let likes = postData["likes"] as? Int {
            self._likes = likes
        }
        
        if let userId = postData["userId"] as? String {
            self._userId = userId
        }
        
        if let comments = postData["comments"] as? Dictionary<String, AnyObject> {
            self._comments = comments
        }
        
        _postRef = DataService.ds.REF_POSTS.child(_postKey)
        
    }
    
    func adjustLikes(addLike: Bool) {
        if addLike {
            _likes = _likes + 1
        } else {
            _likes = likes - 1
        }
        _postRef.child("likes").setValue(_likes)
        
    }
    
}
