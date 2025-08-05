//
//  ChatService.swift
//  GeminiAICloneApp
//
//  Created by Mohammad Shariq on 05/08/25.
//

import Foundation
import SwiftUI
import GoogleGenerativeAI


@Observable
class ChatService {
    
    private(set) var messages = [ChatMessage]()
    private(set) var loadingRespone = false
    private var model = GenerativeModel(name: "gemini-2.5-flash", apiKey: APIKEY.default)
    
    
    func sendMessage(message: String, media: [Media]) async {
        loadingRespone = true
        
        messages.append(.init(role: .user, message: message, media: media))
        messages.append(.init(role: .aiModel, message: "", media: nil))
        
        do {
            var chatMedia = [any ThrowingPartsRepresentable]()
            for mediaItem in media {
                if mediaItem.mediaType == "video/mp4" || mediaItem.mediaType == "text/plain" || mediaItem.mediaType == "application/pdf" {
                    chatMedia.append(ModelContent.Part.data(mimetype: mediaItem.mediaType, mediaItem.data))
                } else {
                    chatMedia.append(ModelContent.Part.jpeg(mediaItem.data))
                }
            }
            let response = try await model.generateContent(message, chatMedia)
            loadingRespone = false
            
            guard let text = response.text else {
                messages.append(.init(role: .aiModel, message: "Something went wrong!", media: nil))
                return
            }
            messages.removeLast()
            messages.append(.init(role: .aiModel, message: text, media: nil))
            
        } catch {
            loadingRespone = false
            messages.removeLast()
            messages.append(.init(role: .aiModel, message: "Something went wrong!", media: nil))
            print(error.localizedDescription)
        }
    }
}
