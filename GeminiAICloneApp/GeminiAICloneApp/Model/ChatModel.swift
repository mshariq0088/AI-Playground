//
//  ChatModel.swift
//  GeminiAICloneApp
//
//  Created by Mohammad Shariq on 05/08/25.
//

import Foundation
import UIKit


enum ChatRole {
    case user
    case aiModel
}

struct Media {
    
    let mediaType: String
    let data: Data
    let thumbnail: UIImage
    
    var overlayIconName: String {
        if mediaType.starts(with: "video") {
            return "video.circle.fill"
        } else if mediaType.starts(with: "image") {
            return "photo.circle.fill"
        } else if mediaType.contains("pdf") || mediaType.contains("text") {
            return "doc.circle.fill"
        }
        
        return ""
    }
}


struct ChatMessage: Identifiable, Equatable {
    let id = UUID().uuidString
    let role: ChatRole
    let message: String
    let media: [Media]?
    
    static func == (lhs: ChatMessage, rhs: ChatMessage) -> Bool {
        return lhs.id == rhs.id
    }
}
