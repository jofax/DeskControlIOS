//
//  DeskTempCollectionViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-20.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift

class DeskTempCollectionViewCell: BaseCollectionViewCell {

    @IBOutlet weak var imgIcon: UIImageView?
    @IBOutlet weak var lblTitle: UILabel?
    @IBOutlet weak var lblValue: UILabel?
    @IBOutlet weak var lblNightValue: UILabel?
    @IBOutlet weak var lblDayValue: UILabel?
    
    @IBOutlet weak var lblNightTitle: UILabel?
    @IBOutlet weak var lblDayTitle: UILabel?
    
    var object: [String:Any]? {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        lblTitle?.adjustContentFontSize()
        lblValue?.adjustNumberFontSize()
        lblNightValue?.adjustNumberFontSize()
        lblDayValue?.adjustNumberFontSize()
        
        lblDayTitle?.adjustContentFontSize()
        lblNightTitle?.adjustContentFontSize()
    }
    
    func updateUI() {
        guard let item = object else {
            return
        }
        
        let type = item["type"] as? String
        
        if type == "4" {
            imgIcon?.image = UIImage.fontAwesomeIcon(name: .temperatureLow,
                                                     style: .solid,
                                                     textColor: .white,
                                                     size: CGSize(width: 40, height: 40))
        } else if type == "5" {
            imgIcon?.image = UIImage.fontAwesomeIcon(name: .lightbulb,
                                                     style: .solid,
                                                     textColor: .white,
                                                     size: CGSize(width: 40, height: 40))
            
        } else if type == "6" {
            imgIcon?.image = UIImage.fontAwesomeIcon(name: .microphone,
                                                     style: .solid,
                                                     textColor: .white,
                                                     size: CGSize(width: 40, height: 40))
        }
        lblTitle?.text = item["title"] as? String
        lblValue?.text = item["value"] as? String
        lblNightValue?.text = item["night"] as? String
        lblDayValue?.text = item["day"] as? String
    }

}
