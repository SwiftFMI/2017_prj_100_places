//
//  MeterCircularView.swift
//  CustomControllAdvanced-phaydushki
//
//  Created by Petko Haydushki on 16.11.17.
//  Copyright © 2017 Petko Haydushki. All rights reserved.
//

import UIKit
import MapKit

class MeterCircularView: UIView {

    var arrowLayer : CAShapeLayer = CAShapeLayer.init();
    var arrowPath : UIBezierPath = UIBezierPath()

    var circleLayer : CAShapeLayer = CAShapeLayer.init();
    var circlePath : UIBezierPath = UIBezierPath()
    
    var mapView : MKMapView = MKMapView()
    
    override func awakeFromNib() {
        mapView.showsUserLocation = true
        mapView.isUserInteractionEnabled = false
        addSubview(mapView)
    }
        
    override func draw(_ rect: CGRect) {

        let customGreen : UIColor = UIColor(red: 39.0/255.0, green: 162.0/255.0, blue: 100.0/255.0, alpha: 1.0)
        
        let frameWidth = frame.size.width
        let frameHeight = frame.size.height
        
        let arrowWidth : CGFloat = 8.0
        let arrowCenter = CGPoint(x: (frameWidth / 2.0 ), y:frameHeight / 2.0)
        let arrowTop = CGPoint(x: (frameWidth / 2.0 ), y:arrowWidth * 1.5)
        
        arrowPath.move(to: arrowCenter)
        arrowPath.addArc(withCenter: arrowCenter, radius: arrowWidth * 0.5, startAngle: 0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
        arrowPath.move(to: arrowCenter)
        arrowPath.addLine(to: arrowTop)
        
        arrowLayer.lineCap = kCALineCapRound

        self.layer.cornerRadius = frameHeight/2.0
        self.layer.masksToBounds = true
        self.arrowLayer.contentsScale = 2.0
        
        arrowLayer.path = arrowPath.cgPath
        arrowLayer.fillColor = customGreen.cgColor
        arrowLayer.strokeColor = customGreen.cgColor
        arrowLayer.lineWidth = arrowWidth/2.0
        arrowLayer.bounds = self.layer.bounds
        arrowLayer.position = arrowCenter;
        arrowLayer.anchorPoint =  CGPoint(x: 0.5, y: 0.5)
    
        circlePath.addArc(withCenter: arrowCenter, radius: frameWidth * 0.5, startAngle: 0, endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
    
        circleLayer.path = circlePath.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = customGreen.cgColor
        circleLayer.lineWidth = arrowWidth
        
        self.layer.addSublayer(circleLayer)
        self.layer.addSublayer(arrowLayer)
        
        self.mapView.frame = rect
    }
 
    func rotate() -> Void {
        let kRotationAnimationKey = "rotationanimationkey"
        
            if arrowLayer.animation(forKey: kRotationAnimationKey) == nil {
                let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
                
                rotationAnimation.fromValue = 0.0
                rotationAnimation.toValue = Float.pi * 2.0
                rotationAnimation.duration = 2.0
                rotationAnimation.repeatCount = Float.infinity
                rotationAnimation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionLinear)
                arrowLayer.add(rotationAnimation, forKey: kRotationAnimationKey)
        }
    }
    
    func stopRotating() -> Void {
        
        let kRotationAnimationKey = "rotationanimationkey"
        
        if arrowLayer.animation(forKey: kRotationAnimationKey) != nil {
            arrowLayer.removeAnimation(forKey: kRotationAnimationKey)
        }
    }
}
