//
//  ListStarsController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-23.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit

class ListStarsController: BaseController {

    //STORYBOARD OUTLETS
    @IBOutlet weak var viewNavigation: MainTopNavigation?
    @IBOutlet weak var tableView: UITableView!
    
    //CLASS VARIABLES
    var viewModel: ActiveStarsViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let email = Utilities.instance.getUserEmail()
        createCustomNavigationBar(title: "active_stars.title".localize(), user: email, cloud: true, back: false, ble: true)
        customizeUI()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func customizeUI() {
        viewNavigation?.delegate = self
        viewModel = ActiveStarsViewModel()
        
        tableView?.delegate = viewModel
        tableView?.dataSource = viewModel
        
        tableView?.register(ActiveStarsTableViewCell.nib, forCellReuseIdentifier: ActiveStarsTableViewCell.identifier)
        tableView?.estimatedRowHeight = 80.0
        tableView?.rowHeight = UITableView.automaticDimension
        tableView?.tableFooterView = UIView()
        
    }
    
    override func bindViewModelAndCallbacks() {
        viewModel?.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            self?.displayStatusNotification(title: message, style: .danger)
        }

        viewModel?.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
        }
    }
    
    @IBAction func onBtnAction(sender: UIButton) {
        
    }
}

extension ListStarsController: MainTopNavigationDelegate {
    func backToPreviewsView() {
        self.navigationController?.popViewController(animated: false)
    }
    
    func backToHomeView() {
        self.navigationController?.popViewController(animated: false)
    }
}
