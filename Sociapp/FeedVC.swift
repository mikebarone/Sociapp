//
//  FeedVC.swift
//  Sociapp
//
//  Created by Mike Barone on 2017-03-22.
//  Copyright © 2017 Mike Barone. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class FeedVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, EditPostVCDelegate, ChangePostVCDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var captionField: UITextField!
    
    lazy var slideInTransitioningDelegate = SlideInPresentationManager()
    
    var posts = [Post]()
    var imagePicker: UIImagePickerController!
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    static var profileImageCache: NSCache<NSString, UIImage> = NSCache()
    var imageSelected = false
    var postSelected: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 320
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        
        DataService.ds.REF_POSTS.observe(.value, with: { (snapshot) in
            
            self.posts = []
            
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAP: \(snap)")
                    if let postDict = snap.value as? Dictionary<String, AnyObject> {
                        let key = snap.key
                        let post = Post(postKey: key, postData: postDict)
                        self.posts.append(post)
                    }
                }
            }
            self.tableView.reloadData()
        
        })
    }
    
    func postData(data: AnyObject!) {
        if let action = data as? String {
            print("NEW CAPTION: \(action)")
            if let post = postSelected, action != "" {
                DataService.ds.REF_POSTS.child(post.postKey).child("caption").setValue(action)
            }
        }
    }
    
    func acceptData(data: AnyObject!) {
        
        if let action = data as? String {
          
            switch action {
            case "delete":
                if let post = postSelected {
                    
                    var refUsers: UInt = 0
                    refUsers = DataService.ds.REF_USERS.observe(.value, with: {(snapshot) in
                        if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                            for snap in snapshot {
                                print("SNAP DELETE: \(snap)")
                                DataService.ds.REF_USERS.child(snap.key).child("likes").child(post.postKey).removeValue(completionBlock: { (error, refer) in
                                    if error != nil {
                                        print(error ?? "Error")
                                    } else {
                                        print("Like for post \(post.postKey) deleted Correctly from User \(snap.key)")
                                    }
                                })
                                
                                DataService.ds.REF_USERS.child(snap.key).child("posts").child(post.postKey).removeValue(completionBlock: { (error, refer) in
                                    if error != nil {
                                        print(error ?? "Error")
                                    } else {
                                        print("Post for post \(post.postKey) deleted Correctly from User \(snap.key)")
                                    }
                                })
                            }
                            DataService.ds.REF_USERS.removeObserver(withHandle: refUsers)
                        }
                    })
                    
                    let refImage = FIRStorage.storage().reference(forURL: post.imageUrl)
                    
                    refImage.delete { error in
                        if let error = error {
                            print("Unable to delete  image from firabase \(error)")
                        } else {
                            print("Post Image deleted Correctly")
                        }
                    }
                    
                    DataService.ds.REF_POSTS.child(post.postKey).removeValue(completionBlock: { (error, refer) in
                        if error != nil {
                            print(error ?? "Error")
                        } else {
                            print(refer)
                            print("Post Removed Correctly")
                        }
                    })
                    
                    tableView.reloadData()
                }
                break
                
            case "edit":
                performSegue(withIdentifier: "ChangePostVC", sender: nil)
                break
                
            default:
                break
            }
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            
            cell.deleteEditPostButton.tag = indexPath.row
            cell.deleteEditPostButton.addTarget(self, action: #selector(FeedVC.goToEditPostVC), for: .touchUpInside)
            
            if let img = FeedVC.imageCache.object(forKey: post.imageUrl as NSString) {
                cell.configureCell(post: post, img: img)
            } else {
                cell.configureCell(post: post)
            }
            return cell
        } else {
            return PostCell()
        }
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            addImageButton.setImage(image, for: UIControlState.normal)
            imageSelected = true
        } else {
            print("MIKE: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func addImagePressed(_ sender: Any) {
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func postPressed(_ sender: Any) {
        guard let caption = captionField.text, caption != "" else {
            print("MIKE: Caption must be entered")
            return
        }
        guard let img = addImageButton.image(for: UIControlState.normal), imageSelected == true else {
            print("MIKE: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_POST_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("MIKE: Unable to upload image to Firebase storage")
                } else {
                    print("MIKE: Successfully uploaded image to Firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        self.postToFirebase(imgUrl: url)
                    }
                }
            }
        }
    }
    
    func postToFirebase(imgUrl: String) {
        
        if let userUID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            let post: Dictionary<String, AnyObject> = [
                "caption": captionField.text! as AnyObject,
                "imageUrl": imgUrl as AnyObject,
                "likes": 0 as AnyObject,
                "userId": userUID as AnyObject
            ]
            
            let firebasePost = DataService.ds.REF_POSTS.childByAutoId()
            firebasePost.setValue(post)
            
            var postsRef: FIRDatabaseReference!
            postsRef = DataService.ds.REF_USER_CURRENT.child("posts").child(firebasePost.key)
            postsRef.setValue(true)
            
            captionField.text = ""
            imageSelected = false
            addImageButton.setImage(UIImage(named: "addimage"), for: UIControlState.normal)
            
            tableView.reloadData()
        }
    }
    
    @IBAction func logOutPressed(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.removeObject(forKey: KEY_UID)
        print("MIKE: \(keychainResult) ID removed from keychain")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "SignInVC", sender: nil)
    }
    
    func goToEditPostVC(sender:UIButton) {
        postSelected = posts[sender.tag]
        performSegue(withIdentifier: "EditPostVC", sender: nil)
    }
    
    func goToChangePostVC(sender:UIButton) {
        postSelected = posts[sender.tag]
        performSegue(withIdentifier: "ChangePostVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? EditPostVC {
            slideInTransitioningDelegate.direction = .bottom
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
            controller.delegate = self
        } else if let controller = segue.destination as? ChangePostVC {
            if let post = postSelected {
                controller.data = post.caption as AnyObject
            }
            slideInTransitioningDelegate.direction = .bottom
            controller.transitioningDelegate = slideInTransitioningDelegate
            controller.modalPresentationStyle = .custom
            controller.delegate = self
        }
    }
}
