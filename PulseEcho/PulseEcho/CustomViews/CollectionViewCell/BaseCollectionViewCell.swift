//
//  BaseCollectionViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-09.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {

    /**
     Static variable nib for identifying the view
     - Returns: Nib file
     */
    
    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    /**
     Static variable string for the view identifier
     - Returns: String filename
     */
    
    static var identifier: String {
        return String(describing: self)
    }
}
