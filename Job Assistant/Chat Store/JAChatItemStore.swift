//
//  JAChatItemStore.swift
//  Job Assistant
//
//  Created by Maruf Memon on 16/01/24.
//

import Foundation
import OpenAI

enum JAChatItemType: Int {
    case chatItemTextType
}

class JAChatItem: NSObject {
    let id: String
    let type: JAChatItemType
    var isUserReply: Bool
    init(id: String = UUID().uuidString, type: JAChatItemType, isUserReply: Bool = false) {
        self.type = type
        self.id = id
        self.isUserReply = isUserReply
    }
}

class JAChatTextItem: JAChatItem {
    let title: String
    init(title: String, isUserReply: Bool = false, useUUID: Bool = true, animationModseq: Int = 0) {
        self.title = title
        super.init(id: useUUID ? UUID().uuidString : "text_item_" + title + "_" + String(isUserReply) + String(animationModseq), type: .chatItemTextType, isUserReply: isUserReply)
    }
}

class JAChatItemsStore: ObservableObject {
    @Published var items: Array<JAChatItem> = []
    @Published var updateScroll: Int = 0
    var shouldScrollToBottom: Bool = false
    
    func initializeChat() {
        append(JAChatTextItem(title: "Hi [Name], How can I help you today?"))
    }
    
    func append(_ item: JAChatItem) {
        items.append(item)
    }
}
