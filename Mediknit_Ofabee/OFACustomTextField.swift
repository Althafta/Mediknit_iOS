//
//  CACustomTextField.swift
//  CalendarApp
//
//  Created by BonMac1 on 07/11/15.
//  Copyright © 2015 bon. All rights reserved.
//

import UIKit

@IBDesignable class OFACustomTextField: UITextField {
    override func draw(_ rect: CGRect) {
        self.borderStyle = .line
        let viewRightPadding=UIView(frame: CGRect(x: 0,y: 0,width: self.bounds.size.width/7,height: self.bounds.size.height))
        let imageView=UIImageView(image: rightPaddingImage)
        imageView.tag=10
        imageView.frame=CGRect(x: 0, y: 0, width: viewRightPadding.bounds.size.width-10, height: viewRightPadding.bounds.size.height)
        imageView.contentMode=UIView.ContentMode.right
        viewRightPadding.addSubview(imageView)
        rightView=viewRightPadding
        rightViewMode = UITextField.ViewMode.always
        
        let viewLeftPadding=UIView(frame: CGRect(x: 0,y: 0,width: self.bounds.size.width/7,height: self.bounds.size.height))
        let imageViewLeft=UIImageView(image: leftPaddingImage)
        imageViewLeft.tag=11
        imageViewLeft.frame=CGRect(x: 0, y: 0, width: viewLeftPadding.bounds.size.width-10, height: viewLeftPadding.bounds.size.height)
        imageViewLeft.image = imageViewLeft.image?.withRenderingMode(.alwaysTemplate)
        imageViewLeft.tintColor = OFAUtils.getColorFromHexString(barTintColor)
        imageViewLeft.contentMode=UIView.ContentMode.left
        viewLeftPadding.addSubview(imageViewLeft)
        leftView=viewLeftPadding
        leftViewMode = UITextField.ViewMode.always

    }
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }
    @IBInspectable var rightPaddingImage:UIImage?
    @IBInspectable var leftPaddingImage:UIImage?
}

