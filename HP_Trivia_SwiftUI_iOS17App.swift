//
//  HP_Trivia_SwiftUI_iOS17App.swift
//  HP Trivia-SwiftUI-iOS17
//
//  Created by Mayur Vaity on 16/07/24.
//

import SwiftUI

@main
struct HP_Trivia_SwiftUI_iOS17App: App {
    //creating store varaible here to share with all views (as an env obj)
    @StateObject private var store = Store()
    //creating a game viewmodel obj
    @StateObject private var game = Game()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store) //passing store as an env obj 
                .environmentObject(game) //passing game as an env obj 
                .task {
                    //to load all the products as soon as app loads
                    await store.loadProducts() 
                    //to load recent scores as soon as app loads
                    game.loadScores() 
                    //to load book status data as soon as app loads (from user defaults)
                    store.loadStatus()
                }
        }
    }
}
