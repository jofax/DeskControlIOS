//
//  BaseTableViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-12.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class BaseTableViewCell: UITableViewCell {

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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
