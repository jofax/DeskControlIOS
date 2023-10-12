//
//  SurveyViewModel.swift
//  PulseEcho
//
//  Created by Joseph on 2020-02-17.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import UIKit
import Moya

enum SurveyDataType: Int {
    case isSurvey = 0
    case isCovid = 1
}

class SurveyViewModel: BaseViewModel {
    //CLASS VARIABLES
    var provider: MoyaProvider<SurveyService>?
    var survey: Survey?
    var type = SurveyDataType.isSurvey
    var hasSurvey: Bool = false
    
    override init() {
        super.init()
        survey = Survey(params: ["":""])
    }
    
    convenience init(type: SurveyDataType) {
        self.init()
        self.type = type
        survey = Survey(params: ["":""])
        
    }
    
    override func cancelCurrentRequest() {
        //provider?.session.session.invalidateAndCancel()
    }
    
    override func checkDatabaseTable() {
        
    }
    
    override func updateRecordinTable(object: Any) {
        
    }
    
    func refreshSurveyData(_ survey: Survey) {
        self.survey = Survey(survey: survey)
    }
    
    
    /**
    Request survey data.
    - Parameter [String: Any] parameters
    - Parameter Closure completion handler
    - Returns: none
    */
    
    func requestAvailableSurvey(_ completion: @escaping (( _ response: Any) -> Void)) {
        cancelCurrentRequest()
        provider = MoyaProvider<SurveyService>(requestClosure: MoyaProvider<SurveyService>.endpointRequestResolver(),
                                               session: smartpodsManager(withSSL: true),
                                             plugins: [
                                                NetworkActivityPlugin(networkActivityClosure: { [weak self] (NetworkActivityChangeType, TargetType) in
                                                    
                                                    switch NetworkActivityChangeType {
                                                    case .began:
                                                        self?.showIndicator?(true)
                                                        break
                                                    case .ended:
                                                        self?.showIndicator?(false)
                                                        break
                                                    }
                                                })])
            let final_params = addTokenToParameter(params: [:])
            provider?.request(.getSurvey(final_params)) { [weak self] result in
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        let result = GenericResponse(params: rawJson)
                        let _object = rawJson["Survey"] as? [String: Any] ?? [String: Any]()
                        
                        guard result.Success && _object.count > 0 else {
                            self?.hasSurvey = false
                            completion(rawJson)
                            return
                        }
                        
                        let _last_date = Utilities.instance.getStringDate()
                        
                        print("last_date: ", _last_date)
                        
                        Utilities.instance.saveDefaultValueForKey(value: _last_date, key: "survey_last_checked")
                        Utilities.instance.newSurveyAvailable = true
                        self?.badgeView?()
                        
                        let _survey = Survey(params: _object)
                        self?.survey = _survey
                        //print("rawJson: ", _survey)
                        self?.hasSurvey = true
                        completion(_survey)
                        
                    } catch {
                        self?.hasSurvey = false
                        completion([String:Any]())
                        self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                        //log.debug("requestAvailableSurvey error")
                        
                        if response.statusCode == 401 {
                            self?.apiCallback?(error, 6)
                        } else {
                            self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                            //log.error("requestProfileSettings error")
                        }
                    }
                    
                case .failure(let error):
                    completion([String:Any]())
                    //self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
                    //log.debug("requestAvailableSurvey error: \(error.localizedDescription)")
                    
                    if error.errorCode == 6 {
                        self?.refreshSessionToken(completion: { (refreshed) in
                            print("refresh token requestAvailableSurvey:  \(refreshed)")
                            
                            
                            
                            if refreshed == false {
                                Threads.performTaskAfterDealy(1) {
                                    Utilities.instance.alertPopUpWithActions(title: "generic.notice".localize(),
                                                              message: "generic.invalid_session".localize(),
                                                              buttonTitle: "common.ok".localize(), buttonAction: {
                                                                BaseController().logoutUser(useGuest: false)
                                                              })
                                }
                            }
                            
                        })
                    }
                }
            }
    }
    
    /**
    Submit survey answer.
    - Parameter [String: Any] parameters
    - Parameter Closure completion handler
    - Returns: none
    */
    
    func requestSubmitSurveryAnswers(_ parameters: [String: Any], _ completion: @escaping (( _ response: Any) -> Void)) {
        cancelCurrentRequest()
        provider = MoyaProvider<SurveyService>(requestClosure: MoyaProvider<SurveyService>.endpointRequestResolver(),
                                               session: smartpodsManager(withSSL: true),
                                             plugins: getMoyaPlugins())
        
            let final_params = addTokenToParameter(params: parameters)
            provider?.request(.sendAnswers(final_params)) { [weak self] result in
                switch result {
                case .success(let response):
                    do {
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        let json = try filteredResponse.mapJSON()
                        let rawJson = json as? [String: Any] ?? [String: Any]()
                        let result = GenericResponse(params: rawJson)
                        Utilities.instance.newSurveyAvailable = false
                        print("rawJson answer responses: ", rawJson)
                        self?.hasSurvey = false
                        completion(result)

                        
                    } catch {
                        
                        //self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                        //log.debug("requestSubmitSurveryAnswers error")
                        
                        if response.statusCode == 401 {
                            self?.apiCallback?(error, 6)
                        } else {
                            self?.alertMessage?("generic.error_title".localize(),"generic.other_error".localize(),0)
                            print("requestProfileSettings error | info: \(Utilities.instance.loginfo())")
                        }
                    }
                    
                case .failure(let error):
                    self?.alertMessage?("generic.error_title".localize(),error.errorDescription ?? "",0)
                    //log.debug("requestSubmitSurveryAnswers error: \(error.localizedDescription)")
                    
                    
                }
            }
    }
    
    func submitSurveyAnswers(_ completion: @escaping (( _ response: Any) -> Void)) {
        var _answers = [[String: Any]]()
        let questions = survey?.Questions
        let userEmail = Utilities.instance.getUserEmail()
        let dateAnswer = Utilities.instance.stringDate(date: Date())
        if let _questions = questions {
            for item in _questions {
                if item.SelectedAnswer != -1 {
                    _answers.append(["AnswerID":0,
                                     "QuestionRunID": item.QuestionRunID,
                                     "ScaleOptionID": item.SelectedAnswer,
                                     "Email": userEmail,
                                     "Dated":dateAnswer])
                }
            }
        }
        
        guard _answers.count > 0 else {
            self.alertMessage?("generic.error_title".localize(),"survey.no_answers".localize(),1)
            return
        }
        
        let answers = ["Answers": _answers]
        self.requestSubmitSurveryAnswers(answers) { (object) in
            completion(object)
        }
        
    }
    
    func updateSurveyAnswer(index: Int, question: SurveyQuestions) {
        
        guard self.survey != nil else {
            return
        }
        
        var questions = self.survey?.Questions
        
        guard questions?.count ?? 0 > 0 else {
            return
        }
        
        questions?.remove(at: index)
        questions?.insert(question, at: index)
        self.survey?.Questions = questions ?? [SurveyQuestions]()
        
        print("survery question: ", question)
    }
}

extension SurveyViewModel:  UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.survey?.Questions.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if type == .isSurvey {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SurveyCollectionViewCell.identifier, for: indexPath) as! SurveyCollectionViewCell
            cell.delegate = self
            let question = self.survey?.Questions[indexPath.row]
            cell.index = indexPath.row
            cell.surveyQuestions = question
            return cell
        } else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CovidCollectionViewCell.identifier, for: indexPath) as! CovidCollectionViewCell
            cell.covidCellDelegate = self
            let question = self.survey?.Questions[indexPath.row]
            cell.index = indexPath.row
            cell.covidDetails = question
            cell.covidTotalQuestions = self.survey?.QuestionCount ?? -1
            return cell
        }
    }
}


extension SurveyViewModel: UICollectionViewDelegate {
    
}

extension SurveyViewModel: SurveyCollectionViewCellDelegate {
    func addAnswer(index: Int, question: SurveyQuestions) {
        self.updateSurveyAnswer(index: index, question: question)
    }
    
}

extension SurveyViewModel: CovidCollectionViewCellDelegate {
    func submitCovidAnswers() {
        successResponse?(["":""])
    }
}
