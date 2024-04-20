//
//  Image+Extension.swift
//  NewsClips
//
//  Created by Kumaresh on 20/04/24.
//

import UIKit

extension UIImage {
    func centerCrop(toSize targetSize: CGSize) -> UIImage? {
        let imageSize = self.size
        let targetAspectRatio = targetSize.width / targetSize.height
        let imageAspectRatio = imageSize.width / imageSize.height

        var cropRect = CGRect.zero

        if imageAspectRatio > targetAspectRatio {
            // Original image is wider than target aspect ratio, crop the width
            let scaledWidth = imageSize.height * targetAspectRatio
            cropRect = CGRect(x: (imageSize.width - scaledWidth) / 2.0, y: 0, width: scaledWidth, height: imageSize.height)
        } else {
            // Original image is taller than target aspect ratio, crop the height
            let scaledHeight = imageSize.width / targetAspectRatio
            cropRect = CGRect(x: 0, y: (imageSize.height - scaledHeight) / 2.0, width: imageSize.width, height: scaledHeight)
        }

        guard let cgImage = self.cgImage?.cropping(to: cropRect) else {
            return nil
        }

        return UIImage(cgImage: cgImage, scale: self.scale, orientation: self.imageOrientation)
    }
}
