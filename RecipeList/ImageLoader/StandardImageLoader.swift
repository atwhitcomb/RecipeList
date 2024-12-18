//
//  StandardImageLoader.swift
//  RecipeList
//
//  Created by Andrew James Whitcomb on 12/15/24.
//

import Foundation
import UIKit

/// A standard image loader, having an internal cache. Defaults to a 20 MB
/// cache but can be changed with the `cacheSize` property.
actor StandardImageLoader {
    /// The identifier for a given load.
    private struct LoadIdentifier: Hashable {
        let url: URL
        let id: UUID
    }
    
    /// The session object to use. Defaults to the default session.
    var session = URLSession.shared
    
    // A hand-written cache object could be done, but it makes sense not to
    // recreate the wheel from complete scratch. NSCache is a bit awkward given
    // it forces the use of Class objects, being written before Swift was a
    // thing, but it can handle disposing of older data rather easily.
    /// The image cache.
    private let cache = {
        let cache = NSCache<NSURL, UIImage>()
        cache.countLimit = 20 * 1024 * 1024
        return cache
    }()
    
    /// The image cache size.
    var cacheSize: Int {
        get {
            cache.countLimit
        }
        set {
            cache.countLimit = newValue
        }
    }
    
    /// Stores the associated identifiers requesting a given `URL`.
    private var urlMapping = [URL: Set<UUID>]()
    
    /// Stores the continuations that need to be resolved for a given URL.
    private var continuations = [LoadIdentifier: CheckedContinuation<UIImage?, Never>]()
    
    /// Stores the associated `Task` object for a given URL.
    private var urlTasks = [URL: Task<Void, Never>]()
    
    /**
     Starts a request for the data for a given URL.
     - Parameters:
        - url: The URL to fire off a data request for.
        - id: The ID to associate with the request.
        - continuation: The continuation to complete the request with.
     */
    private func startRequest(
        for url: URL,
        id: UUID,
        continuation: CheckedContinuation<UIImage?, Never>
    ) {
        urlMapping[url, default: []].insert(id)
        
        let loadIdentifier = LoadIdentifier(url: url, id: id)
        if let continuation = continuations[loadIdentifier] {
            continuation.resume(returning: nil)
        }
        continuations[loadIdentifier] = continuation
        if urlTasks.keys.contains(loadIdentifier.url) {
            return
        }
            
        urlTasks[url] = Task {
            await startRequest(for: url)
        }
    }
    
    /**
     Fires off a request for the data for a given URL.
     - Parameter url: The URL to fire off a data request for.
     */
    private func startRequest(for url: URL) async {
        var result: UIImage?
        if let (data, _) = try? await session.data(from: url),
           let image = UIImage(data: data) {
            result = image
            cache.setObject(image, forKey: url as NSURL, cost: data.count)
        }
        
        let ids = urlMapping[url, default: []]
        for id in ids {
            continuations
                .removeValue(forKey: .init(url: url, id: id))?
                .resume(returning: result)
        }
        urlMapping.removeValue(forKey: url)
        urlTasks.removeValue(forKey: url)
    }
    
    /**
     Cancels the load for a URL with the given ID. If the given URL has other IDs
     requesting said load, it will continue.
     */
    func cancelLoad(for url: URL, id: UUID) async {
        urlMapping[url]?.remove(id)
        continuations
            .removeValue(forKey: .init(url: url, id: id))?
            .resume(returning: nil)
        if urlMapping[url]?.isEmpty ?? true {
            urlTasks.removeValue(forKey: url)?.cancel()
        }
    }
}

extension StandardImageLoader: ImageLoader {
    func loadImage(at url: URL, id: UUID) async -> UIImage? {
        if let image = cache.object(forKey: url as NSURL) {
            return image
        }
        
        return await withCheckedContinuation { continuation in
            startRequest(for: url, id: id, continuation: continuation)
        }
    }
    
    nonisolated func cancelLoad(for url: URL, id: UUID) {
        Task {
            await cancelLoad(for: url, id: id)
        }
    }
}


