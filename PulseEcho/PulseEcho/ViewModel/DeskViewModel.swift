//
//  DeskViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2021-06-02.
//  Copyright © 2021 Smartpods. All rights reserved.
//

import Foundation
import Moya
import RealmSwift

class DeskViewModel: BaseViewModel {
    
    //CLASS VARIABLES
    var provider: MoyaProvider<DeskService>?
    
    override init() {
        super.init()
        
    }
    
    override func cancelCurrentRequest() {
        
    }
    
    /**
    Request desk booking information from web service.
    - Parameter String email
    - Parameter Closure  completion
    - Returns: none
    */
    
    func requestDeskBookingInformation(_ parameters: DeskBooking, _ completion: @escaping (( _ response: DeskBookingInfo) -> Void)) {
        cancelCurrentRequest()
        
        print("requestDeskBookingInformation params: \(parameters)")
        
        provider = MoyaProvider<DeskService>(requestClosure: MoyaProvider<DeskService>.endpointRequestResolver(),
                                             session: smartpodsManager(withSSL: true),
                                             plugins: getMoyaPlugins())
        
            
        
        
            provider?.request(.getBookingInfo(parameters)) { [weak self] result in
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        let _booking = rawJson["DeskBookingInfo"] as? [String: Any] ?? [String: Any]()
                        let bookingInfo = DeskBookingInfo(params: _booking)
                        
                        completion(bookingInfo)
                       
                    } catch {
                        print("requestDeskBookingInformation error | info: \(Utilities.instance.loginfo())")
                        if response.statusCode == 401 {
                            self?.apiCallback?(error, 6)
                        } else {
                            self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                            print("requestDeskBookingInformation error | info: \(Utilities.instance.loginfo())")
                        }
                    }
                    
                case .failure(let error):
                    //self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
                    print("requestDeskBookingInformation error: \(error.errorDescription) | info: \(Utilities.instance.loginfo())")
                    
                }
            }
    }
    
}
