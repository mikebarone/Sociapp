//
//  PostCell.swift
//  Sociapp
//
//  Created by Mike Barone on 2017-03-23.
//  Copyright © 2017 Mike Barone. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: CircleView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postCaption: UITextField!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumber: UILabel!
    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    var displayNameRef: FIRDatabaseReference!
    var profileImageUrlRef: FIRDatabaseReference!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(post: Post, img: UIImage? = nil){
        self.post = post
        self.postCaption.text = post.caption
        self.likeNumber.text = "\(post.likes)"
        
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        displayNameRef = DataService.ds.REF_USERS.child(post.userId).child("displayName")
        profileImageUrlRef = DataService.ds.REF_USERS.child(post.userId).child("profileImageUrl")
        
        if img != nil {
            self.postImage.image = img
        } else {
            let ref = FIRStorage.storage().reference(forURL: post.imageUrl)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("MIKE: Unable to download image from Firebase storage")
                } else {
                    print("MIKE: Image downloaded from Firebase storage")
                    if let imgData = data {
                        if let img = UIImage(data: imgData) {
                            self.postImage.image = img
                            FeedVC.imageCache.setObject(img, forKey: post.imageUrl as NSString)
                        }
                    }
                }
            })
        }
        
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeButton.setImage(UIImage(named: "heartempty"), for: UIControlState.normal)
            } else {
                self.likeButton.setImage(UIImage(named: "heartfilled"), for: UIControlState.normal)
            }
        })
        
        displayNameRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let displayName = snapshot.value as? String {
                self.username.text = displayName
            }
        })
        
        profileImageUrlRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let profileImageUrl = snapshot.value as? String {
                if let img = FeedVC.profileImageCache.object(forKey: profileImageUrl as NSString) {
                    self.profileImage.image = img
                } else {
                    let ref = FIRStorage.storage().reference(forURL: profileImageUrl)
                    ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            print("MIKE: Unable to download Profile Image from Firebase storage")
                        } else {
                            print("MIKE: Profile Image downloaded from Firebase storage")
                            if let imgData = data {
                                if let img = UIImage(data: imgData) {
                                    self.profileImage.image = img
                                    FeedVC.profileImageCache.setObject(img, forKey: profileImageUrl as NSString)
                                }
                            }
                        }
                    })
                }
            }
        })
        
    }

    @IBAction func likePressed(_ sender: Any) {
        likesRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeButton.setImage(UIImage(named: "heartfilled"), for: UIControlState.normal)
                self.post.adjustLikes(addLike: true)
                self.likesRef.setValue(true)
            } else {
                self.likeButton.setImage(UIImage(named: "heartempty"), for: UIControlState.normal)
                self.post.adjustLikes(addLike: false)
                self.likesRef.removeValue()
            }
        })
    }
    
}
