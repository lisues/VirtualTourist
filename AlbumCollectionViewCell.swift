//
//  AlbumCollectionViewCell.swift
//  VirtualTourist
//
//  Created by Lisue She on 6/23/17.
//  Copyright © 2017 udacity. All rights reserved.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImage: UIImageView!

    override func prepareForReuse() {
        super.prepareForReuse()
        self.photoImage.image = nil
    }
}
