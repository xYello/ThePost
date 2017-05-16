//
//  ProfileTagView.swift
//  ThePost
//
//  Created by Michael Blades on 4/1/17.
//  Copyright © 2017 The Post. All rights reserved.
//

import UIKit

class ProfileTagView: UIView {
    
    private var badgeColor: UIColor = #colorLiteral(red: 0.9600599408, green: 0.6655590534, blue: 0.09231746942, alpha: 1)
    
    override func awakeFromNib() {
        //// Rectangle Drawing
        let rectanglePath = UIBezierPath()
        rectanglePath.move(to: CGPoint(x: -26, y: 10))
        rectanglePath.addLine(to: CGPoint(x: 19, y: 10))
        rectanglePath.addLine(to: CGPoint(x: 19, y: -8))
        rectanglePath.addLine(to: CGPoint(x: -26, y: -8))
        rectanglePath.addLine(to: CGPoint(x: -26, y: 10))
        badgeColor.setFill()
        rectanglePath.fill()
        let rectangleShape = CAShapeLayer()
        rectangleShape.path = rectanglePath.cgPath
        rectangleShape.fillColor = badgeColor.cgColor
        rectangleShape.position = CGPoint(x: self.center.x - self.bounds.width/2 - rectangleShape.bounds.width, y: self.center.y)
        self.layer.addSublayer(rectangleShape)
        
        
        //// Polygon Drawing
        let polygonPath = UIBezierPath()
        polygonPath.move(to: CGPoint(x: 28, y: 0.79))
        polygonPath.addLine(to: CGPoint(x: 20.34, y: 10))
        polygonPath.addLine(to: CGPoint(x: 6.94, y: 7.37))
        polygonPath.addLine(to: CGPoint(x: 6.66, y: -5.43))
        polygonPath.addLine(to: CGPoint(x: 20.34, y: -8))
        polygonPath.addLine(to: CGPoint(x: 28, y: 0.79))
        polygonPath.close()
        badgeColor.setFill()
        polygonPath.fill()
        let polyShape = CAShapeLayer()
        polyShape.path = polygonPath.cgPath
        polyShape.fillColor = badgeColor.cgColor
        polyShape.position = CGPoint(x: rectangleShape.position.x + rectangleShape.bounds.width / 2, y: 100)
        self.layer.addSublayer(polyShape)
        
        let badgeText = UILabel(frame: CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height))
        badgeText.text = "Admin"
        badgeText.font = badgeText.font.withSize(14)
        badgeText.textColor = UIColor.black
        self.addSubview(badgeText)
        self.bringSubview(toFront: badgeText)
        
        
        rectangleShape.bounds.size = CGSize.init(width: self.bounds.width, height: self.bounds.height)
        polyShape.bounds.size = CGSize.init(width: self.bounds.width, height: self.bounds.height)
        
        rectangleShape.position = CGPoint(x: self.center.x - rectangleShape.bounds.size.width / 2, y: (self.center.y - rectangleShape.bounds.size.height / 2) + 5)
        polyShape.position = CGPoint(x: self.center.x - rectangleShape.bounds.size.width / 2, y: rectangleShape.position.y)
        badgeText.center = CGPoint.init(x: (rectangleShape.position.x - (badgeText.bounds.size.width / 2 ) + polyShape.bounds.width / 4) - 6, y: rectangleShape.position.y - rectangleShape.bounds.size.height / 2)
        
    }

}
