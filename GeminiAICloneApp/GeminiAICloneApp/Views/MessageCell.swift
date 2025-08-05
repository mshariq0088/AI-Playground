//
//  MessageCell.swift
//  GeminiAICloneApp
//
//  Created by Mohammad Shariq on 05/08/25.
//

import SwiftUI

struct MessageCell<Content>: View where Content: View {
    
    let direction: MessageCellShape.Direction
    let content: () -> Content
    init(direction: MessageCellShape.Direction, @ViewBuilder content: @escaping () -> Content) {
            self.content = content
            self.direction = direction
    }

    
    var body: some View {
        HStack {
            if direction == .left {
                Spacer()
            }
            content()
                .clipShape(MessageCellShape(direction: direction))
            if direction == .left {
                Spacer()
            }
        }
        .padding([(direction == .left) ? .leading : .trailing, .top, .bottom], 20)
        .padding((direction == .right) ? .leading : .trailing, 50)
    }
}


#Preview {
    MessageCell(direction: .left) {
        
    }
}
