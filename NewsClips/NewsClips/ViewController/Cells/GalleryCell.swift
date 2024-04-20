//
//  GalleryCell.swift
//  NewsClips
//
//  Created by Kumaresh on 17/04/24.
//

import UIKit

class GalleryCell: UICollectionViewCell {

    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgThumbnail: UIImageView!
    @IBOutlet weak var lblError: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // Add rounded corners to bgView
        self.bgView.layer.cornerRadius = 5
        self.bgView.layer.borderWidth = 0.5
        self.bgView.layer.borderColor = UIColor.lightGray.cgColor
        
        self.imgThumbnail.layer.cornerRadius = 5
        self.imgThumbnail.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner] 
    }

}
