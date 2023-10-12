//
//  DeskTypeUsersCollectionViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-21.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class DeskTypeUsersCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblTitle1: UILabel?
    @IBOutlet weak var lblTitle2: UILabel?
    @IBOutlet weak var lblTitle3: UILabel?
    @IBOutlet weak var lblValue1: UILabel?
    @IBOutlet weak var lblValue2: UILabel?
    @IBOutlet weak var lblValue3: UILabel?
       
   var object: [String:Any]? {
       didSet {
           updateUI()
       }
   }
       
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblTitle?.adjustContentFontSize()
        lblTitle1?.adjustContentFontSize()
        lblTitle2?.adjustContentFontSize()
        lblTitle3?.adjustContentFontSize()
        lblValue1?.adjustNumberFontSize()
        lblValue2?.adjustNumberFontSize()
        lblValue3?.adjustNumberFontSize()
        // Initialization code
    }

    
    func updateUI() {
        guard let item = object else {
            return
        }
        
        lblTitle?.text = item["title"] as? String
        lblTitle1?.text = item["row1"] as? String
        lblValue1?.text = item["row1_value"] as? String
        
        lblTitle2?.text = item["row2"] as? String
        lblValue2?.text = item["row2_value"] as? String
        
        lblTitle3?.text = item["row3"] as? String
        lblValue3?.text = item["row3_value"] as? String
        

    }
}
