//
//  PercentageCollectionViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-27.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class PercentageCollectionViewCell: BaseCollectionViewCell {
    
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblValue: UILabel?
    var report =  [String:Any]()
    var object: [String:Any]? {
        didSet {
            updateModePercentage()
        }
    }
    
    var activity: DeskActivities? {
        didSet {
            updateDeskActivityPercentage()
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        lblTitle?.adjustContentFontSize()
        lblValue?.adjustContentFontSize()
    }

    func updateModePercentage() {
        guard let item = object else {
            return
        }
        
        lblTitle?.text = item["title"] as? String
        let _value = item["value"] as? Double ?? 0.0
        lblValue?.text =  String(format: "%.2f%%", _value)
    }
    
    func updateDeskActivityPercentage() {
        guard let item = activity else {
            return
        }
        
        lblTitle?.text = String(format: "Serial #: %@", item.SerialNumber)
        lblValue?.text = String(format: "%.2f%%", item.PercentStanding)

    }
}

