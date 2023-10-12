//
//  ReportDetailsViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-01.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Moya

class ReportDetailsViewModel: BaseViewModel {
    //CLASS VARIABLES
    var provider: MoyaProvider<UserReportService>?
    var statistic: Statistics?
    var reports: [[String: Any]] = [["key":"ModePercentage",
                          "title":"Mode Percentage"],
                         ["key":"UpDownPerHour","title":"Up/Down Per Hour"],
                         ["key":"ActivityByDesk","title":"Desk Activity"]]
    
    var reportDetails:((_ object: Any) -> Void)?
    
    override init() {
        super.init()
    }
    
    override func cancelCurrentRequest() {
        //provider?.session.session.invalidateAndCancel()
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
        
        /*let _reports = ["ModePercentage": ["SemiAutomatic":59.4059405940594,
                                          "Automatic":0.99009900990099009,
                                          "Manual":39.603960396039604],
                       "UpDownPerHour":2.360396039603,
                       "ActivityByDesk":[["SerialNumber":"1999",
                                          "PercentStanding":70.588235294117652]]] as [String : Any]
        self.statistic = Statistics(params: _reports , email: email)
        var _sectionList = reports
        reports.removeAll()
        
        for (index, item) in _sectionList.enumerated() {
            var _item = item
            let key  = item["key"] as? String ?? ""
            print("_item : \(_item) at index: \(index)")

            if key == "ModePercentage" {
                _item["data"] = _reports["ModePercentage"]
                reports.append(_item)
            } else if key == "ActivityByDesk" {
                  _item["data"] = _reports["ActivityByDesk"]
                   reports.append(_item)
            } else {
                reports.append(_item)
            }
        }
        print("reports object:", reports)
        

        completion(_reports)
        
        return*/
        let _sectionList = self.reports
        provider = MoyaProvider<UserReportService>(requestClosure: MoyaProvider<SurveyService>.endpointRequestResolver(),
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
                        //completion(rawJson)
                        if let _reports = rawJson["Report"] as? [String : Any] {
                            //self?.report = reports
                            
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
                        }
                        
                    } catch {
                        //self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                        print("requestUserStatisticSummary error | info: \(Utilities.instance.loginfo())")
                        if response.statusCode == 401 {
                            self?.apiCallback?(error, 6)
                        } else {
                            self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                            print("requestProfileSettings error | info: \(Utilities.instance.loginfo())")
                        }
                    }
                    
                case .failure(let error):
                    self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
                    print("requestUserStatisticSummary error: \(error.localizedDescription) | info: \(Utilities.instance.loginfo())")
                    
                }
            }
    }
}
