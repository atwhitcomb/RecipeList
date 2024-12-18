//
//  ImageLoader.swift
//  RecipeList
//
//  Created by Andrew James Whitcomb on 12/15/24.
//

import UIKit
import SwiftUI

/// Protocol to define loading of image data.
protocol ImageLoader {
    /// Makes a request to load an image.
    func loadImage(at url: URL, id: UUID) async -> UIImage?
    
    /// Cancels a request for an image.
    func cancelLoad(for url: URL, id: UUID)
}

/// `EnvironmentKey` for `ImageLoader`.
private struct ImageLoaderKey: EnvironmentKey {
    static let defaultValue: ImageLoader = StandardImageLoader()
}

extension EnvironmentValues {
    var imageLoader: ImageLoader {
        get { self[ImageLoaderKey.self] }
        set { self[ImageLoaderKey.self] = newValue }
    }
}

extension View {
    func imageLoader(_ value: ImageLoader) -> some View {
        environment(\.imageLoader, value)
    }
}
