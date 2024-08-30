//
//  Constants.swift
//  HP Trivia-SwiftUI-iOS17
//
//  Created by Mayur Vaity on 17/07/24.
//

import Foundation
import SwiftUI

enum Constants {
    static let hpFont = "PartyLetPlain"
    
    //sample question for preview,
    //decoding data from trivia file ans getting 1st element of the array
    static let previewQuestion = try! JSONDecoder().decode([Question].self, from: try Data(contentsOf: Bundle.main.url(forResource: "trivia", withExtension: "json")!))[0]
}

//reusable bg image view 
struct InfoBackgroundImageView: View {
    var body: some View {
        Image(.parchment)
            .resizable()
            .ignoresSafeArea()
            .background(.brown)
    }
}

//custome modifier created for Button (by creating an extension)
extension Button {
    //this code below is a custom modifier
    func doneButton() -> some View {
        //all below modifiers will be applied to which ever button this modifier gets applied 
        self
            .font(.largeTitle)
            .padding()
            .buttonStyle(.borderedProminent)
            .tint(.brown)
            .foregroundStyle(.white)
    }
}

//extension to get documents directory
extension FileManager {
    //path to save to defaults 
    static var documentsDirectory: URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
