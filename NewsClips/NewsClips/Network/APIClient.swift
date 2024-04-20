//
//  APIClient.swift
//  NewsClips
//
//  Created by Kumaresh on 17/04/24.
//

import Foundation

class APIClient<Response: Decodable> {
    
    func fetchData(params: [String: Any]? = nil) async throws -> Response {
        var urlComponents = URLComponents(string: "https://acharyaprashant.org/api/v2/content/misc/media-coverages")!
        
        // Append query parameters if provided for GET method
        if let params = params {
            var queryItems = [URLQueryItem]()
            for (key, value) in params {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                queryItems.append(queryItem)
            }
            urlComponents.queryItems = queryItems
        }
        
        // Construct URL from components
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let decoder = JSONDecoder()
        if let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("Response:\n\(jsonData)")
        }
        return try decoder.decode(Response.self, from: data)
    }
    
}
