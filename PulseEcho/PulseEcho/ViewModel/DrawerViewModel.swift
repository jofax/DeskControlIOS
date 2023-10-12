//
//  DrawerViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-05-21.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import UIKit

class DrawerViewModel: BaseViewModel {
    var menu = ["Contact Support", "Logout",]
    var selectedMenu:((_ menu: String) -> Void)?
}

extension DrawerViewModel: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Utilities.instance.isGuest ? 1 : menu.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuCell", for: indexPath)
        cell.textLabel?.font = UIFont(name: Constants.smartpods_font_gotham, size: Constants.smartpods_text_size_medium)
        cell.textLabel?.text = menu[indexPath.row]
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = menu[indexPath.row]
        selectedMenu?(selected)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
}
