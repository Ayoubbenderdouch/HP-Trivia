//
//  SettingsView.swift
//  HP Trivia-SwiftUI-iOS17
//
//  Created by Mayur Vaity on 18/07/24.
//

import SwiftUI

struct SettingsView: View {
    //env property to dismiss this vw
    @Environment(\.dismiss) private var dismiss
    
    //env obj containing store class obj
    @EnvironmentObject private var store: Store
    
    var body: some View {
        ZStack {
            //bg image
            InfoBackgroundImageView()
            
            VStack {
                //main title of the screen
                Text("Which books would you like to see questions from?")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                
                ScrollView {
                    //[GridItem(), GridItem()] - only 2, as to show only 2 cols per row
                    LazyVGrid(columns: [GridItem(), GridItem()]) {
                        
                        ForEach(0..<7) { i in
                            //book state 1 - selected book (unlocked and selected)
                            //also checking for locked but purchased
                            if store.books[i] == .active || (store.books[i] == .locked && store.purchasedIDs.contains("hp\(i+1)")) {
                                //alignment: .bottomTrailing - to align all content in this vw bottom-right corner (in this case to add tick mark image at bottom-right corner of the book)
                                ZStack(alignment: .bottomTrailing) {
                                    //book image
                                    //image name derived using i
                                    Image("hp\(i+1)")
                                        .resizable()
                                        .scaledToFit()
                                        .shadow(radius: 7)
                                    
                                    //check mark to indicate selected book
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.largeTitle)
                                        .imageScale(.large)
                                        .foregroundStyle(.green)
                                        .shadow(radius: 1)
                                        .padding(3)
                                }
                                .task {
                                    //making aleady active and (locked but active) books active
                                    store.books[i] = .active
                                    //fn to save statuses to userdefaults
                                    store.saveStatus()
                                }
                                .onTapGesture {
                                    //to change status to inactive when tapped on an active book
                                    store.books[i] = .inactive
                                    //fn to save statuses to userdefaults
                                    store.saveStatus()
                                }
                            } //book state 2 - unselected and unlocked
                            else if store.books[i] == .inactive {
                                ZStack(alignment: .bottomTrailing) {
                                    //book image
                                    //image name derived using i
                                    Image("hp\(i+1)")
                                        .resizable()
                                        .scaledToFit()
                                        .shadow(radius: 7)
                                        .overlay(Rectangle().opacity(0.33)) //darkened effect on image
                                    
                                    //checkmark unselected (it's only a circle)
                                    Image(systemName: "circle")
                                        .font(.largeTitle)
                                        .imageScale(.large)
                                        .foregroundStyle(.green.opacity(0.5))
                                        .shadow(radius: 1)
                                        .padding(3)
                                }
                                .onTapGesture {
                                    //to change status to active when tapped on an inactive book
                                    store.books[i] = .active
                                    //fn to save statuses to userdefaults
                                    store.saveStatus()
                                }
                            } else {
                                //book state 3 -  locked
                                ZStack {
                                    //book image
                                    //image name derived using i
                                    Image("hp\(i+1)")
                                        .resizable()
                                        .scaledToFit()
                                        .shadow(radius: 7)
                                        .overlay(Rectangle().opacity(0.75)) //darkened effect on image
                                    
                                    //lock on the book image
                                    Image(systemName: "lock.fill")
                                        .font(.largeTitle)
                                        .imageScale(.large)
                                        .shadow(color: .white, radius: 3)
                                }
                                .onTapGesture {
                                    //creating Product obj of selected book
                                    let product = store.products[i-3]
                                    
                                    print("Selected product from store list: \(product)")
                                    
                                    //async fn needs to be run within a Task
                                    Task {
                                        //calling fn to purchase the selected product
                                        await store.purchase(product)
                                    }
                                    //not saving status here, as it will get handled in .active sction abv 
                                }
                                
                            }
                        }
                        
                    }
                    .padding()
                }
                
                //dismiss button
                Button("Done") {
                    dismiss()
                }
                .doneButton()
                
            }
            .foregroundColor(.black) //to assign default font color for everything in the abv vstack (to make this vw look ok in dark mode)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(Store())  //creating a store obj and passing for preview 
}
