//
//  DeskActivityTableViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-30.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class DeskActivityTableViewCell: SummaryModeTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func updateUI() {
        guard let _statistics = item else {
            return
        }
        
        dataList = _statistics.ActivityByDesk
        self.collectionView?.reloadData()
      
    }

    
}
