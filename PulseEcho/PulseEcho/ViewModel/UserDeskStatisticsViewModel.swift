//
//  UserDeskStatisticsViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-03-26.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Moya

class UserDeskStatisticsViewModel: BaseViewModel {
    //CLASS VARIABLES
    var provider: MoyaProvider<UserReportService>?
    var statistic: Statistics?
    var reports: [[String: Any]] = [["key":"ModePercentage",
                          "title":"Mode Percentage"],
                         ["key":"UpDownPerHour","title":"Up/Down Per Hour"],
                         ["key":"TotalActivity","title":"Total Activity"],
                         ["key":"ActivityByDesk","title":"Desk Activity"]]
    
    var reportDetails:((_ object: Any) -> Void)?
    
    override init() {
        super.init()
    }
    
    /**
    Request to set user connected to device
    - Parameter [String: Any] parameters
    - Parameter Closure completion handler
    - Returns: none
    */
    
    func requestUserStatisticSummary(_ completion: @escaping (( _ response: [String: Any]) -> Void)) {
        cancelCurrentRequest()
        let email = Utilities.instance.getUserEmail()
        let _sectionList = self.reports
        
        
        provider = MoyaProvider<UserReportService>(requestClosure: MoyaProvider<UserReportService>.endpointRequestResolver(),
                                                   session: smartpodsManager(withSSL: true),
                                                   plugins: getMoyaPlugins())
        
            let final_params = addTokenToParameter(params: [:])
            provider?.request(.summary(final_params)) { [weak self] result in
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        if let _reports = rawJson["Report"] as? [String : Any] {
                            self?.statistic = Statistics(params: _reports , email: email)
                            self?.reports.removeAll()
                            
                            for (index, item) in _sectionList.enumerated() {
                                var _item = item
                                let key  = item["key"] as? String ?? ""
                                print("_item : \(_item) at index: \(index)")

                                if key == "ModePercentage" {
                                    _item["data"] = _reports["ModePercentage"]
                                    self?.reports.append(_item)
                                } else if key == "ActivityByDesk" {
                                      _item["data"] = _reports["ActivityByDesk"]
                                        self?.reports.append(_item)
                                } else {
                                    self?.reports.append(_item)
                                }
                            }
                            print("reports object:", self?.reports)
                            completion(rawJson)
                        } else {
                            completion([String: Any]())
                        }
                        
                    } catch {
                        print("requestUserStatisticSummary error | info: \(Utilities.instance.loginfo())")
                        if response.statusCode == 401 {
                            self?.apiCallback?(error, 6)
                        } else {
                            self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                            print("requestProfileSettings error | info: \(Utilities.instance.loginfo())")
                        }
                    }
                    
                case .failure(let error):
                    print("requestUserStatisticSummary error: \(error.localizedDescription)  | info: \(Utilities.instance.loginfo())")
                    if error.errorCode == 6 {
                        self?.refreshSessionToken(completion: { (refreshed) in
                            print("refresh token requestUserStatisticSummary:  \(refreshed)")
                            if refreshed == false {
                                Threads.performTaskAfterDealy(1) {
                                    self?.apiCallback?(error, error.errorCode)
                                }
                            }
                            
                        })
                    }
                    
                }
            }
    }
}

/**
 UITableView Delegate and Datasource
- Returns: none
*/

extension UserDeskStatisticsViewModel: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return reports.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let _section = reports[section]
        let item = _section["key"] as? String ?? ""
        
        if item == "UpDownPerHour" || item == "TotalActivity" {
            return 0
        } else {
            return 1
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: SummaryModeTableViewCell.identifier) as! SummaryModeTableViewCell
        cell.section = indexPath.section
        cell.report = reports[indexPath.section]
        cell.item = statistic
         return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: SummaryTableViewHeader.identifier) as? SummaryTableViewHeader {
            headerView.section = section
            headerView.sectionTitle = reports[section]
            headerView.item = self.statistic
            return headerView
        }
        return UIView()
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

/**
 SummaryTableViewHeaderDelegte delegate methods
- Parameter Int section
- Parameter [String: Any] item
- Returns: none
*/

extension UserDeskStatisticsViewModel: SummaryTableViewHeaderDelegte {
    func headerShowReportDetails(_ section: Int, _ item: [String: Any]) {
        reportDetails?(item)
    }
}
