//
//  DXRoundProgressView.swift
//  DXProgressHUD_Swift
//
//  Created by fashion on 2018/8/11.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

//MARK: - Extension UIView
extension UIView {
    func dx_updateUI() {
        DispatchQueue.main.async {
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
}

class DXRoundProgressView: UIView {

    var progress: Float = 0.0 {
        didSet {
            self.dx_updateUI()
        }
    }
    
    var progressTintColor: UIColor {
        didSet {
            self.dx_updateUI()
        }
    }
    
    var backgroundTintColor: UIColor {
        didSet {
            self.dx_updateUI()
        }
    }
    // 环形
    var annular: Bool = false {
        didSet {
            self.dx_updateUI()
        }
    }
    
    convenience init() {
        self.init(frame: CGRect(x: 0.0, y: 0.0, width: 37.0, height: 37.0))
    }
    
    override init(frame: CGRect) {
        progressTintColor = UIColor(white: 1.0, alpha: 1.0)
        backgroundTintColor = UIColor(white: 1.0, alpha: 0.1)
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clear
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let allRect: CGRect = self.bounds
        let circleRect: CGRect = allRect.insetBy(dx: 2.0, dy: 2.0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        
        if annular {
            // Draw background
            let lineWidth: CGFloat = 2.0
            let processBackgroundPath: UIBezierPath = UIBezierPath()
            
            processBackgroundPath.lineWidth = lineWidth
            processBackgroundPath.lineCapStyle = CGLineCap.butt
            
            let center: CGPoint = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
            let radius: CGFloat = (self.bounds.size.width - lineWidth) / 2
            let startAngle: CGFloat = -(CGFloat(Double.pi) / 2)
            var endAngle: CGFloat = (2 * CGFloat(Double.pi)) + startAngle
            processBackgroundPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            backgroundTintColor.set()
            processBackgroundPath.stroke()
            
            // Draw progress
            let processPath: UIBezierPath = UIBezierPath()
            processPath.lineCapStyle = CGLineCap.square
            processPath.lineWidth = lineWidth
            endAngle = CGFloat(progress) * 2 * CGFloat(Double.pi) + startAngle
            processPath.addArc(withCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
            progressTintColor.set()
            processPath.stroke()
        } else {
            // Draw background
            progressTintColor.setStroke()
            backgroundTintColor.setFill()
            context.setLineWidth(2.0)
            context.fillEllipse(in: circleRect)
            context.strokeEllipse(in: circleRect)
            
            // Draw progress
            let center: CGPoint = CGPoint(x: allRect.size.width / 2, y: allRect.size.height / 2)
            let radius: CGFloat = (allRect.size.width - 4) / 2
            let startAngle: CGFloat = -(CGFloat(Double.pi) / 2)
            let endAngle: CGFloat = CGFloat(progress) * 2 * CGFloat(Double.pi) + startAngle
            progressTintColor.setFill()
            context.move(to: CGPoint(x: center.x, y: center.y))
            context.addArc(center: CGPoint(x:center.x,y:center.y), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            context.closePath()
            context.fillPath()
        }
    }

}
