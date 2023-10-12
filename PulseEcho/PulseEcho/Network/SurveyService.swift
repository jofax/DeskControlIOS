//
//  SurveyService.swift
//  PulseEcho
//
//  Created by Joseph on 2020-04-24.
//  Copyright © 2020 Smartpods. All rights reserved.
//

import Foundation
import Moya
import Alamofire

/**
 Survey service abstract network layer for interfacing the web service.
*/

public enum SurveyService {
    case getSurvey([String: Any])
    case sendAnswers([String: Any])
}

extension SurveyService: TargetType {
    public var baseURL: URL {
      //return URL(string: Environment.instance.endpoint())!
        return API_ENDPOINT.baseURL
    }
    
    public var path: String {
        switch self {
        case .getSurvey:
            return API.survey + API.nextSurveyRun
        case .sendAnswers:
            return API.survey + API.surveyAnswers
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .getSurvey, .sendAnswers:
            return .post
        }
    }
    
    public var sampleData: Data {
        return Data()
    }
    
    public var task: Task {
        switch self {
        case .getSurvey(let params), .sendAnswers(let params):
            return .requestParameters(parameters: params, encoding: JSONEncoding.default)
        }
    }
    
    public var headers: [String : String]? {
        return requestHeaders()
    }
    
}

func readJSONFromFile(fileName: String) -> Any?
{
    var json: Any?
    if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
        do {
            let fileUrl = URL(fileURLWithPath: path)
            // Getting data from JSON file using the file URL
            let data = try Data(contentsOf: fileUrl, options: .mappedIfSafe)
            json = try? JSONSerialization.jsonObject(with: data)
        } catch {
            // Handle error here
        }
    }
    return json
}
