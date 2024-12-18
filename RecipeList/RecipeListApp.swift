//
//  RecipeListApp.swift
//  RecipeList
//
//  Created by Andrew James Whitcomb on 12/14/24.
//

import SwiftUI

@main
struct RecipeListApp: App {
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RecipeListView()
            }
            .recipeFetcher(recipeFetcher)
            .onAppear {
                setupURLSession()
            }
        }
    }
    
    var recipeFetcher: any RecipeFetcher {
        return RecipeURLFetcher(
            url: .init(
                string: "https://d3jbb8n5wk0qxi.cloudfront.net/recipes.json"
            )!
        )
    }
    
    func setupURLSession() {
        let configuration = URLSession.shared.configuration
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.timeoutIntervalForRequest = 5.0
        configuration.timeoutIntervalForResource = 5.0
    }
}
