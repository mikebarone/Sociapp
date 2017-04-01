//
//  EditPostVC.swift
//  Sociapp
//
//  Created by Mike Barone on 2017-03-31.
//  Copyright © 2017 Mike Barone. All rights reserved.
//

import UIKit
import Foundation

protocol EditPostVCDelegate {
    func acceptData(data: AnyObject!)
}

class EditPostVC: UIViewController {

    var delegate : EditPostVCDelegate?
    // another data outlet
    var data : AnyObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isBeingDismissed {
            //if let pokeSel = selectedPokemon {
            //    self.delegate?.acceptData(data: pokeSel.pokedexId as AnyObject!)
            //}
        }
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
