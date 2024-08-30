//
//  GameplayView.swift
//  HP Trivia-SwiftUI-iOS17
//
//  Created by Ayoub Benderdouch on 19/08/24.
//

import SwiftUI
import AVKit

struct GameplayView: View {
    //env var to dismiss the vw
    @Environment(\.dismiss) private var dismiss
    //env obj containing game vm obj
    @EnvironmentObject private var game: Game
    
    //to allow us to connect correct answers with celebration screen
    @Namespace private var namespace
    
    //audio player (for bg sound) and sfx player (for sound effects player)
    @State private var musicPlayer: AVAudioPlayer!
    @State private var sfxPlayer: AVAudioPlayer!
    
    //var to handle animations
    @State private var animateViewsIn = false
    //var used to trigger celebration screen
    @State private var tappedCorrectAnswer = false
    //an array to maintain a list of tapped wrong answers
    @State private var wrongAnswersTapped: [Int] = []
    
    //var used in giving that wiggling effect to question mark
    @State private var hintWiggle = false
    //for animationg next level button
    @State private var scaleNextButton = false
    
    @State private var movePointsToScore = false
    //vars for hints
    @State private var revealHint = false
    @State private var revealBook = false
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                //bg image
                Image("hogwarts")
                    .resizable()
                    .frame(width: geo.size.width * 3, height: geo.size.height * 1.05)
                    .overlay(Rectangle().foregroundStyle(.black.opacity(0.8)))
                
                VStack {
                    //MARK: - Controls
                    HStack {
                        Button("End Game") {
                            //calling fn to perform end game actions
                            game.endGame()
                            //to dismiss gameplay view
                            dismiss()
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(.red.opacity(0.5))
                        
                        Spacer()
                        
                        //total score of current game
                        Text("Score: \(game.gameScore)")
                    }
                    .padding()
                    .padding(.vertical, 30)
                    
                    //MARK: - Question
                    VStack {
                        if animateViewsIn {
                            //current question
                            Text(game.currentQuestion.question)
                                .font(.custom(Constants.hpFont, size: 50))
                                .multilineTextAlignment(.center)
                                .padding()
                                .transition(.scale)  //transition type for animation
                            //when selected correct answer, the question text to be faded
                                .opacity(tappedCorrectAnswer ? 0.1 : 1)
                        }
                    }
                    //animation modf suggests how a vw will appear and disappear, so need to specify differently for both cases like below (based on certain var)
                    //below ternary conditions says we want animation to appear taking 2 sec and disappear in 0 sec (i.e. instantly)
                    .animation(.easeInOut(duration: animateViewsIn ? 2 : 0), value: animateViewsIn) //animation specified with var it depends on
                    
                    Spacer()
                    
                    //MARK: - Hints 
                    HStack {
                        //for some hint
                        VStack {
                            if animateViewsIn {
                                Image(systemName: "questionmark.app.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100)
                                    .foregroundStyle(.cyan)
                                    .rotationEffect(.degrees(hintWiggle ? -13 : -17)) //to rotate image by angle in degrees
                                    .padding()
                                    .padding(.leading, 20)
                                    .transition(.offset(x: -geo.size.width/2))
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 0.1).repeatCount(9).delay(5).repeatForever()) {
                                            hintWiggle = true
                                        }
                                    } //for wiggle effect animation
                                    //to create animation of 3d rotation when clicked on it
                                    .onTapGesture {
                                        withAnimation(.easeOut(duration: 1)) {
                                            revealHint = true
                                        }
                                        
                                        //to play filp sound
                                        playFlipSound()
                                        //deducting 1 from question score
                                        game.questionScore -= 1
                                    }
                                    .rotation3DEffect(
                                        .degrees(revealHint ? 1440 : 0), axis: (x: 0, y: 1, z: 0)
                                    )
                                    .scaleEffect(revealHint ? 5 : 1)
                                    .opacity(revealHint ? 0 : 1)
                                    .offset(x: revealHint ? geo.size.width/2 : 0) //direction of flippng
                                // to show hint once clicked on abv btn, at the place of the button
                                    .overlay(
                                        Text(game.currentQuestion.hint)
                                            .padding(.leading, 33)
                                            .minimumScaleFactor(0.5)
                                            .multilineTextAlignment(.center)
                                            .opacity(revealHint ? 1 : 0)
                                            .scaleEffect(revealHint ? 1.33 : 1) //scaling animation when revealing
                                    )
                                //when selected correct answer, this button to be faded and disabled
                                    .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    .disabled(tappedCorrectAnswer)
                            }
                        }
                        .animation(.easeOut(duration: animateViewsIn ? 1.5 : 0).delay(animateViewsIn ? 2 : 0), value: animateViewsIn)
                        
                        Spacer()
                        
                        //for book as hint (from which question is taken)
                        VStack {
                            if animateViewsIn {
                                Image(systemName: "book.closed")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50)
                                    .foregroundStyle(.black)
                                    .frame(width: 100, height: 100)
                                    .background(.cyan)
                                    .clipShape(.rect(cornerRadius: 20))
                                    .rotationEffect(.degrees(hintWiggle ? 13 : 17))
                                    .padding()
                                    .padding(.trailing, 20)
                                    .transition(.offset(x: geo.size.width/2))
                                    .onAppear {
                                        withAnimation(.easeInOut(duration: 0.1).repeatCount(9).delay(5).repeatForever()) {
                                            hintWiggle = true
                                        }
                                    } //for wiggle effect animation
                                //to create animation of 3d rotation when clicked on it
                                    .onTapGesture {
                                        withAnimation(.easeOut(duration: 1)) {
                                            revealBook = true
                                        }
                                        
                                        //to play flip sound
                                        playFlipSound()
                                        //deducting 1 from question score
                                        game.questionScore -= 1
                                    }
                                    .rotation3DEffect(
                                        .degrees(revealBook ? 1440 : 0), axis: (x: 0, y: 1, z: 0)
                                    )
                                    .scaleEffect(revealBook ? 5 : 1)
                                    .opacity(revealBook ? 0 : 1)
                                    .offset(x: revealBook ? -geo.size.width/2 : 0) //direction of flippng
                                // to show hint once clicked on abv btn, at the place of the button
                                    .overlay(
                                        Image("hp\(game.currentQuestion.book)")
                                            .resizable()
                                            .scaledToFit()
                                            .padding(.trailing, 33)
                                            .opacity(revealBook ? 1 : 0)
                                            .scaleEffect(revealBook ? 1.33 : 1) //scaling animation when revealing
                                    )
                                //when selected correct answer, this button to be faded and disabled
                                    .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                    .disabled(tappedCorrectAnswer)
                                
                            }
                        }
                        .animation(.easeOut(duration: animateViewsIn ? 1.5 : 0).delay(animateViewsIn ? 2 : 0), value: animateViewsIn)
                        
                    }
                    .padding(.bottom)
                    
                    //MARK: - Answers
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        //Array - converting dictionary to an array
                        //id: \.offset - this is a way to specify id for arrays
                        ForEach(Array(game.answers.enumerated()), id: \.offset) {
                            //from enumerated we got 2 things, i - index, answer - key from dict element
                            i, answer in
                            //checking in the dict of answers in currentquestion by searching abv found answer key if value is true (i.e., correct answer)
                            if game.currentQuestion.answers[answer] == true {
                                //below code for "CORRECT" answer
                                VStack {
                                    if animateViewsIn {
                                        if tappedCorrectAnswer == false {
                                            Text(answer)
                                                .minimumScaleFactor(0.5) //to specify minimum font size
                                                .multilineTextAlignment(.center)
                                                .padding(10)
                                                .frame(width: geo.size.width/2.15, height: 80)
                                                .background(.green.opacity(0.5))
                                                .clipShape(.rect(cornerRadius: 25))
                                            //specifying diff transitions for gameplay vw and celebration vw
                                            //insertion - for gameplay vw
                                            //removal - for celebration vw
                                                .transition(.asymmetric(insertion: .scale, removal: .scale(scale: 5).combined(with: .opacity.animation(.easeOut(duration: 0.5)))))
                                            //for correct answer
                                                .matchedGeometryEffect(id: "answer", in: namespace)
                                            //for tapping on the button
                                                .onTapGesture {
                                                    withAnimation(.easeOut(duration: 1)) {
                                                        tappedCorrectAnswer = true
                                                    }
                                                    
                                                    //play correct sound when tapped on correct answer
                                                    playCorrectSound()
                                                    //to wait for 3.5 sec to update game score using correct fn
                                                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                                                        game.correct()
                                                    }
                                                }
                                        }
                                    }
                                }
                                .animation(.easeOut(duration: animateViewsIn ? 1 : 0).delay(animateViewsIn ? 1.5 : 0), value: animateViewsIn)
                            } else {
                                //below code for "INCORRECT" answer
                                VStack {
                                    if animateViewsIn {
                                        Text(answer)
                                            .minimumScaleFactor(0.5) //to specify minimum font size
                                            .multilineTextAlignment(.center)
                                            .padding(10)
                                            .frame(width: geo.size.width/2.15, height: 80)
                                        //adjusting bg based on answer, checking if tapped wrong answer is already selected then red else keeping green
                                            .background(wrongAnswersTapped.contains(i) ? .red.opacity(0.5) : .green.opacity(0.5))
                                            .clipShape(.rect(cornerRadius: 25))
                                            .transition(.scale)
                                        //for selecting wrong answer
                                            .onTapGesture {
                                                withAnimation(.easeOut(duration: 1)) {
                                                    //adding id of wrong answer tapped to the list
                                                    wrongAnswersTapped.append(i)
                                                }
                                                
                                                //to play tapping incorrect sound
                                                playWrongSound()
                                                //for haptic feedback
                                                giveWrongFeedback()
                                                //deducting 1 from question score
                                                game.questionScore -= 1
                                            }
                                            .scaleEffect(wrongAnswersTapped.contains(i) ? 0.8 : 1)
                                        //when selected correct answer, this button to be faded and disabled
                                            .opacity(tappedCorrectAnswer ? 0.1 : 1)
                                        //to disable this answer once wrong answer is tapped or correct answer is tapped
                                            .disabled(wrongAnswersTapped.contains(i) || tappedCorrectAnswer)
                                    }
                                }
                                .animation(.easeOut(duration: animateViewsIn ? 1 : 0).delay(animateViewsIn ? 1.5 : 0), value: animateViewsIn)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .foregroundStyle(.white)
                
                //MARK: - Celebration screen
                VStack {
                    Spacer()
                    
                    //score got from current question
                    VStack {
                        if tappedCorrectAnswer {
                            Text("\(game.questionScore)")
                                .font(.largeTitle)
                                .padding(.top, 50)
                                .transition(.offset(y: -geo.size.height/4))
                            //below are move transition mods (animate to invisible)
                                .offset(x: movePointsToScore ? geo.size.width/2.3 : 0,
                                        y: movePointsToScore ? -geo.size.height/13: 0)
                                .opacity(movePointsToScore ? 0 : 1)
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1).delay(3)) {
                                        movePointsToScore = true
                                    }
                                }
                        }
                    }
                    .animation(.easeInOut(duration: 1).delay(2), value: tappedCorrectAnswer)
                    
                    Spacer()
                    
                    VStack {
                        if tappedCorrectAnswer {
                            Text("Brilliant!")
                                .font(.custom(Constants.hpFont, size: 100))
                                .transition(.scale.combined(with: .offset(y: -geo.size.height/2))) // combined - to combine 2 diff types of animations together on this view
                        }
                    }
                    .animation(.easeInOut(duration: tappedCorrectAnswer ? 1 : 0).delay(tappedCorrectAnswer ? 1 : 0), value: tappedCorrectAnswer)
                    
                    Spacer()
                    
                    if tappedCorrectAnswer {
                        //correct answer text
                        Text(game.correctAnswer)
                            .minimumScaleFactor(0.5) //to specify minimum font size
                            .multilineTextAlignment(.center) //text alignment when going multiline
                            .padding(10)
                            .frame(width: geo.size.width/2.15, height: 80)
                            .background(.green.opacity(0.5))
                            .clipShape(.rect(cornerRadius: 25))
                            .scaleEffect(2)
                        //for correct answer (linking with main vw)
                            .matchedGeometryEffect(id: "answer", in: namespace)
                    }
                    
                    Group {
                        Spacer()
                        Spacer()
                    }
                    
                    VStack {
                        if tappedCorrectAnswer {
                            Button("Next Level>") {
                                //reseting vars before moving to next question
                                animateViewsIn = false
                                tappedCorrectAnswer = false
                                revealHint = false
                                revealBook = false
                                movePointsToScore = false
                                wrongAnswersTapped = []
                                
                                //getting next question
                                game.newQuestion()
                                
                                //wait for 0.5 sec from now and execute the code within
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    //setting below var to allow next question to load on screen 
                                    animateViewsIn = true
                                }
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.blue.opacity(0.5))
                            .font(.largeTitle)
                            .transition(.offset(y: geo.size.height/3))
                            .scaleEffect(scaleNextButton ? 1.2 : 1) //to add animation effect to this button using var "scalePlayButton"
                            .onAppear {
                                //to start animation of the button once it appears on the screen
                                withAnimation(.easeInOut(duration: 1.3).repeatForever()) {
                                    //easeInOut - after 1.3 duration to play this animation
                                    //repeatForever - to repeat abv animation step forever
                                    //keep toggling "scalePlayButton" value to keep button animated
                                    scaleNextButton.toggle()
                                }
                            }
                        }
                    }
                    .animation(.easeInOut(duration: tappedCorrectAnswer ? 2.7 : 0).delay(tappedCorrectAnswer ? 2.7 : 0), value: tappedCorrectAnswer)
                    
                    Group {
                        Spacer()
                        Spacer()
                    }
                }
                .foregroundStyle(.white)
                
            }
            .frame(width: geo.size.width, height: geo.size.height) //this sets size of zstack and also aligns everything within in center
        }
        .ignoresSafeArea()
        .onAppear {
            animateViewsIn = true
            //to play bg music when this vw loads, wait 3 sec and then start playing music
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                playMusic()
            }
        }
    }
    
    
    //fn to get music file and setting it and playing it on audio player
    private func playMusic() {
        //list of all the songs that can be played as bg music
        let songs = ["let-the-mystery-unfold", "spellcraft", "hiding-place-in-the-forest", "deep-in-the-dell"]
        //to generate a random number to pick a random song
        let i = Int.random(in: 0...3)
        
        //creating a pth for audio file, which needs to be played
        let sound = Bundle.main.path(forResource: songs[i], ofType: "mp3")
        //assigning abv obj to audio player
        musicPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        //keeping volume to 10% to avoid distraction
        musicPlayer.volume = 0.1
        //to run this song in infinite loops use -1
        musicPlayer.numberOfLoops = -1
        //to play the audio player
        musicPlayer.play()
    }
    
    //fn for sound effect for flip (for hints)
    private func playFlipSound() {
        //creating a pth for audio file, which needs to be played
        let sound = Bundle.main.path(forResource: "page-flip", ofType: "mp3")
        //assigning abv obj to audio player
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        //to play this mp3
        sfxPlayer.play()
    }
    
    //fn for sound effect for wrong answer tapped
    private func playWrongSound() {
        //creating a pth for audio file, which needs to be played
        let sound = Bundle.main.path(forResource: "negative-beeps", ofType: "mp3")
        //assigning abv obj to audio player
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        //to play this mp3
        sfxPlayer.play()
    }
    
    //fn for sound effect for wrong answer tapped
    private func playCorrectSound() {
        //creating a pth for audio file, which needs to be played
        let sound = Bundle.main.path(forResource: "magic-wand", ofType: "mp3")
        //assigning abv obj to audio player
        sfxPlayer = try! AVAudioPlayer(contentsOf: URL(filePath: sound!))
        //to play this mp3
        sfxPlayer.play()
    }
    
    //to give haptic feedback when tapped on wrong answer 
    private func giveWrongFeedback() {
        //obj to create haptic feedback
        let generator = UINotificationFeedbackGenerator()
        //type of vibration specified
        generator.notificationOccurred(.error)
    }
}

#Preview {
    GameplayView()
        .environmentObject(Game()) 
}
