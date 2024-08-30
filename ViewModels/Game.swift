//
//  Game.swift
//  HP Trivia-SwiftUI-iOS17
//
//  Created by Mayur Vaity on 23/07/24.
//

import Foundation
import SwiftUI 

//this is a view model

//@MainActor - we want this to run on main thread as it is tied so closely to the app
@MainActor
class Game: ObservableObject {
    //var to keep main game score
    @Published var gameScore = 0
    //var to keep current question score
    @Published var questionScore = 5
    //var array to keep recent 3 scores
    @Published var recentScores = [0, 0, 0]
    
    //to keep collection of all questions
    private var allQuestions: [Question] = []
    
    //an array to keep list of answered questions
    private var answeredQuestions: [Int] = []
    //path to save scores
    private let savePath = FileManager.documentsDirectory.appending(path: "SavedScores")
    
    //to keep colln of filtered qestions (by selected books)
    var filteredQuestions: [Question] = []
    
    //var to keep current question, initializing it with sample question
    var currentQuestion = Constants.previewQuestion
    
    //var to keep answers keys (as an array) (for displaying on vw) (from currentquestion) 
    var answers: [String] = []
    
    //calculated var to get correct answer from currentQuestion
    var correctAnswer: String {
        //finding answer where value is true and getting its key as correct answer
        currentQuestion.answers.first(where: { $0.value == true })!.key
    }
    
    init() {
        //to gather data from trivia file, as soon as a new obj is created
        decodeQuestions()
    }
    
    //fn to clear scores and list of answered questions
    func startGame() {
        gameScore = 0
        questionScore = 5
        answeredQuestions = []
    }
    
    //fn to filter questions based on list of books passed
    func filterQuestions(to books: [Int]) {
        filteredQuestions = allQuestions.filter { books.contains( $0.book) }
    }
    
    //fn to select next question
    func newQuestion() {
        //checking if the list has any questions
        if filteredQuestions.isEmpty { return}
        
        //checking if all the available questions were answered
        //if so then clearing the answeredQuestions array
        if answeredQuestions.count == filteredQuestions.count {
            answeredQuestions = []
        }
        
        //getting a random question
        var potentialQuestion = filteredQuestions.randomElement()!
        //running a while loop while checking if question was already answered
        //if answered, getting another random question
        //if not answered, selecting that question to show
        while answeredQuestions.contains(potentialQuestion.id) {
            potentialQuestion = filteredQuestions.randomElement()!
        }
        //making selected question currentQuestion
        currentQuestion = potentialQuestion
        
        //emptying answers array for new question's answers
        answers = []
        
        //getting answers list from currentQuestion obj and putting them in the array of answers
        for answer in currentQuestion.answers.keys {
            answers.append(answer)
        }
        
        //shuffling answers
        answers.shuffle()
        
        //resetting current question score
        questionScore = 5
    }
    
    //fn to exec when user gives correct answer to the question
    func correct() {
        //appending currentQuestion to the answeredQuestions list
        answeredQuestions.append(currentQuestion.id)
        
        //to perform animation while updating scores 
        withAnimation {
            //everytime they tap the correct answer, need to add it in total game score
            gameScore += questionScore
        }
    }
    
    //while ending the game, adding total score to recent scores list 
    func endGame() {
        recentScores[2] = recentScores[1]
        recentScores[1] = recentScores[0]
        recentScores[0] = gameScore
        
        //while ending, saving scores to defaults
        saveScores()
    }
    
    //fn to load recent scores data from userDefaults 
    func loadScores() {
        do {
            //getting recent scores data from abv path (into Data format)
            let data = try Data(contentsOf: savePath)
            //decoding recent scores data from Data format into an array of Int
            recentScores = try JSONDecoder().decode([Int].self, from: data)
        } catch {
            recentScores = [0, 0, 0]
        }
    }
    
    //fn to save recent scores
    private func saveScores() {
        do {
            //encoding recentScores array into Data format
            let data = try JSONEncoder().encode(recentScores)
            //write this data to defaults path created abv
            try data.write(to: savePath)
        } catch {
            print("Error saving score data, \(error)")
        }
    }
    
    //fn to decode questions data from trivia file and store in abv var
    private func decodeQuestions() {
        if let url = Bundle.main.url(forResource: "trivia", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                allQuestions = try decoder.decode([Question].self, from: data)
                filteredQuestions = allQuestions
            } catch {
                print("Error decoding JSON data, \(error)")
            }
        }
            
    }
}
