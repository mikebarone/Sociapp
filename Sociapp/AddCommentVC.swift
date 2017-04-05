//
//  AddCommentVC.swift
//  Sociapp
//
//  Created by Mike Barone on 2017-04-04.
//  Copyright © 2017 Mike Barone. All rights reserved.
//

import UIKit
import Foundation

protocol AddCommentVCDelegate {
    func commentData(data: AnyObject!)
}

class AddCommentVC: UIViewController {

    @IBOutlet weak var commentTextView: UITextView!
    
    var delegate : AddCommentVCDelegate?
    // another data outlet
    var data : AnyObject?
    
    var frameOriginY: CGFloat!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(self, selector: #selector(AddCommentVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(AddCommentVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        frameOriginY = self.view.frame.origin.y
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isBeingDismissed {
            self.delegate?.commentData(data: data as AnyObject!)
        }
    }

    @IBAction func cancelPressed(_ sender: Any) {
        data = "" as AnyObject
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: Any) {
        if let comment = commentTextView.text, comment != "" {
            data = comment as AnyObject
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == frameOriginY {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != frameOriginY{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
}
