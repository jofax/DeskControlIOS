//
//  BoxControlsViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-06.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import UIKit

class BoxControlsViewModel: BaseViewModel {
    var data = [[String:Any]]()
}

extension BoxControlsViewModel: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActiveStarsTableViewCell.identifier) as! ActiveStarsTableViewCell
        return cell
    }
    
}

extension BoxControlsViewModel: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  80

    }
    
     func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10.0
     }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
        view.backgroundColor = .clear
        return view
    }
}
