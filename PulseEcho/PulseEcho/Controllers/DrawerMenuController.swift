//
//  DrawerMenuController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-05-21.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

protocol DrawerMenuControllerDelegate: class {
    func contactSupport()
}

class DrawerMenuController: BaseController {
    
    @IBOutlet weak var tableView: UITableView?
    var drawerDelegate: DrawerMenuControllerDelegate?
    var viewModel: DrawerViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeUI()
        // Do any additional setup after loading the view.
    }

    override func customizeUI() {
        self.viewModel = DrawerViewModel()
        self.tableView?.tableFooterView = UIView()
        self.tableView?.delegate = viewModel
        self.tableView?.dataSource = viewModel
        
        self.viewModel?.selectedMenu = { [weak self] (menu: String) in
                   
                   if menu == "Logout" {
                    self?.logoutUser(useGuest: false)
                   }
                   
                   if menu == "Contact Support" {
                       self?.drawerDelegate?.contactSupport()
                   }
                   
               }
    }
}
