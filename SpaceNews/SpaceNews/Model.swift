//
//  Model.swift
//  SpaceFlight News
//
//  Created by Nabbel on 10/02/2025.
//

import Foundation

import UIKit

struct ArticlesResponse: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Article]
}

struct Article: Codable {
    let id: Int
    let title: String
    let authors: [Author]
    let url: String
    let image_url: String
    let news_site: String
    let summary: String
    let published_at: String
    let updated_at: String
    let featured: Bool
    let launches : [Launches]
    
}

struct Author: Codable {

}

struct Launches : Codable {
    let launch_id : String
    let provider : String
}

struct Events : Codable {
    
    let event_id : String
    let provider : String
}
