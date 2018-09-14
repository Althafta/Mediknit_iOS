//
//  OFAHomePageCollectionViewCell.swift
//  Life_Line
//
//  Created by Administrator on 9/11/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFAHomePageCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageViewHomeIcon: UIImageView!
    @IBOutlet var labelHomeTitle: UILabel!
    
    func customizeCellWithDetails(iconName:String,heading:String){
        self.layer.borderColor = OFAUtils.getColorFromHexString(barTintColor).cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 4
        
        self.imageViewHomeIcon.contentMode = .scaleAspectFit
        self.imageViewHomeIcon.image = UIImage(named: iconName)
        self.labelHomeTitle.text = heading
        self.labelHomeTitle.textColor = .white//OFAUtils.getColorFromHexString(barTintColor)
    }
}
