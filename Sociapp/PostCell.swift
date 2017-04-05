//
//  PostCell.swift
//  Sociapp
//
//  Created by Mike Barone on 2017-03-23.
//  Copyright © 2017 Mike Barone. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper
import AVFoundation

class PostCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: CircleView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var postCaption: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeNumber: UILabel!
    @IBOutlet weak var deleteEditPostButton: UIButton!
    @IBOutlet weak var commentsTextView: UITextView!
    @IBOutlet weak var postImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postImageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentButton: UIButton!

    
    var post: Post!
    var likesRef: FIRDatabaseReference!
    var displayNameRef: FIRDatabaseReference!
    var profileImageUrlRef: FIRDatabaseReference!
    
    var showComments: NSMutableAttributedString = NSMutableAttributedString(string:"Show Comments...")
    var allComments: NSMutableAttributedString = NSMutableAttributedString(string:"No comments yet")
    var commentsExpanded: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    public func adjustPostImageSize() {
        if postImage.frame.size.width < (postImage.image?.size.width)! {
                       postImageHeightConstraint.constant = postImage.frame.size.width / (postImage.image?.size.width)! * (postImage.image?.size.height)!
        }
        
        if postImage.frame.size.height < (postImage.image?.size.height)! {
            postImageWidthConstraint.constant = postImage.frame.size.height / (postImage.image?.size.height)! * (postImage.image?.size.height)!
        }
    }
    

    func configureCell(post: Post, img: UIImage? = nil){
        self.post = post
        self.postCaption.text = post.caption
        self.likeNumber.text = "\(post.likes)"
        
        let boldAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Next", size: 15.0)!, NSForegroundColorAttributeName: UIColor.black ]
        let normalAttributes = [ NSFontAttributeName: UIFont(name: "Avenir Next", size: 15.0)!, NSForegroundColorAttributeName: UIColor.gray ]
        
        if post.comments.count > 0 {
            allComments = NSMutableAttributedString(string:"", attributes:normalAttributes)
        }
        
        for comment in post.comments {
            
            let commentUserRef = DataService.ds.REF_USERS.child(comment.value["userId"] as! String).child("displayName")
            commentUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
                if let displayName = snapshot.value as? String {
                    
                    let currentComment = comment.value["comment"] as! String
                    
                    let attributedString = NSMutableAttributedString(string:"\(currentComment)\n", attributes:normalAttributes)
                    let boldString = NSMutableAttributedString(string: "\(displayName) ", attributes:boldAttributes)
                    boldString.append(attributedString)
                    
                    self.allComments.append(boldString)
                }
            })
            
        }
        print(allComments)
        
        if let userUID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            if userUID != post.userId {
                deleteEditPostButton.isHidden = true
            } else {
                deleteEditPostButton.isHidden = false
            }
        }
        
        likesRef = DataService.ds.REF_USER_CURRENT.child("likes").child(post.postKey)
        displayNameRef = DataService.ds.REF_USERS.child(post.userId).child("displayName")
        profileImageUrlRef = DataService.ds.REF_USERS.child(post.userId).child("profileImageUrl")
        
        if img != nil {
            self.postImage.image = img
            adjustPostImageSize()
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
                            self.adjustPostImageSize()
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

    @IBAction func commentPressed(_ sender: Any) {
        
    }
    
    func showCommentsPressed(_ sender: UITapGestureRecognizer) {
        
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
