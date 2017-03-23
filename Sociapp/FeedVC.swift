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

class FeedVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    @IBAction func signOutTapped(_ sender: Any) {
        let keychainResult = KeychainWrapper.standard.remove(key: KEY_UID)
        print("MIKE: \(keychainResult) ID removed from keychain")
        try! FIRAuth.auth()?.signOut()
        performSegue(withIdentifier: "SignInVC", sender: nil)
    }
    
    
}
