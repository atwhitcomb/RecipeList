//
//  ContentView.swift
//  RecipeList
//
//  Created by Andrew James Whitcomb on 12/14/24.
//

import SwiftUI

/// The primary view in which the recipes are displayed on.
struct RecipeListView {
    @Environment(\.recipeFetcher) var recipeFetcher
    @State private var isLoading = false
    @State private var recipes: [Recipe] = []
    @State private var selectedRecipe: Recipe?
    @State private var showingOptions = false
    @State private var showingError = false
    
    func refreshList() {
        Task {
            await refreshList()
        }
    }
    
    @MainActor func refreshList() async {
        guard !isLoading else { return }
        isLoading = true
        do {
            guard let recipeFetcher else {
                return
            }
            
            recipes = try await recipeFetcher.fetchRecipes()
            isLoading = false
        } catch {
            isLoading = false
            showingError = true
        }
    }
}

extension RecipeListView: View {
    var body: some View {
        mainBody
            .navigationTitle("Recipe List")
            .task {
                await refreshList()
            }
            .onChange(of: selectedRecipe) { _, newValue in
                showingOptions = newValue != nil
            }
            .confirmationDialog(
                selectedRecipe?.name ?? "",
                isPresented: $showingOptions,
                titleVisibility: .visible,
                presenting: selectedRecipe,
                actions: dialogBody(from:)
            )
            .alert("Error", isPresented: $showingError) {
                Button("Ok") { }
                Button("Try Again") { refreshList() }
            } message: {
                Text("Unable to load the recipe list. Please try again.")
            }
            
    }
    
    @ViewBuilder var mainBody: some View {
        if isLoading && recipes.count == 0 {
            loadingView
        } else if isLoading || recipes.count > 0 {
            listView
        } else {
            emptyView
        }
    }
    
    var loadingView: some View {
        ProgressView()
    }
    
    var listView: some View {
        List(recipes, selection: $selectedRecipe) { recipe in
            RecipeListItemView(recipe: recipe)
                .tag(recipe)
                .listRowBackground(Color.clear)
        }
        .refreshable {
            await refreshList()
        }
        .listStyle(.plain)
    }
    
    var emptyView: some View {
        VStack {
            Text("No recipes found.")
            Button {
                refreshList()
            } label: {
                Text("Refresh")
            }
            .buttonStyle(.automatic)
        }
    }
    
    @ViewBuilder func dialogBody(from recipe: Recipe) -> some View {
        if let sourceURL = recipe.sourceURL {
            Button("View Original Source") {
                selectedRecipe = nil
                UIApplication.shared.open(sourceURL)
            }
        }
        
        if let youtubeURL = recipe.youtubeURL {
            Button("View on YouTube") {
                selectedRecipe = nil
                UIApplication.shared.open(youtubeURL)
            }
        }
        
        Button("Cancel", role: .cancel) {
            selectedRecipe = nil
        }
    }
}

#Preview {
    let mockRecipes: [Recipe] = [
        .init(
            id: .init(uuidString: "0c6ca6e7-e32a-4053-b824-1dbf749910d8")!,
            name: "Apam Balik",
            cuisine: "Malaysian",
            largePhotoURL: .init(
                string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg"
            ),
            smallPhotoURL: .init(
                string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg"
            ),
            sourceURL: .init(
                string: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ"
            ),
            youtubeURL: .init(
                string: "https://www.youtube.com/watch?v=6R8ffRRJcrg"
            )
        ),
        .init(
            id: .init(uuidString: "1a86ef7d-a9f1-44c1-a4a0-2278f5916d49")!,
            name: "Eton Mess",
            cuisine: "British",
            largePhotoURL: .init(
                string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/258262f1-57dc-4895-8856-bf95aee43054/large.jpg"
            ),
            smallPhotoURL: .init(
                string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/258262f1-57dc-4895-8856-bf95aee43054/small.jpg"
            ),
            youtubeURL: .init(
                string: "https://www.youtube.com/watch?v=43WgiNq54L8"
            )
        ),
    ]
    let mockRecipeFetcher = RecipeMockFetcher(
        returnType: .recipes(mockRecipes),
        delay: 3.0
    )
    
    NavigationStack {
        RecipeListView()
            .recipeFetcher(mockRecipeFetcher)
    }
}

#Preview("RecipeListView - Error") {
    let mockRecipeFetcher = RecipeMockFetcher(
        returnType: .throwError(CancellationError()),
        delay: 3.0
    )
    
    NavigationStack {
        RecipeListView()
            .recipeFetcher(mockRecipeFetcher)
    }
}

#Preview("RecipeListView - Empty") {
    let mockRecipeFetcher = RecipeMockFetcher(
        returnType: .empty,
        delay: 3.0
    )
    
    NavigationStack {
        RecipeListView()
            .recipeFetcher(mockRecipeFetcher)
    }
}

struct RecipeListItemView: View {
    @Environment(\.imageLoader) var imageLoader
    let recipe: Recipe
    
    var body: some View {
        VStack {
            HStack {
                if let url = recipe.smallPhotoURL ?? recipe.largePhotoURL {
                    ImageLoaderView(url: url)
                        .frame(width: 60.0, height: 60.0)
                        
                }
                VStack(alignment: .leading) {
                    Text(recipe.name)
                        .font(.title3)
                        .minimumScaleFactor(0.7)
                    Text(recipe.cuisine)
                        .font(.subheadline)
                }
                
                Spacer()
            }
        }
        .padding(.horizontal, 0)
    }
}

#Preview(String(describing: RecipeListItemView.self), traits: .sizeThatFitsLayout) {
    let recipe = Recipe(
        id: .init(uuidString: "0c6ca6e7-e32a-4053-b824-1dbf749910d8")!,
        name: "Apam Balik",
        cuisine: "Malaysian",
        largePhotoURL: .init(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/large.jpg"),
        smallPhotoURL: .init(string: "https://d3jbb8n5wk0qxi.cloudfront.net/photos/b9ab0071-b281-4bee-b361-ec340d405320/small.jpg"),
        sourceURL: .init(string: "https://www.nyonyacooking.com/recipes/apam-balik~SJ5WuvsDf9WQ"),
        youtubeURL: .init(string: "https://www.youtube.com/watch?v=6R8ffRRJcrg")
    )

    RecipeListItemView(recipe: recipe)
}
