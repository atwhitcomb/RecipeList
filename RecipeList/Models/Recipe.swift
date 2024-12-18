//
//  Recipe.swift
//  RecipeList
//
//  Created by Andrew James Whitcomb on 12/14/24.
//

import Foundation

/// The metadata for the recipes displayed within this app.
struct Recipe: Identifiable, Hashable {
    /// The identifier associated with the recipe.
    let id: UUID
    
    /// The name of the recipe.
    let name: String
    
    /// The cuisine type associated with the recipe.
    let cuisine: String
    
    /// The URL to access the large-sized photo for the recipe.
    var largePhotoURL: URL?
    
    /// The URL to access the small-sized photo for the recipe.
    var smallPhotoURL: URL?
    
    /// The URL source of the recipe.
    var sourceURL: URL?
    
    /// The associated YouTube video link for the recipe.
    var youtubeURL: URL?
}
