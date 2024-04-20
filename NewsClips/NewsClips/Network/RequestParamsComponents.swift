//
//  RequestQueryParams.swift
//  NewsClips
//
//  Created by Kumaresh on 17/04/24.
//

import Foundation
struct RequestParamsComponents {
    var url:URL
    var params : [String : Any]
    //get
    public func getURLWithParams()->String
    {
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return ""
        }
        components.queryItems = params.map {  element in URLQueryItem(name: element.key, value: "\(element.value)")}
        return components.url?.absoluteString.removingPercentEncoding ?? ""
    }
    
}
