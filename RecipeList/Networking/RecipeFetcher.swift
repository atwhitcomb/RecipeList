//
//  RecipeFetcher.swift
//  RecipeList
//
//  Created by Andrew James Whitcomb on 12/14/24.
//

import Foundation
import SwiftUI

// While we are only caring about a single API request so far, a protocol to
// define our API is ideal since in this theoretical it is likely in the future
// we will want to show recipes in-app.
/// Protocol to define the simple API to determine how fetch recipes.
protocol RecipeFetcher {
    /// Makes a request to fetch recipes from the underlying data source.
    func fetchRecipes() async throws -> [Recipe]
}

/// `EnvironmentKey` for `RecipeFetcher`.
private struct RecipeFetcherKey: EnvironmentKey {
    static let defaultValue: RecipeFetcher? = nil
}

extension EnvironmentValues {
    var recipeFetcher: RecipeFetcher? {
        get { self[RecipeFetcherKey.self] }
        set { self[RecipeFetcherKey.self] = newValue }
    }
}

extension View {
    func recipeFetcher(_ value: RecipeFetcher?) -> some View {
        environment(\.recipeFetcher, value)
    }
}
