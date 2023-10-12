//
//  ScaleOptions.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-23.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation

struct SurveyScaleOptions {
    var ID: Int
    var LanguageEnum: Int
    var Text: String
    var Rank: Int
    var RiskScore: Int
    
    init(params: [String: Any]) {
        self.ID = params["ID"] as? Int ?? 0
        self.LanguageEnum = params["LanguageEnum"] as? Int ?? 0
        self.Text = params["Text"] as? String ?? ""
        self.Rank = params["Rank"] as? Int ?? 0
        self.RiskScore = params["RiskScore"] as? Int ?? 0
    }
}
