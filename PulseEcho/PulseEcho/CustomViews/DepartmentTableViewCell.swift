//
//  DepartmentTableViewCell.swift
//  PulseEcho
//
//  Created by Joseph on 2020-05-08.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class DepartmentTableViewCell: UITableViewCell {

      // MARK: Properties
        
    static let identifier = String(describing: DepartmentTableViewCell.self)

    // MARK: Initialize
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = nil
        textLabel?.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_text_size_small)
        textLabel?.textColor = UIColor(hexString: Constants.smartpods_gray)
        contentView.backgroundColor = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    // MARK: Configure Selection
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        accessoryType = selected ? .checkmark : .none
    }
}
