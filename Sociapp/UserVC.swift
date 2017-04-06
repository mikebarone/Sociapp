//
//  UserVC.swift
//  Sociapp
//
//  Created by Mike Barone on 2017-03-25.
//  Copyright © 2017 Mike Barone. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class UserVC: UIViewController, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var genderPicker: UIPickerView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var statusText: UITextField!
    @IBOutlet weak var displayNameText: UITextField!
    
    var genders = [Gender]()
    var imagePicker: UIImagePickerController!
    var imageSelected = false
    
    var userRef: FIRDatabaseReference!
    
    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    var currentProfileImageUrl: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        genderPicker.delegate = self
        genderPicker.dataSource = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.profileImageTapped(_:)))
        profileImage.addGestureRecognizer(tap)
        profileImage.isUserInteractionEnabled = true
        
        loadGenders()
        
        if let userUID = KeychainWrapper.standard.string(forKey: KEY_UID) {
            userRef = DataService.ds.REF_USERS.child(userUID)
        }
        
        userRef.observe(.value, with: { (snapshot) in
            
            if let userDict = snapshot.value as? Dictionary<String, AnyObject> {
                
                if let displayName = userDict["displayName"] as? String {
                    self.displayNameText.text = displayName
                }
                
                if let status = userDict["status"] as? String {
                    self.statusText.text = status
                }
                
                if let gender = userDict["gender"] as? String {
                    var index = 2
                    switch gender {
                    case "Male":
                        index = 0
                        break
                    case "Female":
                        index = 1
                        break
                    default:
                        index = 2
                    }
                    self.genderPicker.selectRow(index, inComponent: 0, animated: false)
                }
                
                if let profileImageUrl = userDict["profileImageUrl"] as? String, profileImageUrl != "" {
                    
                    self.currentProfileImageUrl = profileImageUrl
                    
                    if let img = UserVC.imageCache.object(forKey: profileImageUrl as NSString) {
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
                                        UserVC.imageCache.setObject(img, forKey: profileImageUrl as NSString)
                                    }
                                }
                            }
                        })
                    }
                }
                
            }
        })
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func profileImageTapped(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }

    func loadGenders(){
        genders = []
        genders.append(Gender.Male)
        genders.append(Gender.Female)
        genders.append(Gender.Unspecified)
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let gender = genders[row]
        return gender.rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func savePressed(_ sender: Any) {
        guard let displayName = displayNameText.text, displayName != "" else {
            print("MIKE: displayName must be entered")
            return
        }
        
        guard let img = profileImage.image else {
            print("MIKE: An image must be selected")
            return
        }
        
        if let imgData = UIImageJPEGRepresentation(img, 0.2) {
            
            let imgUid = NSUUID().uuidString
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/jpeg"
            
            DataService.ds.REF_PROFILE_IMAGES.child(imgUid).put(imgData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("MIKE: Unable to upload image to Firebase storage")
                } else {
                    print("MIKE: Successfully uploaded image to Firebase storage")
                    let downloadURL = metadata?.downloadURL()?.absoluteString
                    if let url = downloadURL {
                        let userData = ["displayName": displayName, "status": self.statusText.text ?? "", "profileImageUrl": url, "gender": self.genders[self.genderPicker.selectedRow(inComponent: 0)].rawValue]
                        self.sendToFirebase(imgUrl: url,userData: userData)
                    }
                    
                   
                    let ref: FIRStorageReference!
                    
                    if self.currentProfileImageUrl != "" {
                        ref = FIRStorage.storage().reference(forURL: self.currentProfileImageUrl)
                        
                        if ref != nil {
                            // Delete the file
                            ref.delete { error in
                                if let error = error {
                                    // Uh-oh, an error occurred!
                                    print("Unable to delete the old profile image from firabase \(error)")
                                } else {
                                    // File deleted successfully
                                    print("Old profile image deleted from firabase")
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func sendToFirebase(imgUrl: String, userData: Dictionary<String, Any>) {
        
        if let userUID = KeychainWrapper.standard.string(forKey: KEY_UID) {
           DataService.ds.updateFirbaseDBUser(uid: userUID, userData: userData)
            print("MIKE: Successfully update user to Firebase")
        }
        
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImage.image = image
            imageSelected = true
        } else {
            print("MIKE: A valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
}
