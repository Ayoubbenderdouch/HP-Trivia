//
//  Store.swift
//  HP Trivia-SwiftUI-iOS17
//
//  Created by Mayur Vaity on 22/07/24.
//

import Foundation
import StoreKit

//enum of book statuses
enum BookStatus: Codable {
    case active
    case inactive
    case locked
}

//@MainActor - we want this to run on main thread as it is tied so closely to the app
@MainActor
class Store: ObservableObject {
    //var to store bookstatus for each book
    @Published var books: [BookStatus] = [.active, .active, .inactive, .locked, .locked, .locked, .locked]
    //array of storekit products (ones we created in HPConfig file)
    @Published var products: [Product] = []
    
    //a Set to store purchased product IDs (as Set cannot have duplicates, we are using one)
    @Published var purchasedIDs = Set<String>()
    
    //list of product ids created in HPConfig
    private var productIDs = ["hp4", "hp5", "hp6", "hp7"]
    
    //to monitor updates outside the app, using this var to store return data
    private var updates: Task<Void, Never>? = nil
    
    //path to save book statuses
    private let savePath = FileManager.documentsDirectory.appending(path: "SavedBookStatus")
    
    init() {
        //to monitor updates outside the app, calling this fn
        updates = watchForUpdates()
    }
    
    //fn to fill abv products array
    func loadProducts() async {
        do {
            //getting all the products using list of product ids
            products = try await Product.products(for: productIDs)
            //sorting products by id (hp4, hp5, etc.)
            products.sort(by: {$0.id < $1.id})
            
            for product in products {
                print(product.id)
            }
            
        } catch {
            print("Couldn't fetch those products: \(error)")
        }
    }
    
    
    //fn to purchase selected product
    func purchase(_ product: Product) async {
        do {
            
            //try to purchase selected product
            let result = try await product.purchase()
            
            //result cases
            switch result {
            //Purchase successful, but now we have to verify receipt
            case .success(let verificationResult):
                switch verificationResult {
                //error occurred during verification of purchase
                case .unverified(let signedType, let verificationError):
                    print("Error on \(signedType): \(verificationError)")
                    
                //purchase is verified, now need to add to the list
                case .verified(let signedType):
                    //adding purchased product ID to the set
                    purchasedIDs.insert(signedType.productID)
                }
                
            //User cancelled or parent disapproved child's purchase request
            case .userCancelled:
                break
                
            // Waiting for approval from either the user or parent
            case .pending:
                break
            
            //to deal with cases that could be added in the future
            @unknown default:
                break
            }
            
        } catch {
            print("Couldn't purchase that product, \(error)")
        }
    }
    
    //fn to save book statuses data
    func saveStatus() {
        do {
            //encoding book statuses data and keeping it in Data format
            let data = try JSONEncoder().encode(books)
            //writing this data to abv created userDefaults path
            try data.write(to: savePath)
        } catch {
            print("Error saving Book status data, \(error)")
        }
    }
    
    //fn to load statuses data from userDefaults
    func loadStatus() {
        do {
            //getting data from userDefaults path into Data format
            let data = try Data(contentsOf: savePath)
            //decoding data from Data format into a BookStatus array 
            books = try JSONDecoder().decode([BookStatus].self, from: data)
        } catch {
            print("Error loading book statuses, \(error)")
            //no need to set default values to books var here, as they are getting initailized abv 
        }
    }
    
    
    //fn to check products that were purchased in the past, there could be one of the below cases
    //1. user closed the app and re-opened it
    //2. user uninstalled and reinstalled the app
    //3. user switched the iphone
    private func checkPurchased() async {
        //looping through list of purchasable products to check each if purchases
        for product in products {
            //this gets the state (verificationResult) of the current product purchased
            //if purchase is success it returns a value otherwise it moves to else part
            guard let state = await product.currentEntitlement else {
                print("This product is not purchased: \(product.id)")
                continue
//                return
            }
            
            //for success type purchases, there are 2 types of state (verificationResult)
            //need to deal with them separately
            switch state {
            //error occurred during verification of purchase
            case .unverified(let signedType, let verificationError):
                print("Error on \(signedType): \(verificationError)")
                
            //purchase is verified, now need to add to the list
            case .verified(let signedType):
                //checking if there is any revocationDate, if not then adding to the set
                //note: revocationDate not nil - this is a case of refund, in that case Apple puts a date here and refunds money to the user
                if signedType.revocationDate == nil {
                    //adding purchased product ID to the set
                    purchasedIDs.insert(signedType.productID)
                    print("Product ID: \(signedType.productID) is purchased")
                } else {
                    //handling revocation case here, by removing product ID from the set
                    purchasedIDs.remove(signedType.productID)
                }
            }
            
        }
        
       
    }
    
    
    //to monitor updates outside the app, impl below fn
    //case when user makes purchase outside of the app (on the App Store)
    //in this case need to update the user's app accordingly
    //apple has provided below code for such cases, we need to run our checkPurchased fn within this
    private func watchForUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await _ in Transaction.updates {
                //here running our checkPurchased fn to get updates
                await checkPurchased()
                
            }
        }
    }
}
