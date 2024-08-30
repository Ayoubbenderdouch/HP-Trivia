//
//  InstructionsView.swift
//  HP Trivia-SwiftUI-iOS17
//
//  Created by Mayur Vaity on 18/07/24.
//

import SwiftUI

struct InstructionsView: View {
    //env property to dismiss this view
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            //bg view
            InfoBackgroundImageView()
            
            VStack {
                //appicon image
                Image(.appiconwithradius)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150)
                    .padding(.top)
                
                ScrollView {
                    Text("How To Play")
                        .font(.largeTitle)
                        .padding()
                    
                    VStack(alignment: .leading) {
                         Text("Welcome to HP Trivia! In this game, you will be asked random questions from the HP books and you must guess the right answer or you will lose points! 😱")
                            .padding([.horizontal, .bottom])
                        
                        Text("Each question is worth 5 points, but if you guess a wrong answer, you will lose 1 point.")
                            .padding([.horizontal, .bottom])
                        
                        Text("If you are struggling with a question, there is an option to reveal a hint or reveal the book that answers the question. But beware! Using these also minuses 1 point each.")
                            .padding([.horizontal, .bottom])
                        
                        Text("When you select the correct answer, you will be awarded all the points left for that question and they will be added to your total score.")
                            .padding(.horizontal)
                    }
                    .font(.title3)
                    
                    Text("Good Luck!")
                        .font(.title)
                }
                .foregroundStyle(.black)  //adding text color here to apply to all the text within and also to keep black color while using dark mode
                
                //dismiss button
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }
                .doneButton() //apply custom modifier 
            }
        }
    }
}

#Preview {
    InstructionsView()
}
