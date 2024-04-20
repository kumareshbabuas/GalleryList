//
//  GalleryModel.swift
//  NewsClips
//
//  Created by Kumaresh on 17/04/24.
//

import Foundation

// MARK: - GalleryModel
struct GalleryModelElement: Codable {
    let id, title: String?
    let thumbnail: Thumbnail?
}

// MARK: - Thumbnail
struct Thumbnail: Codable {
    let id: String?
    let version: Int?
    let domain: String?
    let basePath: String?
    let key: String?
    let qualities: [Int]?
    let aspectRatio: Double?
}

typealias GalleryModel = [GalleryModelElement]

