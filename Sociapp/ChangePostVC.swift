//
//  ChangePostVC.swift
//  Sociapp
//
//  Created by Mike Barone on 2017-04-03.
//  Copyright © 2017 Mike Barone. All rights reserved.
//

import UIKit
import Foundation

protocol ChangePostVCDelegate {
    func postData(data: AnyObject!)
}

class ChangePostVC: UIViewController {

    @IBOutlet weak var captionTextView: UITextView!
    
    var delegate : ChangePostVCDelegate?
    // another data outlet
    var data : AnyObject?
    
    var frameOriginY: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let oldCaption = data as? String {
            captionTextView.text = oldCaption
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChangePostVC.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ChangePostVC.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        frameOriginY = self.view.frame.origin.y
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isBeingDismissed {
            self.delegate?.postData(data: data as AnyObject!)
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        data = "" as AnyObject
        self.dismiss(animated: true, completion: nil)
    }
   
    @IBAction func saveButtonPressed(_ sender: Any) {
        if let caption = captionTextView.text, caption != "" {
            data = caption as AnyObject
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
