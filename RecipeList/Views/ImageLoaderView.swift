//
//  ImageLoaderView.swift
//  RecipeList
//
//  Created by Andrew James Whitcomb on 12/16/24.
//

import SwiftUI

/// `View` to handle the loading of an image.
struct ImageLoaderView {
    /// The load state of the image.
    enum LoadState {
        /// The image is actively loading.
        case loading
        
        /// The image has loaded.
        case image(UIImage)
        
        /// The image failed to load.
        case failed
    }
    
    /// The `ImageLoader` environment variable.
    @Environment(\.imageLoader) private var imageLoader
    
    /// The current state of the image to load.
    @State private var state = LoadState.loading
    
    /// The ID for this view.
    private let id = UUID()
    
    /// The image URL to load.
    let url: URL
}

extension ImageLoaderView: View {
    var body: some View {
        stateView
            .scaledToFit()
            .task {
                guard let image = await imageLoader.loadImage(at: url, id: id) else {
                    state = .failed
                    return
                }
                state = .image(image)
            }
            .onDisappear {
                imageLoader.cancelLoad(for: url, id: id)
            }
    }
    
    @ViewBuilder var stateView: some View {
        switch state {
        case .loading:
            ProgressView()
        case .failed:
            Image("NoImageAvailable")
                .resizable()
        case let .image(image):
            Image(uiImage: image)
                .resizable()
        }
    }
}
