//
//  APIKEY.swift
//  GeminiAICloneApp
//
//  Created by Mohammad Shariq on 05/08/25.
//

import Foundation


enum APIKEY {
    
    
    static var  `default` : String {
        guard let filePath = Bundle.main.path(forResource: "GenerativeAI-Info", ofType: "plist") else {
            fatalError("Could Not Find GenerativeAI-Info.plist")
        }
        
        let plist = NSDictionary(contentsOfFile: filePath)
        guard let value = plist?.object(forKey: "API_KEY") as? String else {
            fatalError("Couldn't find API_KEY in GenerativeAi-Info.plist")
        }
        
        if value.starts(with: "_") {
            fatalError("Follow instructions to get api key.")
        }
        return value
    }
}
