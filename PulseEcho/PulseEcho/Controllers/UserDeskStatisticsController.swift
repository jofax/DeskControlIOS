//
//  UserDeskStatisticsController.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-26.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import EmptyStateKit

class UserDeskStatisticsController: BaseController {

    //STORYBOARD OUTLETS
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var viewContainer: UIView?
    
    //CLASS VARIABLES
    private var viewModel: UserDeskStatisticsViewModel = UserDeskStatisticsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        customizeUI()
        getSummary()
    }
    
    override func viewDidAppear(_ animated: Bool) {
         super.viewDidAppear(animated)
        cloudStatusIndicator()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func customizeUI() {
        let email = Utilities.instance.getUserEmail()
        createCustomNavigationBar(title: "desk_statistics.title".localize(), user: email, cloud: true, back: false, ble: true)
        viewContainer?.addBorder(on: [.top(thickness: 3, color: UIColor(hexstr: Constants.smartpods_blue))])
       
        
        view.emptyState.format = DataState.noData.format
        view.emptyState.delegate = self

        tableView?.estimatedRowHeight = tableView?.rowHeight ?? UITableView.automaticDimension
        
        tableView?.delegate = viewModel
        tableView?.dataSource = viewModel
        

        tableView?.register(SummaryModeTableViewCell.nib, forCellReuseIdentifier: SummaryModeTableViewCell.identifier)
        tableView?.register(DeskActivityTableViewCell.nib, forCellReuseIdentifier: DeskActivityTableViewCell.identifier)
        tableView?.register(SummaryTableViewHeader.nib, forHeaderFooterViewReuseIdentifier: SummaryTableViewHeader.identifier)
        
        //bindViewModelAndCallbacks()
    }
    
    override func bindViewModelAndCallbacks() {
        viewModel.reportDetails = { (item) in
            
        }
        
        viewModel.alertMessage = { [weak self](title: String, message: String, tag: Int) in
            self?.displayStatusNotification(title: message, style: .danger)
        }

        viewModel.showIndicator = { [weak self] (show: Bool) in
            self?.showActivityIndicator(show: show)
        }
        
        viewModel.apiCallback = { [weak self] (_ response : Any, _ status: Int) in
            if status == 6 {
                
                self?.showAlertWithAction(title: "generic.notice".localize(),
                                          message: "generic.invalid_session".localize(),
                                          buttonTitle: "common.ok".localize(), buttonAction: {
                                            self?.logoutUser(useGuest: false)
                                          })
            }
        }

    }
    
    func getSummary() {
        
        guard !Utilities.instance.isGuest else {
            return
        }
        
        let reachable = reachability?.isReachable ?? false
        if  reachable{
           refreshStatistics()
        } else {
          requestStatisticData()
        }
    }

    func refreshStatistics() {
        viewModel.requestUserStatisticSummary({ [weak self] object in
           //update box
            // refresh data
            
            if object.count > 0 {
                self?.view.emptyState.hide()
                self?.requestStatisticData()
                self?.tableView?.isHidden = false
                self?.tableView?.reloadData()
                
            } else {
                self?.tableView?.isHidden = true
                self?.view.emptyState.show(DataState.noData)
            }

        })
    }

    func requestStatisticData() {
    }
    
    func updateUI() {
        
    }
}

extension UserDeskStatisticsController: EmptyStateDelegate {
    
    func emptyState(emptyState: EmptyState, didPressButton button: UIButton) {
        getSummary()
        view.emptyState.hide()
    }
}
