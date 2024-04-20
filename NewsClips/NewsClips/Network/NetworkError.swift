//
//  NetworkError.swift
//  NewsClips
//
//  Created by Kumaresh on 17/04/24.
//

import Foundation
import Network

enum NetworkError: Error {
    case transportError(Error)
    case serverError(statusCode: Int)
    case invalidData
    case serverMessage(msg: String)
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingError(Error)
    case encodingError(Error)
    case customError(msg: String)
}
extension NetworkError {
    init?(data: Data?,response: URLResponse?, error: Error?) {
        if let error = error {
            self = .requestFailed(error)
            return
        }

        if let response = response as? HTTPURLResponse, !(200...300).contains(response.statusCode) {
            do {
                if let data = data,
                   let jsonData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
//                    //print("Response:\n\(jsonData)")
                }
            } catch {
                //print("Nil")
            }
            self =  .serverError(statusCode: response.statusCode)
            return
        }
       
        if data == nil {
            self = .invalidData
            return
        }
        
        return nil
    }
    
}

extension NetworkError {
    
    var message: String {
           switch self {
           case .invalidData:
               return "Server without response object"
           case .serverMessage(let errMessage):
               return "service response error with: \(errMessage)"
           case .decodingError(let error):
               return "Decoding error with: \(error.localizedDescription)"
           case .encodingError(let err):
               return "Decoding error with: \(err.localizedDescription)"
           case .transportError(let err):
               return "transportError with: \(err.localizedDescription)"
           case .serverError(let statusCode):
               return "server error with status Code: \(statusCode)"
           case .customError(let msg):
               return "custom error: \(msg)"
           case .invalidURL:
               return "InvalidURL"
           case .requestFailed(let err):
               return "custom error: \(err.localizedDescription)"
           case .invalidResponse:
               return "Invalid response"
           }
       }
    

}

