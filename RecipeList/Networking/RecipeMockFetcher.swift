//
//  RecipeMockFetcher.swift
//  RecipeList
//
//  Created by Andrew James Whitcomb on 12/15/24.
//

#if DEBUG
/// Mock object for `RecipeFetcher` to provide a given return type.
struct RecipeMockFetcher {
    /// The return type the `RecipeFetcher` should return.
    enum ReturnType {
        /// To return an array of recipes.
        case recipes([Recipe])
        
        /// To throw an error.
        case throwError(Error)
        
        /// To return an empty array of recipes.
        static let empty: ReturnType = .recipes([])
    }
    
    /// What `fetchRecipes` should return.
    let returnType: ReturnType
    
    /// The delay on returning in seconds. If `nil`, will perform synchronously.
    var delay: Double?
}

extension RecipeMockFetcher: RecipeFetcher {
    func fetchRecipes() async throws -> [Recipe] {
        if let delay {
            try? await Task.sleep(for: .seconds(delay))
        }
        switch returnType {
        case let .recipes(recipes):
            return recipes
        case let .throwError(error):
            throw error
        }
    }
}
#endif
