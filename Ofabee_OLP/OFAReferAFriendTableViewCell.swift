//
//  OFAReferAFriendTableViewCell.swift
//  Life_Line
//
//  Created by Administrator on 6/25/18.
//  Copyright © 2018 Administrator. All rights reserved.
//

import UIKit

class OFAReferAFriendTableViewCell: UITableViewCell {

    @IBOutlet var imageViewProgramme: UIImageView!
    @IBOutlet var labelProgrammeTitle: UILabel!
    @IBOutlet var labelDescription: UILabel!
    @IBOutlet var buttonRefer: UIButton!
    @IBOutlet var viewBackground: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func customizeCellWithDetails(programmeDescription:String,imageURLString:String,programmeTitle:String){
        self.labelDescription.text = programmeDescription
        self.labelProgrammeTitle.text = programmeTitle
        self.imageViewProgramme.sd_setImage(with: URL(string: imageURLString), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .progressiveDownload)
        
        self.viewBackground.layer.cornerRadius = 10.0
        
        let path = UIBezierPath(roundedRect:self.imageViewProgramme.bounds,
                                byRoundingCorners:[.topRight, .topLeft],
                                cornerRadii: CGSize(width: 10, height:  10))
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        self.imageViewProgramme.layer.mask = maskLayer
        
        let buttonPath = UIBezierPath(roundedRect:self.buttonRefer.bounds,
                                byRoundingCorners:[.bottomLeft, .bottomRight],
                                cornerRadii: CGSize(width: 10, height:  10))
        
        let maskLayerForButton = CAShapeLayer()
        
        maskLayerForButton.path = buttonPath.cgPath
        self.buttonRefer.layer.mask = maskLayerForButton
        
        self.viewBackground.dropShadow()
    }
}
