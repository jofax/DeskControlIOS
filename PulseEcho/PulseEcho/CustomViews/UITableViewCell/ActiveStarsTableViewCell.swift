//
//  ActiveStarsTableViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-28.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import FontAwesome_swift

class ActiveStarsTableViewCell: BaseTableViewCell {

    @IBOutlet weak var viewContainer: UIView?
    @IBOutlet weak var btnRun: UIButton?
    @IBOutlet weak var lblTItle: UILabel?
    @IBOutlet weak var lblDetails: UILabel?
    @IBOutlet weak var btnStar: UIButton?
    @IBOutlet weak var btnHeart: UIButton?
    
    override func awakeFromNib() {
        viewContainer?.layer.cornerRadius = frame.height / 2
        btnRun?.layer.cornerRadius = 0.5 * (btnRun?.bounds.size.width ?? 0)
        
        btnStar?.setImage(UIImage.fontAwesomeIcon(name: .star,
                                                  style: .solid,
                                                  textColor: .white,
                                                  size: CGSize(width: 20,height: 20)),
                          for: .normal)
        
        btnRun?.setImage(UIImage.fontAwesomeIcon(name: .running,
                                                  style: .solid,
                                                  textColor: UIColor.init(hexString: Constants.smartpods_gray),
                                                  size: CGSize(width: 80,height: 80)),
                          for: .normal)
        
        btnHeart?.setImage(UIImage.fontAwesomeIcon(name: .heart,
                                                  style: .solid,
                                                  textColor: .white,
                                                  size: CGSize(width: 20,height: 20)),
                          for: .normal)
        
        btnStar?.setTitle("10", for: .normal)
        btnHeart?.setTitle("20%", for: .normal)
        
        lblTItle?.text = "Running"
        lblDetails?.text = "7 mi - 1 hr"
        
        btnHeart?.titleLabel?.adjustContentFontSize()
        btnStar?.titleLabel?.adjustContentFontSize()
        
        lblTItle?.adjustContentFontSize()
        lblDetails?.adjustContentFontSize()
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
