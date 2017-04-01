//
//  RoundCornerButton.swift
//  Sociapp
//
//  Created by Mike Barone on 2017-03-31.
//  Copyright © 2017 Mike Barone. All rights reserved.
//

import UIKit

class RoundCornerButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = 7
        
    }
}
