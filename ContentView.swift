//
//  ContentView.swift
//  HP Trivia-SwiftUI-iOS17
//
//  Created by Ayoub Benderdouch on 25/08/24.
//

import SwiftUI
import AVKit

struct ContentView: View {
    //env obj containing store class obj
    @EnvironmentObject private var store: Store
    //env obj containing game vm obj
    @EnvironmentObject private var game: Game
    
    //creating audio player obj
    @State private var audioPlayer: AVAudioPlayer!
    
    //for animating play button
    @State private var scalePlayButton = true
    //for animating bg image
    @State private var moveBackgroundImage = false
    //var for animating transitions
    @State private var animateViewsIn = false
    //var to manage showing of instructions screen
    @State private var showInstructions = false
    //var to manage showing of settings screen
    @State private var showSettings = false
    //var to manage showing of Gameplay screen
    @State private var playGame = false
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                //bg image
                Image("hogwarts")
                    .resizable()
                    .frame(width: geo.size.width * 3, height: geo.size.height)
                    .padding(.top, 3) //to push the image down a little
                    .offset(x: moveBackgroundImage ? geo.size.width/1.1 : -geo.size.width/1.1) //for bg animation movement
                    .onAppear {
                        withAnimation(.linear(duration: 60).repeatForever()) {
                            //linear - left right movement animation
                            //duration 60 - for 60 seconds it will move one side then to other side for 60 seconds
                            moveBackgroundImage.toggle()
                        }
                    }
                
                VStack {
                    //to apply animation modifers, need to add all that content in a vstack
                    VStack {
                        //putting all the vws involved in the animation within a if statement driven by "animateViewsIn" var
                        if animateViewsIn {
                            VStack {
                                //bolt image
                                Image(systemName: "bolt.fill")
                                    .font(.largeTitle)
                                    .imageScale(.large)
                                
                                Text("HP")
                                    .font(.custom(Constants.hpFont, size: 70))
                                    .padding(.bottom, -50) //to bring HP and Trivia words closer
                                
                                Text("Trivia")
                                    .font(.custom(Constants.hpFont, size: 60))
                            }
                            .padding(.top, 70)
                            .transition(.move(edge: .top)) //to transition in from top
                        }
                    }
                    .animation(.easeOut(duration: 0.7).delay(2), value: animateViewsIn) //to specify animation interval and manage "animateViewsIn" var
                    //it is suppose to fly in right after view loads (delay of 2 sec, and duration of animation is 0.7) and stay there
                    
                    Spacer()
                    
                    
                    //to apply animation modifers, need to add all that content in a vstack
                    VStack {
                        //putting all the vws involved in the animation within a if statement driven by "animateViewsIn" var
                        if animateViewsIn {
                            VStack {
                                Text("Recent Scores")
                                    .font(.title2)
                                
                                Text("\(game.recentScores[0])")
                                Text("\(game.recentScores[1])")
                                Text("\(game.recentScores[2])")
                            }
                            .font(.title3)
                            .padding(.horizontal)
                            .foregroundStyle(.white)
                            .background(.black.opacity(0.7))
                            .clipShape(.rect(cornerRadius: 15))
                            .transition(.opacity) //to just appear use "opacity"
                        }
                    }
                    .animation(.linear(duration: 1).delay(4), value: animateViewsIn) //to specify animation interval and manage "animateViewsIn" var
                    //it is suppose to appear there right after view loads (delay of 4 sec, and duration of animation is 1) and stay there
                    
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        //to apply animation modifers, need to add all that content in a vstack
                        VStack {
                            //putting all the vws involved in the animation within a if statement driven by "animateViewsIn" var
                            if animateViewsIn {
                                Button {
                                    //show instructions screen
                                    //to show the instructions screen this var value need to b set to true (for this var is used in Sheet)
                                    showInstructions.toggle()
                                } label: {
                                    Image(systemName: "info.circle.fill")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                        .shadow(radius: 5)
                                }
                                .transition(.offset(x: -geo.size.width/4)) //to fly in from left
                                .sheet(isPresented: $showInstructions, content: {
                                    InstructionsView()
                                }) //sheet - to open this view as a Modal view
                                
                            }
                        }
                        .animation(.easeOut(duration: 0.7).delay(2.7), value: animateViewsIn) //to specify animation interval and manage "animateViewsIn" var
                        //it is suppose to fly in right after view loads (delay of 2.7 sec, and duration of animation is 0.7) and stay there
                        
                        
                        Spacer()
                        
                        
                        //to apply animation modifers, need to add all that content in a vstack
                        VStack {
                            //putting all the vws involved in the animation within a if statement driven by "animateViewsIn" var
                            if animateViewsIn {
                                Button {
                                    //filtering questions using active books and preparing new question 
                                    filterQuestions()
                                    //calling fn to prepare for a new game
                                    game.startGame()
                                    //start a new game
                                    playGame.toggle()
                                } label: {
                                    Text("Play")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                        .padding(.vertical, 7)
                                        .padding(.horizontal, 50)
                                        //changing button color based on active books
                                        .background(store.books.contains(.active) ? .brown : .gray)
                                        .clipShape(.rect(cornerRadius: 7))
                                        .shadow(radius: 5)
                                }
                                .scaleEffect(scalePlayButton ? 1.2 : 1) //to add animation effect to this button using var "scalePlayButton"
                                .onAppear {
                                    //to start animation of the button once it appears on the screen
                                    withAnimation(.easeInOut(duration: 1.3).repeatForever()) {
                                        //easeInOut - after 1.3 duration to play this animation
                                        //repeatForever - to repeat abv animation step forever
                                        //keep toggling "scalePlayButton" value to keep button animated
                                        scalePlayButton.toggle()
                                    }
                                }
//                                .transition(.move(edge: .bottom)) //.bottom move doesn't work so need to use offset as below
                                .transition(.offset(y: geo.size.height/3)) //to specify what kind of transition it requires
                                .fullScreenCover(isPresented: $playGame, content: {
                                    GameplayView()
                                        .environmentObject(game)
                                        .onAppear {
                                            //on appearance of gameplay vw, bg music from content view should fade away in 2 seconds
                                            audioPlayer.setVolume(0, fadeDuration: 2)
                                        }
                                        .onDisappear {
                                            //on coming back from gameplay vw, bg music should get enabled again (come in from fade to full in duration of 3 sec) 
                                            audioPlayer.setVolume(1, fadeDuration: 3)
                                        }
                                }) //fullScreenCover - to open vw in full screen
                                //to disable the button if no book is active
                                .disabled(store.books.contains(.active) ? false : true)
                            }
                        }
                        .animation(.easeOut(duration: 0.7).delay(2), value: animateViewsIn) //to specify animation interval and manage "animateViewsIn" var
                        //it is suppose to fly in right after view loads (delay of 2 sec, and duration of animation is 0.7) and stay there
                        
                        
                        Spacer()
                        
                        //to apply animation modifers, need to add all that content in a vstack
                        VStack {
                            //putting all the vws involved in the animation within a if statement driven by "animateViewsIn" var
                            if animateViewsIn {
                                Button {
                                    //show settings screen
                                    //to toggle "showSettings" var to show settings screen
                                    showSettings.toggle()
                                } label: {
                                    Image(systemName: "gearshape.fill")
                                        .font(.largeTitle)
                                        .foregroundStyle(.white)
                                        .shadow(radius: 5)
                                }
                                .transition(.offset(x: geo.size.width/4)) //to fly in from right
                                .sheet(isPresented: $showSettings, content: {
                                    //showing SettingsView as Modal based on value of "showSettings" var
                                    SettingsView()
                                        .environmentObject(store) //passing store obj which we got from env (from App file) 
                                })
                            }
                        }
                        .animation(.easeOut(duration: 0.7).delay(2.7), value: animateViewsIn) //to specify animation interval and manage "animateViewsIn" var
                        //it is suppose to fly in right after view loads (delay of 2.7 sec, and duration of animation is 0.7) and stay there
                        
                        Spacer()
                    }
                    .frame(width: geo.size.width)
                    
                    //if no book is selected, this message will show up on the screen
                    VStack {
                        //chekcing if animateViewsIn is true (i.e. to perform animations)
                        if animateViewsIn {
                            //checking if any book is active
                            if store.books.contains(.active) == false {
                                //message
                                Text("No questions available. Go to settings. ⬆️")
                                    .multilineTextAlignment(.center)
                                    .transition(.opacity)
                            }
                        }
                    }
                    .animation(.easeInOut.delay(3), value: animateViewsIn) //animations config w delay and var on which animation is based upon
                    
                    Spacer()
                }
            }
            .frame(width: geo.size.width,
                   height: geo.size.height)
        }
        .ignoresSafeArea()
        .onAppear {
            //to start playing audio from audioplayer, once this view appears on the screen
            playAudio()
            
            //to enable title vws animation fying in on screen when app loads
            animateViewsIn = true
        }
    }
    
    //fn to get music file and setting it and playing it on audio player
    private func playAudio() {
        //creating a pth for audio file, which needs to be played
        let sound = Bundle.main.path(forResource: "magic-in-the-air", ofType: "mp3")
        //assigning abv obj to audio player
        audioPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        //to run this song in infinite loops use -1
        audioPlayer.numberOfLoops = -1
        //to play the audio player
        audioPlayer.play()
    }
    
    //fn to filter questions on the basis of active books
    private func filterQuestions() {
        //list of ids of enabled books
        var books: [Int] = []
        
        //enumerated - returns index of the element and value of the element in the array
        for (index, status) in store.books.enumerated() {
            if status == .active {
                books.append(index + 1)
            }
        }
        //to call fn to filter questions by books
        game.filterQuestions(to: books)
        //to get a new question (using new filteredQuestions list)
        game.newQuestion()
    }
    
}

#Preview {
    ContentView()
        .environmentObject(Store()) //creating a store obj and passing for preview 
        .environmentObject(Game()) //creating a game obj and passing for preview
}
