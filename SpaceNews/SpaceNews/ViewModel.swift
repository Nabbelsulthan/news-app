//
//  ViewModel.swift
//  SpaceFlight News
//
//  Created by Nabbel on 10/02/2025.


import Foundation

class ViewModel {
    
    var articles: [Article] = []
    private var nextPageURL: String? = "https://api.spaceflightnewsapi.net/v4/articles/"
    private var isFetching = false
    
    var onDataUpdated: (() -> Void)? // Callback to notify the UI
    
    func fetchArticles() {
        guard let urlString = nextPageURL, let url = URL(string: urlString), !isFetching else { return }
        
        isFetching = true
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isFetching = false
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let response = try decoder.decode(ArticlesResponse.self, from: data)
                        self?.articles.append(contentsOf: response.results)
                        self?.nextPageURL = response.next // Update next page URL
                        self?.onDataUpdated?() // Notify UI to reload
                    } catch {
                        print("Error decoding data: \(error)")
                    }
                }
            }
        }
        task.resume()
    }
}

