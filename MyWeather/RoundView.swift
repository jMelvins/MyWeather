//
//  RoundView.swift
//  
//
//  Created by Vladislav Shilov on 14.07.17.
//
//

import UIKit

@IBDesignable
class RoundView: UIView {
    
    @IBInspectable var cornerRadius: CGFloat = 0{
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor = .white{
        didSet{
            self.layer.borderColor = borderColor.cgColor
        }
    }
    
}
