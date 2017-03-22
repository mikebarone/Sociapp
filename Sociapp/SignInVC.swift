//
//  ViewController.swift
//  Sociapp
//
//  Created by Mike Barone on 2017-03-21.
//  Copyright © 2017 Mike Barone. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase


class SignInVC: UIViewController {

    @IBOutlet weak var emailField: FancyField!
    @IBOutlet weak var passwordField: FancyField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func facebookButtonPressed(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("MIKE: Unable to authenticate with facebook - \(error)")
            } else if result?.isCancelled == true{
                print("MIKE: User canceled facebook authentication")
            } else {
                print("MIKE: Facebook authentication ok")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseAuth(credential)
            }
        }
    }
    
    func firebaseAuth(_ credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if error != nil {
                print("MIKE: Unable to authenticate with Firebase - \(error)")
            } else {
                print("MIKE: Successfully authenticated with Firebase")
                if let user = user {
                    let userData = ["provider": credential.provider]
                    //self.completeSignIn(id: user.uid, userData: userData)
                }
            }
        })
    }

    @IBAction func signinPressed(_ sender: Any) {
        if let email = emailField.text, let pwd = passwordField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: pwd, completion: { (user, error) in
                if error == nil {
                    print("MIKE: Email user authenticated with Firebase")
                    if let user = user {
                        let userData = ["provider": user.providerID]
                        //self.completeSignIn(id: user.uid, userData: userData)
                    }
                } else {
                    FIRAuth.auth()?.createUser(withEmail: email, password: pwd, completion: { (user, error) in
                        if error != nil {
                            print("MIKE: Unable to authenticate with Firebase using email")
                        } else {
                            print("MIKE: Successfully authenticated with Firebase")
                            FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
                                print("MIKE: Verification email sent!")
                            })
                            if let user = user {
                                let userData = ["provider": user.providerID]
                                //self.completeSignIn(id: user.uid, userData: userData)
                            }
                        }
                    })
                }
            })
        }
    }
}

