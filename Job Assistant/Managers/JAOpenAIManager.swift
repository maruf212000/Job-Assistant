//
//  JAOpenAIManager.swift
//  Job Assistant
//
//  Created by Maruf Memon on 18/01/24.
//

import Foundation
import OpenAI

let kOpenAI = JAOpenAIManager.shared

class JAOpenAIManager {
    private let client: OpenAI
    
    static let shared: JAOpenAIManager = {
        let instance = JAOpenAIManager()
        // setup code
        return instance
    }()
    
    private init() {
        self.client = OpenAI(apiToken: EnvironmentVariables.openAISecretKey)
    }
    
    func setup() {
        
    }
    
    func didEnterQuery(_ query: String) {
        let query = ChatQuery(model: .gpt3_5Turbo_1106, messages: [
            Chat(role: .system, content: "You are a helpful assistant."),
            Chat(role: .user, content: query)
        ])
        client
            .chatsStream(query: query) { partialResult in
                switch partialResult {
                case .success(let result):
                    print(result.choices)
                    break
                case .failure(let error):
                    print(error)
                    break
                    //Handle chunk error here
                }
            } completion: { error in
                print(error as Any)
            }
    }
}
