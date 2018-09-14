//
//  CBTPageViewImagesViewController.swift
//  CleverBabyTestApp
//
//  Created by Administrator on 5/31/17.
//  Copyright © 2017 Administrator. All rights reserved.
//

import UIKit

class OFAPageViewImagesViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    var pageIndex: Int = 0
    var strPhotoName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        imageView.image = UIImage(named: strPhotoName)
        imageView.sd_setImage(with: URL(string: strPhotoName), placeholderImage: #imageLiteral(resourceName: "Default image"), options: .progressiveDownload)
    }

}
