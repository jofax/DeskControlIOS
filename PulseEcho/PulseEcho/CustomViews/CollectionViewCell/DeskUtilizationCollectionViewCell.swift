//
//  DeskUtilizationCollectionViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-20.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class DeskUtilizationCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblValue: UILabel?
    
    @IBOutlet weak var leftValue: UILabel?
    @IBOutlet weak var leftLbl: UILabel?
    
    @IBOutlet weak var rightValue: UILabel?
    @IBOutlet weak var rightLbl: UILabel?
    
    
    var object: [String:Any]? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle?.adjustContentFontSize()
        lblValue?.adjustNumberFontSize()
        leftLbl?.adjustContentFontSize()
        leftValue?.adjustNumberFontSize()
        rightValue?.adjustNumberFontSize()
        rightLbl?.adjustContentFontSize()
        // Initialization code
    }
    
    func updateUI() {
        guard let item = object else {
            return
        }
        
        lblTitle?.text = item["title"] as? String
        lblValue?.text = item["value"] as? String
        
        leftLbl?.text = item["left_title"] as? String
        leftValue?.text = item["left_value"] as? String
        
        rightLbl?.text = item["right_title"] as? String
        rightValue?.text = item["right_value"] as? String
        

    }

}
