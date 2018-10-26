//
//  DXIndeterminatedRoundProgressView.swift
//  DXProgressHUD_Swift
//
//  Created by fashion on 2018/8/13.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class DXIndeterminatedRoundProgressView: UIView {

    fileprivate let circleLayer: CAShapeLayer = CAShapeLayer()
    
    var lineColor: UIColor = UIColor.white {
        didSet {
            self.dx_updateUI()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
        
        setupAndStartRotatingCircle()
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: 37.0, height: 37.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupAndStartRotatingCircle() {
        let circlePath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.bounds.size.width / 2)
        circleLayer.frame = self.bounds
        circleLayer.path = circlePath.cgPath
        circleLayer.strokeColor = lineColor.cgColor
        circleLayer.lineWidth = 2.0
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineCap = CAShapeLayerLineCap.round
        
        self.layer.addSublayer(circleLayer)
        
        startRotatingCircle()
    }
    
    fileprivate func startRotatingCircle() {
        let animationForStrokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        animationForStrokeEnd.fromValue = 0.0
        animationForStrokeEnd.toValue = 1.0
        animationForStrokeEnd.duration = 0.4
        animationForStrokeEnd.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        
        let animationForStrokeStart = CABasicAnimation(keyPath: "strokeStart")
        animationForStrokeStart.fromValue = 0.0
        animationForStrokeStart.toValue = 1.0
        animationForStrokeStart.duration = 0.4
        animationForStrokeStart.beginTime = 0.5
        animationForStrokeStart.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeIn)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [animationForStrokeEnd, animationForStrokeStart]
        animationGroup.duration = 0.9
        animationGroup.repeatCount = MAXFLOAT
        
        circleLayer.add(animationGroup, forKey: nil)
    }

}
