//
//  MainChatView.swift
//  GeminiAICloneApp
//
//  Created by Mohammad Shariq on 05/08/25.
//

import SwiftUI
import PhotosUI

struct MainChatView: View {
    @State private var textInput: String = ""
    @State private var chatService = ChatService()
    @State private var photoPickerItem = [PhotosPickerItem]()
    @State private var selectedMedia = [Media]()
    @State private var showAttachmentsOption = false
    @State private var showPhotoPicker = false
    @State private var showFilePicker = false
    @State private var showEmptyTextAlert = false
    @State private var loadingMedia = false
    
    
    var body: some View {
        VStack {
            //MARK: - AI LOGO
            Image("ai-image")
                .resizable()
                .scaledToFit()
                .frame(width: 70)
            
            // MARK: - TEXT
            
            Text("Welcome to AI Playground")
                .font(.headline)
                .padding(.top)
            
            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    ForEach(chatService.messages) { message in
                        //MARK: chat message view
                        chatMessageView(message)
                            .id(message.id)
                    }
                }
                
                .onChange(of: chatService.messages) { _, _ in
                    guard let recentMessage = chatService.messages.last else {
                        return
                    }
                    DispatchQueue.main.async {
                        withAnimation(.spring()) {
                            proxy.scrollTo(recentMessage.id, anchor: .bottom)
                        }
                    }
                }
                
                // Attachment preview:
                
                if selectedMedia.count > 2 {
                    ScrollView(.horizontal) {
                        LazyHStack(spacing: 10) {
                            ForEach(0..<selectedMedia.count, id: \.self) { index in
                                Image(uiImage: selectedMedia[index].thumbnail)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 50)
                                    .foregroundStyle(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                            }
                        }
                    }
                    .frame(height: 50)
                    .padding(.bottom, 8)
                }
                
                HStack {
                    Button {
                        showAttachmentsOption.toggle()
                    } label: {
                        if loadingMedia {
                            ProgressView()
                                .tint(.white)
                                .frame(width: 40)
                        } else {
                            Image(systemName: "paperclip")
                                .tint(.white)
                                .frame(width: 50, height: 25)
                        }
                    }
                    
                    .disabled(chatService.loadingRespone)
                    .confirmationDialog("What would you like to attach?",
                                        isPresented: $showAttachmentsOption,
                                        titleVisibility: .visible) {
                        Button("Images/Videos") {
                            showPhotoPicker.toggle()
                        }
                        Button("Documents") {
                            showFilePicker.toggle()
                        }
                    }.photosPicker(isPresented: $showPhotoPicker,
                                   selection: $photoPickerItem,
                                   maxSelectionCount: 2,
                                   matching: .any(of: [.images,.videos]))
                    
                    .onChange(of: photoPickerItem) { _,_ in
                        Task{
                            loadingMedia.toggle()
                            selectedMedia.removeAll()
                            for item in photoPickerItem {
                                do{
                                    let (mimeType, data, thumbnail) = try await MediaService().processPhotoPickerItem(for: item)
                                    selectedMedia.append(.init(mediaType: mimeType, data: data, thumbnail: thumbnail))
                                    
                                    
                                }catch{
                                    print(error.localizedDescription)
                                }
                            }
                            
                            loadingMedia.toggle()
                        }
                    }
                    .fileImporter(isPresented: $showFilePicker, allowedContentTypes: [.pdf,.text], allowsMultipleSelection: true) { result in
                        
                        selectedMedia.removeAll()
                        loadingMedia.toggle()
                        
                        switch result{
                        case .success(let urls):
                            for url in urls{
                                do {
                                    let (mediaType, data, thumbnail) = try MediaService().processDocumentItem(for: url)
                                    selectedMedia.append(.init(mediaType: mediaType, data: data, thumbnail: thumbnail))
                                    
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            
                        case .failure(let failure):
                            print(failure.localizedDescription)
                        }
                        loadingMedia.toggle()
                    }
                    
                    TextField("Enter a message...", text: $textInput)
                        .foregroundStyle(.black)
                        .alert("Please enter a message", isPresented: $showEmptyTextAlert, actions: {})
                        .padding()
                        .background(Color.white.cornerRadius(30))
                    
                    if chatService.loadingRespone {
                        ProgressView()
                            .tint(.white)
                            .frame(width: 30)
                    } else {
                        Button {
                            sendMessage()
                        } label: {
                            Image(systemName: "paperplane.fill")
                        }
                        .frame(width: 30)
                        
                    }
                }
            }
        }
        
        .foregroundStyle(.white)
        .padding()
        .background {
            ZStack {
                Color.black
                    .ignoresSafeArea()
            }
        }
        
    }
    
    
    //MARK: - Chat Media
    
    @ViewBuilder
    private func chatMessageView(_ message: ChatMessage) -> some View {
        if let media = message.media, media.isEmpty == false{
            GeometryReader { reader in
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        Spacer()
                            //.frame(width: spacerWidth(for: media, geometry: reader))
                        
                        ForEach(0..<media.count, id: \.self) { index in
                            let mediaItem = media[index]
                            
                            Image(uiImage: mediaItem.thumbnail)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 150)
                                .clipShape(RoundedRectangle(cornerRadius: 5))
                                .overlay(alignment: .topLeading) {
                                    Image(systemName: mediaItem.overlayIconName)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .shadow(color:.black,radius: 10)
                                        .padding(8)
                                }
                        }
                    }
                }
            }
            .frame(height: 150)
        }
        
        MessageCell(direction: message.role == .aiModel ? .left : .right) {
            Text(message.message)
                .font(.title2)
                .padding(.horizontal,20)
                .padding(.vertical,10)
                .foregroundStyle(.white)
                .background(message.role == .aiModel ? .blue : .gray)
        }
    }
    
    private func sendMessage() {
        guard !textInput.isEmpty else {
            showEmptyTextAlert = true
            return
        }
        
        Task {
            let chatMedia = selectedMedia
            selectedMedia.removeAll()
            await chatService.sendMessage(message: textInput, media: chatMedia)
            textInput = ""
        }
    }
    
    private func spacerWidth(for media: [Media],geometry: GeometryProxy) -> CGFloat{
        var totalWidth: CGFloat = 0
        for mediaItem in media {
            let scaledWidth = mediaItem.thumbnail.size.width * (150/mediaItem.thumbnail.size.height)
            
            totalWidth += scaledWidth + 20
        }
        return totalWidth < geometry.size.width ? geometry.size.width - totalWidth : 0
    }

}

#Preview {
    MainChatView()
}
