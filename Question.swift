//
//  Question.swift
//  HP Trivia-SwiftUI-iOS17
//
//  Created by Mayur Vaity on 23/07/24.
//

import Foundation

struct Question: Codable {
    let id: Int
    let question: String
    var answers: [String: Bool] = [:]
    let book: Int
    let hint: String
    
    enum QuestionKeys: String, CodingKey {
        case id
        case question
        case answer
        case wrong
        case book
        case hint
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: QuestionKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.question = try container.decode(String.self, forKey: .question)
        self.book = try container.decode(Int.self, forKey: .book)
        self.hint = try container.decode(String.self, forKey: .hint)
        
        //to handle question and convert into single dict of string and bool
        //for coerrect answer
        let correctAnswer = try container.decode(String.self, forKey: .answer)
        //adding to final dictionary of QnAs
        answers[correctAnswer] = true
        
        //for wrong answer
        let wrongAnswers = try container.decode([String].self, forKey: .wrong)
        //adding each of them to final dictionary of QnAs
        for answer in wrongAnswers {
            answers[answer] = false
        }
    }
}
