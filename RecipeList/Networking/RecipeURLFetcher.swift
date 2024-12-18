//
//  RecipeURLFetcher.swift
//  RecipeList
//
//  Created by Andrew James Whitcomb on 12/14/24.
//

import Foundation

/// The response object from fetching recipes.
struct RecipeURLFetchResponse {
    /// The recipes received in the response.
    let recipes: [Recipe]
}

extension RecipeURLFetchResponse: Decodable {
    /// Coding keys for the base layer response.
    enum CodingKeys: String, CodingKey {
        case recipes
    }
    
    enum RecipesCodingKeys: String, CodingKey {
        case id = "uuid"
        case name
        case cuisine
        case largePhotoURL = "photo_url_large"
        case smallPhotoURL = "photo_url_small"
        case sourceURL = "source_url"
        case youtubeURL = "youtube_url"
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        var recipesContainer = try container.nestedUnkeyedContainer(
            forKey: CodingKeys.recipes
        )
        var recipes = [Recipe]()
        while !recipesContainer.isAtEnd {
            let recipeItem = try recipesContainer.nestedContainer(
                keyedBy: RecipesCodingKeys.self
            )
            // We could have this directly coded into Recipe but on a personal
            // level, I rather manually encode into Recipe as to avoid needing
            // a transfer object let alone.
            recipes.append(
                .init(
                    id: try recipeItem.decode(UUID.self, forKey: .id),
                    name: try recipeItem.decode(String.self, forKey: .name),
                    cuisine: try recipeItem.decode(String.self, forKey: .cuisine),
                    largePhotoURL: try recipeItem.decodeIfPresent(URL.self, forKey: .largePhotoURL),
                    smallPhotoURL: try recipeItem.decodeIfPresent(URL.self, forKey: .smallPhotoURL),
                    sourceURL: try recipeItem.decodeIfPresent(URL.self, forKey: .sourceURL),
                    youtubeURL: try recipeItem.decodeIfPresent(URL.self, forKey: .youtubeURL)
                )
            )
        }
        self.recipes = recipes
    }
}

extension RecipeURLFetchResponse: Equatable {}

/// Recipe fetcher that takes a URL endpoint.
actor RecipeURLFetcher {
    /// The URL to fetch the recipes from.
    let url: URL
    
    /// The session object to use. Defaults to `URLSession.shared`.
    var session = URLSession.shared
    
    init(url: URL) {
        self.url = url
    }
}

extension RecipeURLFetcher: RecipeFetcher {
    func fetchRecipes() async throws -> [Recipe] {
        let (data, _) = try await session.data(from: url)
        let decoder = JSONDecoder()
        return try decoder.decode(
            RecipeURLFetchResponse.self,
            from: data
        ).recipes
    }
}
