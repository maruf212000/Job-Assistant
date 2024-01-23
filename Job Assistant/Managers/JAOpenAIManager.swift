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
    let systemContent: String = """
    You are a Job Assitant who will help user in applying for jobs. Your job is to find job role, job location, pay range, skills required for the job (write it in short and bullet points).Specify not given if any of the above is not present. After this please show all the things which user have to do for applying to this job. Also list down questions which are listed in the job description and employer has asked to submit answer of those while applying. It should be listed in following format:
    => BASIC DETAILS
    Job Role: XXX
    Job Location: YYY
    Pay Range: ZZZ

    => SKILLS:
    1. Skill 1
    2. Skill 2

    => TODO
    1. First task.
    2. Second task

    => QUESTIONS
    1. Question 1
    2. Question 2
    3. Question 3

    bullet point should always be in number format like in above format


    Example:
    => BASIC DETAILS
    Job Role: Software Engineer
    Job Location: Global/Remote
    Pay Range: Not given

    => SKILLS
    1. Good communication
    2. Good knowledge of data structures and algorithm

    => TODO
    1. Write a cover letter
    2. Attach your degree proof with your application.

    => QUESTIONS
    1. Write a bried about your biggest achievement.
    2. How many years of relative experience do you have?

    Other than this no other information is needed. So please don't show anythin extra.
"""
    
    let questionContent: String = """
        From this above questions tell me how many you as an AI Chat Assistant can answer and how many todos you can perform based on given information(resume provided by system and above chats). Add it to json object if you can answer the question or help user complete the todo. Please make sure you say yes to only questions and todos which you can do, for example you can't fill form on a website as a chat assistant, so you have to say no to things which you can't do.

        Example:
        Output
        {
            "todos": [
                "Todo 1",
                "Todo 2"
            ],
            "questions": [
                "Question 1",
                "Question 2"
            ]
        }
"""
    
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
    
    func userData() -> String {
        return """
        After this you will help user in answering the questions and completing the todo list. I am providing users full resume here, you can write answers based on that.
        User's Resume:
        """ + kData.userProfileJson()
    }
    
    func extractTodosAndQuestions(from json: String) -> (todos: [String], questions: [String])? {
        guard let jsonData = json.data(using: .utf8) else {
            return nil
        }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            guard let jsonDict = jsonObject as? [String: Any],
                  let todos = jsonDict["todos"] as? [String],
                  let questions = jsonDict["questions"] as? [String] else {
                return nil
            }
            
            return (todos, questions)
        } catch {
            print("Error parsing JSON: \(error)")
            return nil
        }
    }
    
    func stream(for jobEntity: JAJobEntity,
                rayIdHandler: @escaping (String) -> Void,
                contextHandler: @escaping (String) -> Void,
                progressHandler: @escaping (String) -> Void,
                extractedDataHandler: @escaping([String], [String]) -> Void,
                completionHandler: @escaping (String) -> Void) {
        let userContent = """
Following is the job description. Please help me to get this job
Job Description:
""" + kData.getJSONString(from: jobEntity)
        var messages = [
            Chat(role: .system, content: systemContent + userData()),
            Chat(role: .user, content: userContent)
        ]
        let chatQuery = ChatQuery(model: .gpt3_5Turbo, messages: messages)
        var rayId:String? = nil
        var answer = ""
        client
            .chatsStream(query: chatQuery) { partialResult in
                switch partialResult {
                case .success(let result):
                    if (rayId == nil) {
                        rayIdHandler(result.id)
                        rayId = result.id
                    }
                    for choice in result.choices {
                        if let progress = choice.delta.content {
                            progressHandler(progress)
                            answer.append(progress)
                        }
                    }
                    print(result)
                    break
                case .failure(let error):
                    completionHandler(answer)
                    print(error)
                    break
                }
            } completion: { error in
                print(error as Any)
                completionHandler(answer)
                messages.append(Chat(role: .assistant, content: answer))
                messages.append(Chat(role: .system, content: self.questionContent))
                let questionQuery = ChatQuery(model: .gpt3_5Turbo, messages: messages)
                self.client
                    .chats(query: questionQuery) { result in
                        switch result {
                        case .success(let chatResult):
                            print("Result: \(result)")
                            if let choice:ChatResult.Choice = chatResult.choices.first, let answer = choice.message.content {
                                let extractedData = self.extractTodosAndQuestions(from: answer)
                                print(extractedData ?? "No Data")
                                extractedDataHandler(extractedData?.questions ?? [], extractedData?.todos ?? [])
                            }
                            break
                            
                        case .failure(let error):
                            print("Error: \(error)")
                        }
                    }
            }
    }
    
    func stream(for term: String,
        history: [Chat],
        rayIdHandler: @escaping (String) -> Void,
        contextHandler: @escaping (String) -> Void,
        progressHandler: @escaping (String) -> Void,
        completionHandler: @escaping (String) -> Void) {
        var messages = [
            Chat(role: .system, content: systemContent + userData())
        ]
        messages.append(contentsOf: history)
        messages.append(Chat(role: .user, content: term))
        let chatQuery = ChatQuery(model: .gpt3_5Turbo, messages: messages)
        var rayId:String? = nil
        var answer = ""
        client
            .chatsStream(query: chatQuery) { partialResult in
                switch partialResult {
                case .success(let result):
                    if (rayId == nil) {
                        rayIdHandler(result.id)
                        rayId = result.id
                    }
                    for choice in result.choices {
                        if let progress = choice.delta.content {
                            progressHandler(progress)
                            answer.append(progress)
                        }
                    }
                    print(result)
                    break
                case .failure(let error):
                    completionHandler(answer)
                    print(error)
                    break
                }
            } completion: { error in
                completionHandler(answer)
                print(error as Any)
            }
    }
}
