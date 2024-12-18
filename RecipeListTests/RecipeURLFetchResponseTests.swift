//
//  RecipeURLFetchResponseTests.swift
//  RecipeList
//
//  Created by Andrew James Whitcomb on 12/16/24.
//

@testable import RecipeList
import XCTest

class RecipeURLFetchResponseTests: XCTest {
    /// JSON object for all the parameters that Recipe item requires.
    let maximumRecipeItemJSON: [String: Any] = [
        "uuid": "0c6ca6e7-e32a-4053-b824-1dbf749910d8",
        "name": "Apam Balik",
        "cuisine": "Malaysian",
        "photo_url_large": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg",
        "photo_url_small": "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg",
        "source_url": "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ",
        "youtube_url": "https://www.youtube.com/watch?v=6R8ffRRJcrg",
    ]
    
    /// `Recipe` object from `maximumRecipeItemJSON`.
    let maximumRecipe: Recipe = .init(
        id: UUID(uuidString: "0c6ca6e7-e32a-4053-b824-1dbf749910d8")!,
        name: "Apam Balik",
        cuisine: "Malaysian",
        largePhotoURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg")!,
        smallPhotoURL: URL(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg")!,
        sourceURL: URL(string: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ")!,
        youtubeURL: URL(string: "https://www.youtube.com/watch?v=6R8ffRRJcrg")!
    )
    
    /// JSON object for the minimum required parameters that Recipe items requires.
    let minimumRecipeItemJSON: [String: Any] = [
        "uuid": "1a86ef7d-a9f1-44c1-a4a0-2278f5916d49",
        "name": "Eton Mess",
        "cuisine": "British",
    ]
    
    /// The minimum keys to be present.
    let minimumKeys = ["uuid", "name", "cuisine"]
    
    /// The URL keys
    let urlKeys = ["photo_url_large", "photo_url_small", "source_url", "youtube_url"]
    
    /// `Recipe` object from `minimumRecipeItemJSON`.
    let minimumRecipe: Recipe = .init(
        id: UUID(uuidString: "1a86ef7d-a9f1-44c1-a4a0-2278f5916d49")!,
        name: "Eton Mess",
        cuisine: "British"
    )
    
    /**
     Gets a `Data` object to test the deserialization of.
     - Parameters:
        - recipes: The recipe JSON objects to pass in.
        - rootKey: The root key to put the `recipes` in it. Defaults to `"recipes"`.
     */
    func responseData(recipeJSONs: [[String: Any]], rootKey: String = "recipes") -> Data {
        try! JSONSerialization.data(withJSONObject: [rootKey: recipeJSONs])
    }
    
    /// Testing to ensure that expected values parse as intended.
    func testValidParse() {
        let responseDataToParse = responseData(
            recipeJSONs: [maximumRecipeItemJSON, minimumRecipeItemJSON]
        )
        do {
            let response = try JSONDecoder().decode(
                RecipeURLFetchResponse.self,
                from: responseDataToParse
            )
            XCTAssertEqual(
                RecipeURLFetchResponse(recipes: [maximumRecipe, minimumRecipe]),
                response
            )
        } catch {
            XCTFail("Failed to parse valid data: \(error)")
        }
    }
    
    /// Testing to ensure that any missing keys causes errors to be thrown.
    func testMissingKeyParse() {
        let keys = minimumRecipeItemJSON.keys
        for key in keys {
            var invalidItemJSON = minimumRecipeItemJSON
            invalidItemJSON.removeValue(forKey: key)
            let responseDataToParse = responseData(
                recipeJSONs: [invalidItemJSON]
            )
            do {
                _ = try JSONDecoder().decode(
                    RecipeURLFetchResponse.self,
                    from: responseDataToParse
                )
                XCTFail("Was able to parse without required key: \(key)")
            } catch {}
        }
    }
    
    /// Test to ensure that an invalid ID will not get parsed somehow.
    func testInvalidIDParse() {
        var invalidItemJSON = maximumRecipeItemJSON
        // Valid UUID format except the first character is a 'g'.
        invalidItemJSON["uuid"] = "gc6ca6e7-e32a-4053-b824-1dbf749910d8"
        do {
            _ = try JSONDecoder().decode(
                RecipeURLFetchResponse.self,
                from: responseData(recipeJSONs: [invalidItemJSON])
            )
            XCTFail("Was able to parse with invalid UUID value")
        } catch {}
        
        // Valid UUID values but missing a character.
        invalidItemJSON["uuid"] = "0c6ca6e7-e32a-4053-b824-1dbf749910d"
        do {
            _ = try JSONDecoder().decode(
                RecipeURLFetchResponse.self,
                from: responseData(recipeJSONs: [invalidItemJSON])
            )
            XCTFail("Was able to parse with invalid UUID format")
        } catch {}
    }
    
    /// Test to ensure that an invalid URL will not get parsed somehow.
    func testInvalidURLParse() {
        for urlKey in urlKeys {
            var invalidItemJSON = minimumRecipeItemJSON
            // We want to check against what may be a URI because that is the most
            // likely to parse when it shouldn't.
            invalidItemJSON[urlKey] = "/recipes/apam-balik~SJ5WuvsDf9WQ"
            do {
                _ = try JSONDecoder().decode(
                    RecipeURLFetchResponse.self,
                    from: responseData(recipeJSONs: [invalidItemJSON])
                )
                XCTFail("Was able to parse with invalid URL for key: \(urlKey)")
            } catch {}
        }
    }
    
    /// Test to ensure a differing root key would not be parsed.
    func testInvalidRootKeyParse() {
        do {
            _ = try JSONDecoder().decode(
                RecipeURLFetchResponse.self,
                from: responseData(recipeJSONs: [maximumRecipeItemJSON], rootKey: "recipe")
            )
            XCTFail("Was able to parse with invalid root key")
        } catch {}
    }
}
