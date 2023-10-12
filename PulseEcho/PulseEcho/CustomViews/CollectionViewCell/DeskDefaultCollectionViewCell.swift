//
//  DeskDefaultCollectionViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-20.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class DeskDefaultCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblValue: UILabel?
    
    var object: [String:Any]? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle?.adjustContentFontSize()
        lblValue?.adjustNumberFontSize()
        // Initialization code
    }

    func updateUI() {
        guard let item = object else {
            return
        }
        
        lblTitle?.text = item["title"] as? String
        lblValue?.text = item["value"] as? String
    }
    
}
