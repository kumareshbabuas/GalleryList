//
//  GalleryViewModel.swift
//  NewsClips
//
//  Created by Kumaresh on 17/04/24.
//

import Foundation

class GalleryViewModel {
    
    func getImageListFromServer(limit:Int = 30, offset:Int = 1) async throws -> GalleryModel{
        let client = APIClient<GalleryModel>()
        var galleryList :GalleryModel = []
        do {
            galleryList = try await client.fetchData(params: ["limit":"\(limit)", "offset" :"\(offset)"])
        }catch {
            throw error
        }
        return galleryList
    }
    
   
}
