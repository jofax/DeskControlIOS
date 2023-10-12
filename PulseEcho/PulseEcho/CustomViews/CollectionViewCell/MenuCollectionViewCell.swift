//
//  MenuCollectionViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-01-09.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class MenuCollectionViewCell: BaseCollectionViewCell {
    
    //view outlets
    
    @IBOutlet weak var imgIcon: UIImageView?
    
    // class variables
    var menu: [String:String]? {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        guard let item = menu else {
            return
        }
        let img = item["icon"]
        let img_selected = item["selected"]
        imgIcon?.image = UIImage(named: (isSelected ? img_selected : img) ?? "")
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
