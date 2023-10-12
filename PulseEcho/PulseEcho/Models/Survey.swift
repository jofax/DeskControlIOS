//
//  Survey.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-23.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation

struct Survey {
    var SurveyID: Int
    var RuntimeID: Int
    var Category: Int
    var Name: String
    var StartDate: String
    var EndDate: String
    var Status: Int
    var QuestionCount: Int
    var PercentComplete: Double
    var Questions: [SurveyQuestions] = [SurveyQuestions]()
    var LastAnswerDated: String
    var Success: Bool
    var ResultCode: Int
    var Message: String
    
    init(params: [String: Any]) {
        self.SurveyID = params["SurveyID"] as? Int ?? 0
        self.RuntimeID = params["RuntimeID"] as? Int ?? 0
        self.Category = params["Category"] as? Int ?? 0
        self.Name = params["Name"] as? String ?? ""
        self.StartDate = params["StartDate"] as? String ?? ""
        self.EndDate = params["EndDate"] as? String ?? ""
        self.Status = params["Status"] as? Int ?? 0
        self.QuestionCount = params["QuestionCount"] as? Int ?? 0
        self.PercentComplete = params["PercentComplete"] as? Double ?? 0.0
        
        if let _questions = params["Questions"] as? [[String:Any]] {
            for item in _questions {
                self.Questions.append(SurveyQuestions(params: item))
            }
        }
        
        self.LastAnswerDated = params["LastAnswerDated"] as? String ?? ""
        self.Success = params["Success"] as? Bool ?? false
        self.ResultCode = params["ResultCode"] as? Int ?? 0
        self.Message = params["Message"] as? String ?? ""
    }
    
    init(survey: Survey) {
        self.SurveyID = survey.SurveyID
        self.RuntimeID = survey.RuntimeID
        self.Category = survey.Category
        self.Name = survey.Name
        self.StartDate = survey.StartDate
        self.EndDate = survey.EndDate
        self.Status = survey.Status
        self.QuestionCount = survey.QuestionCount
        self.PercentComplete = survey.PercentComplete
        self.Questions = survey.Questions
        self.LastAnswerDated = survey.LastAnswerDated
        self.Success = survey.Success
        self.ResultCode = survey.ResultCode
        self.Message = survey.Message
    }
}
