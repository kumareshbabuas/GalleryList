//
//  ImageLoadingManager.swift
//  NewsClips
//
//  Created by Kumaresh on 17/04/24.
//

import Foundation
import UIKit

class ImageLoadingManager {
    private let imageCache = NSCache<NSString, UIImage>()
    private let fileManager = FileManager.default
    private let cacheDirectory = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    private let expirationTime: TimeInterval = 24 * 60 * 60 // 24 hours
    private let imageLoadingQueue = DispatchQueue(label: "com.newsclips.ImageLoadingQueue", attributes: .concurrent)
    
    func loadImage(from url: String, fileKeyName: String) async -> UIImage? {
        // Validate the URL string
        guard let imageURL = URL(string: url) else {
            print("Invalid URL: \(url)")
            return nil
        }
        
        // Check if the image is already cached
        if let cachedImage = imageCache.object(forKey: fileKeyName as NSString) {
            return cachedImage
        }
        
        // Attempt to load the image from disk
        do {
            if let cachedImage = try await loadImageFromDisk(filename: fileKeyName) {
                imageCache.setObject(cachedImage, forKey: fileKeyName as NSString)
                return cachedImage
            }
        }catch {
            
        }
            // Fetch the image data from the URL asynchronously
            do {
                let (data, _) = try await URLSession.shared.data(from: imageURL)
                
                if let image = UIImage(data: data) {
                    // Cache the image
                    imageCache.setObject(image, forKey: fileKeyName as NSString)
                    // Save the image to disk
                    await saveImageToDisk(image: image, filename: fileKeyName)
                    return image
                } else {
                    print("Failed to create image from data")
                    return nil
                }
            } catch {
                print("Error loading image from URL: \(error)")
                return nil
            }
    }

    private func saveImageToDisk(image: UIImage, filename: String) async{
         imageLoadingQueue.async {
            let fileURL = self.cacheDirectory.appendingPathComponent(filename)
            
            let imageDataDict: [String: Any] = ["imageData": image.pngData()!, "timestamp": Date().timeIntervalSince1970]
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: imageDataDict, requiringSecureCoding: true)
                try data.write(to: fileURL)
            } catch {
                print("Error saving image to disk: \(error)")
            }
        }
    }

    func loadImageFromDisk(filename: String) async throws -> UIImage? {
        return try await withCheckedThrowingContinuation { continuation in
            imageLoadingQueue.async {
                do {
                    let fileURL = self.cacheDirectory.appendingPathComponent(filename)
                    
                    guard self.fileManager.fileExists(atPath: fileURL.path) else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    guard let data = try? Data(contentsOf: fileURL) else {
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    guard let imageDataDict  = try NSKeyedUnarchiver.unarchivedObject(ofClasses: [NSDictionary.self, NSData.self, NSDate.self, NSString.self,NSNumber.self], from: data) as? [String: Any],
                          let imageData = imageDataDict["imageData"] as? Data,
                          let timestamp = imageDataDict["timestamp"] as? TimeInterval,
                          Date().timeIntervalSince1970 - timestamp < self.expirationTime else {
                        try? self.fileManager.removeItem(at: fileURL)
                        continuation.resume(returning: nil)
                        return
                    }
                    let image = UIImage(data: imageData)
                    continuation.resume(returning: image)
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}

