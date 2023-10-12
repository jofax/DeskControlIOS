//
//  Questions.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-23.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation

struct SurveyQuestions {
    var QuestionRunID: Int
    var QuestionID: Int
    var Answer: Int
    var Rank: Int
    var Language: Int
    var Text: String
    var ImageURL: String
    var ScaleOptions: [SurveyScaleOptions] = [SurveyScaleOptions]()
    var Details: [QuestionDetails] = [QuestionDetails]()
    var SelectedScaleOptionID: Int
    var SelectedAnswer: Int
    
    init(params: [String: Any]) {
         self.QuestionRunID = params["QuestionRunID"] as? Int ?? 0
         self.QuestionID = params["QuestionID"] as? Int ?? 0
         self.Answer = params["Answer"] as? Int ?? 0
         self.Rank = params["Rank"] as? Int ?? 0
         self.Language = params["Language"] as? Int ?? 0
         self.ImageURL = params["ImageURL"] as? String ?? ""
         self.Text = params["Text"] as? String ?? ""
         self.SelectedAnswer = -1
        
         if let _options = params["ScaleOptions"] as? [[String:Any]] {
             for item in _options {
                self.ScaleOptions.append(SurveyScaleOptions(params: item))
             }
         }
        
        if let _details = params["Details"] as? [String] {
            for item in _details {
                self.Details.append(QuestionDetails(param: item))
            }
        }
        
         self.SelectedScaleOptionID = params["SelectedScaleOptionID"] as? Int ?? 0
    }
    
    init(object: SurveyQuestions) {
         self.QuestionRunID = object.QuestionRunID
         self.QuestionID = object.QuestionID
         self.Answer = object.Answer
         self.Rank = object.Rank
         self.Language = object.Language
         self.ImageURL = object.ImageURL
         self.Text = object.Text
         self.SelectedAnswer = object.SelectedAnswer
         self.ScaleOptions = object.ScaleOptions
         self.Details = object.Details
         self.SelectedScaleOptionID = object.SelectedScaleOptionID
    }
}


struct QuestionDetails {
    var content: String
    
    init(param: String) {
        self.content = param
    }
}
