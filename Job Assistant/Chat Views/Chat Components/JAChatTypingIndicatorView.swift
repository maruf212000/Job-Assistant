//
//  JAChatTypingIndicatorView.swift
//  Job Assistant
//
//  Created by Maruf Memon on 16/01/24.
//

import SwiftUI

struct JAChatTypingIndicatorView: View {
    @State private var isTyping = false

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .frame(width: 5, height: 5)
                .opacity(isTyping ? 1 : 0.1)
                .animation(.easeOut(duration: 1).repeatForever(autoreverses: true), value: isTyping)
            Circle()
                .frame(width: 5, height: 5)
                .opacity(isTyping ? 1 : 0.1)
                .animation(.easeInOut(duration: 1).repeatForever(autoreverses: true), value: isTyping)
            Circle()
                .frame(width: 5, height: 5)
                .opacity(isTyping ? 1 : 0.1)
                .animation(.easeIn(duration: 1).repeatForever(autoreverses: true), value: isTyping)
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
        .onAppear{
            isTyping.toggle()
        }
    }
}

#Preview {
    JAChatTypingIndicatorView()
}
