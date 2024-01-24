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
    case chatItemJobType
    case chatItemTypingIndicatorType
    case chatItemAnswerType
    case chatItemSuggestionType
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

class JAChatSuggestionItem: JAChatItem {
    let title: String
    init(title: String, isUserReply: Bool = true, useUUID: Bool = true, animationModseq: Int = 0) {
        self.title = title
        super.init(id: useUUID ? UUID().uuidString : "text_item_" + title + "_" + String(isUserReply) + String(animationModseq), type: .chatItemSuggestionType, isUserReply: isUserReply)
    }
}

class JAChatJobItem: JAChatItem {
    let job: JAJobEntity
    init(job: JAJobEntity, isUserReply: Bool = false) {
        self.job = job
        super.init(type: .chatItemJobType, isUserReply: isUserReply)
    }
}

class JAAnswerTextItem: JAChatItem, ObservableObject {
    @Published var answer: String
    @Published var context: String
    var update: ((_ answer: String) -> ())?
    var isComplete: Bool = false
    
    var rayId: String = String()
    @Published var feedback: Int = 0
    
    init() {
        self.answer = String()
        self.context = String()
        super.init(type: .chatItemAnswerType)
    }
    
    func identify(rayId: String) {
        self.rayId = rayId
    }
    
    func clean() {
        while (self.answer.hasPrefix(" ") || self.answer.hasPrefix("\n") || self.answer.hasPrefix("\r")) {
            self.answer.remove(at: self.answer.startIndex)
        }
    }
    
    func addContext(delta: String) {
        DispatchQueue.main.async {
            self.context = delta;
        }
    }
    
    func fill(delta: String) {
        DispatchQueue.main.async {
            self.answer.append(delta)
            self.clean()
            if (self.update != nil) {
                self.update!(self.answer)
            }
        }
    }
    
    func complete(answer: String) {
        DispatchQueue.main.async {
            self.isComplete = true
            self.answer = answer
            self.clean()
            if (self.update != nil) {
                self.update!(self.answer)
            }
        }
    }
}

class JAChatItemsStore: ObservableObject {
    @Published var items: Array<JAChatItem> = []
    @Published var updateScroll: Int = 0
    
    var tempItems: Array<JAChatItem> = []
    var isOptionsAnimating: Bool = false
    var shouldScrollToBottom: Bool = false
    var questions: [String] = []
    var todos: [String] = []
    
    func initializeChat() {
        self.items.append(JAChatItem(type: .chatItemTypingIndicatorType))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            var newItems: [JAChatItem] = []
            let full_name: String = kData.userData["name"] as? String ?? ""
            newItems.append(JAChatTextItem(title: "Hi \(full_name), How can I help you today?"))
            for job in kData.fetchAllJobs() {
                newItems.append(JAChatJobItem(job: job))
            }
            self.addItemsWithAnimation(newItems: newItems)
        }
    }
    
    func addItemsWithAnimation(newItems: Array<JAChatItem>) {
        if (newItems.count == 0) {
            return;
        }
        if (isOptionsAnimating) {
            self.tempItems.append(contentsOf: newItems)
            return;
        }
        isOptionsAnimating = true
        let nowTime = DispatchTime.now()
        for idx in 0...newItems.count {
            let dispatchAfter = DispatchTimeInterval.milliseconds(Int((Double(idx) / 2.0) * 1000.0))
            DispatchQueue.main.asyncAfter(deadline: nowTime + dispatchAfter) {
                if (self.items.last?.type == .chatItemTypingIndicatorType) {
                    self.items.removeLast()
                }
                if (idx == newItems.count) {
                    self.isOptionsAnimating = false
                    self.addItemsWithAnimation(newItems: self.tempItems)
                    self.tempItems = []
                } else {
                    self.items.append(newItems[idx])
                }
            }
        }
    }
    
    
    func append(_ item: JAChatItem) {
        items.append(item)
    }
    
    func addReply(for jobEntity: JAJobEntity) {
        if let job_role = jobEntity.job_role, let company_name = jobEntity.company_name {
            let text = "I want to apply for \(job_role) at \(company_name)."
            self.append(JAChatTextItem(title: text, isUserReply: true))
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                let item: JAAnswerTextItem = JAAnswerTextItem()
                self.shouldScrollToBottom = true
                kOpenAI.stream(for: jobEntity) { rayId in
                    item.identify(rayId: rayId)
                } contextHandler: { context in
                    item.addContext(delta: context)
                } progressHandler: { progress in
                    item.fill(delta: progress)
                } extractedDataHandler: { questions, todos in
                    self.questions = questions
                    self.todos = todos
                    self.suggestActions()
                } completionHandler: { answer in
                    item.complete(answer: answer)
                }
                self.append(item)
            }
        }
    }
    
    func suggestActions() {
        DispatchQueue.main.async {
            var newItems: [JAChatItem] = []
            var count = 0
            for question in self.questions {
                if (count > 2) {
                    break
                }
                if (question.count > 0) {
                    newItems.append(JAChatSuggestionItem(title: question))
                    count += 1
                }
            }
            for todo in self.todos {
                if (count > 2) {
                    break
                }
                if (todo.count > 0) {
                    newItems.append(JAChatSuggestionItem(title: todo))
                    count += 1
                }
            }
            self.shouldScrollToBottom = false
            self.items.append(contentsOf: newItems)
            self.shouldScrollToBottom = true
        }
    }
    
    func removeSuggested(term: String) {
        self.questions.removeAll { $0 == term }
        self.todos.removeAll { $0 == term }
    }
    
    func chatHistory() -> [Chat] {
        var history: [Chat] = []
        for item in self.items.suffix(from: 5) {
            if let answerItem = item as? JAAnswerTextItem {
                history.append(Chat(role: .assistant, content: answerItem.answer))
            } else if let textItem = item as? JAChatTextItem {
                history.append(Chat(role: item.isUserReply ? .user : .assistant, content: textItem.title))
            }
        }
        return history
    }
    
    func userQuery(_ term: String, isFromSuggestionItem: Bool = false) {
        while (self.items.last?.type == .chatItemSuggestionType) {
            self.items.removeLast()
        }
        self.append(JAChatTextItem(title: term, isUserReply: true))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let item: JAAnswerTextItem = JAAnswerTextItem()
            self.shouldScrollToBottom = true
            if (isFromSuggestionItem) {
                self.removeSuggested(term: term)
            }
            let query = isFromSuggestionItem ? "Answer this on behalf of user based on my resume provided above: " + term : term
            kOpenAI.stream(for: query, history: self.chatHistory()) { rayId in
                item.identify(rayId: rayId)
            } contextHandler: { context in
                item.addContext(delta: context)
            } progressHandler: { progress in
                item.fill(delta: progress)
            } completionHandler: { answer in
                item.complete(answer: answer)
                self.suggestActions()
            }
            self.append(item)
        }
    }
    
    func didPressClearBtn() {
        self.items = []
        self.initializeChat()
    }
}
