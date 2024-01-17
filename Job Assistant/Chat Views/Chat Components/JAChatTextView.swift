//
//  JAChatTextView.swift
//  Job Assistant
//
//  Created by Maruf Memon on 16/01/24.
//

import SwiftUI

struct JAChatTextView: View {
    let title: String
    var isUserReply: Bool = false
    
    init(cardItem: JAChatTextItem) {
        self.title = cardItem.title
        self.isUserReply = cardItem.isUserReply
    }
    
    init(title: String) {
        self.title = title
    }
    
    func bodyView() -> some View {
        let moreRoundedCorners: RectCorner = isUserReply ? [.bottomLeft, .bottomRight, .topLeft] : [.bottomLeft, .bottomRight, .topRight]
        let lessRoundedCorners: RectCorner = isUserReply ? [.topRight] : [.topLeft]
        return HStack {
            Text(title)
                .foregroundColor(isUserReply ? Color.white : Color.primary)
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
        }
        .background(isUserReply ? Color.blue :  Color(uiColor: UIColor.secondarySystemBackground))
        .cornerRadius(20, corners: moreRoundedCorners)
        .cornerRadius(4, corners: lessRoundedCorners)
    }
    
    var body: some View {
        if #available(macOS 12.0, iOS 15.0, *) {
            bodyView().textSelection(.enabled)
        } else {
            bodyView()
        }
    }
}
