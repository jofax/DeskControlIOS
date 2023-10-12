//
//  BaseTableHeaderView.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-27.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class BaseTableHeader: UITableViewHeaderFooterView {

    static var nib:UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
