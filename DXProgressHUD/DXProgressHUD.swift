//
//  DXProgressHUD.swift
//  DXProgressHUD_Swift
//
//  Created by fashion on 2018/8/11.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

class DXProgressHUD: UIView {

    fileprivate var useAnimation: Bool = true
    fileprivate var closureForExecution: DXProgressHUDExecutionClosures?
    fileprivate var label: UILabel!
    fileprivate var detailsLabel: UILabel!
    fileprivate var rotationTransform: CGAffineTransform = CGAffineTransform.identity
    
    fileprivate var indicator: UIView?
    fileprivate var graceTimer: Timer?
    fileprivate var minShowTimer: Timer?
    fileprivate var showStarted: Date?
    
    var customView: UIView? {
        didSet {
            self.updateIndicators()
            self.dx_updateUI()
        }
    }
    /// toast 位置
    var position = DXProgressPosition.center {
        didSet {
            self.dx_updateUI()
        }
    }
    
    var animationType = DXProgressHUDAnimation.fade
    var mode = DXProgressHUDMode.indeterminate {
        didSet {
            self.updateIndicators()
            self.dx_updateUI()
        }
    }
    var labelText: String? {
        didSet {
            label.text = labelText
            self.dx_updateUI()
        }
    }
    var detailsLabelText: String? {
        didSet {
            detailsLabel.text = detailsLabelText
            self.dx_updateUI()
        }
    }
    var opacity = 0.8
    var color: UIColor?
    var labelFont = UIFont.boldSystemFont(ofSize: kLabelFontSize) {
        didSet {
            label.font = labelFont
            self.dx_updateUI()
        }
    }
    var labelColor = UIColor.white {
        didSet {
            label.textColor = labelColor
            self.dx_updateUI()
        }
    }
    var detailsLabelFont = UIFont.boldSystemFont(ofSize: kDetailsLabelFontSize) {
        didSet {
            detailsLabel.font = detailsLabelFont
            self.dx_updateUI()
        }
    }
    var detailsLabelColor = UIColor.white {
        didSet {
            detailsLabel.textColor = detailsLabelColor
            self.dx_updateUI()
        }
    }
    var activityIndicatorColor = UIColor.white {
        didSet {
            self.updateIndicators()
            self.dx_updateUI()
        }
    }
    var xOffset = 0.0
    var yOffset = 0.0
    var dimBackground = false
    var margin = 20.0
    var cornerRadius = 10.0
    var graceTime = 0.0
    var minShowTime = 0.0
    var removeFromSuperViewOnHide = false
    var minSize: CGSize = CGSize.zero
    var square = false
    var size: CGSize = CGSize.zero
    
    var taskInprogress = false
    
    var progress: Float = 0.0 {
        didSet {
           // self.indicator?.setValue(progress, forKeyPath: "progress")
            if let cator = indicator as? DXRoundProgressView {
                cator.progress = progress
            }
            
            if let cator = indicator as? DXBarProgressView {
                cator.progress = progress
            }
        }
    }
    
    var completionBlock: DXProgressHUDCompletionBlock?
    
    var delegate: DXProgressHUDDelegate?
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.contentMode = UIViewContentMode.center
        self.autoresizingMask = [UIViewAutoresizing.flexibleTopMargin, UIViewAutoresizing.flexibleBottomMargin, UIViewAutoresizing.flexibleLeftMargin, UIViewAutoresizing.flexibleRightMargin]
        self.isOpaque = false
        self.backgroundColor = UIColor.clear
        self.alpha = 0.0
        
        self.setupLabels()
        self.updateIndicators()
    }
    
    convenience init(view: UIView?) {
        assert(view != nil, "View must not be nil.")
        
        self.init(frame: view!.bounds)
    }
    
    convenience init(window: UIWindow) {
        self.init(view: window)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.unregisterFromNotifications()
    }
    
    // MARK: - Show & Hide
    func show(_ animated: Bool) {
        assert(Thread.isMainThread, "DXProgressHUD needs to be accessed on the main thread.")
        useAnimation = animated
        if graceTime > 0.0 {
            let newGraceTimer: Timer = Timer(timeInterval: graceTime, target: self, selector: #selector(handleGraceTimer), userInfo: nil, repeats: false)
            RunLoop.current.add(newGraceTimer, forMode: RunLoopMode.commonModes)
            graceTimer = newGraceTimer
        }
            // ... otherwise show the HUD imediately
        else {
            self.showUsingAnimation(useAnimation)
        }
    }
    
    func hide(_ animated: Bool) {
        assert(Thread.isMainThread, "DXProgressHUD needs to be accessed on the main thread.")
        useAnimation = animated
        // If the minShow time is set, calculate how long the hud was shown,
        // and pospone the hiding operation if necessary
        if let showStarted = showStarted, minShowTime > 0.0 {
            let interv: TimeInterval = Date().timeIntervalSince(showStarted)
            guard interv >= minShowTime else {
                minShowTimer = Timer(timeInterval: minShowTime - interv, target: self, selector:#selector(handleMinShowTimer) , userInfo: nil, repeats: false)
                return
            }
        }
        //        if minShowTime > 0.0 && showStarted != nil {
        //            let interv: NSTimeInterval = NSDate().timeIntervalSinceDate(showStarted!)
        //            if interv < minShowTime {
        //                minShowTimer = NSTimer(timeInterval: minShowTime - interv, target: self, selector: "handleMinShowTimer:", userInfo: nil, repeats: false)
        //                return
        //            }
        //        }
        // ... otherwise hide the HUD immediately
        self.hideUsingAnimation(useAnimation)
    }
    
    func hide(_ animated: Bool, afterDelay delay: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.hideDelayed(animated)
        }
    }
    
    func hideDelayed(_ animated: Bool) {
        self.hide(animated)
    }
    
    // MARK: - Timer callbacks
    @objc func handleGraceTimer(_ theTimer: Timer) {
        // Show the HUD only if the task is still running
        if taskInprogress {
            self.showUsingAnimation(useAnimation)
        }
    }
    
    @objc fileprivate func handleMinShowTimer(_ theTimer: Timer) {
        self.hideUsingAnimation(useAnimation)
    }
    
    // MARK: - View Hierrarchy
    override func didMoveToSuperview() {
        self.updateForCurrentOrientationAnimaged(false)
    }
    
    // MARK: -  Internal show & hide operations
    fileprivate func showUsingAnimation(_ animated: Bool) {
        // Cancel any scheduled hideDelayed: calls
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.setNeedsDisplay()
        
        if animated && animationType == .zoomIn {
            self.transform = rotationTransform.concatenating(CGAffineTransform(scaleX: 0.5, y: 0.5))
        } else if animated && animationType == .zoomOut {
            self.transform = rotationTransform.concatenating(CGAffineTransform(scaleX: 1.5, y: 1.5))
        }
        self.showStarted = Date()
        //Fade in
        if animated {
            UIView.beginAnimations(nil, context:nil)
            UIView.setAnimationDuration(0.30)
            self.alpha = 1.0
            if animationType == .zoomIn || animationType == .zoomOut {
                self.transform = rotationTransform
            }
            UIView.commitAnimations()
        } else {
            self.alpha = 1.0
        }
    }
    
    fileprivate func hideUsingAnimation(_ animated: Bool) {
        // Fade out
        if animated && showStarted != nil {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.30)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDidStop(#selector(animationFinished(_:finished:context:)))
            // 0.02 prevents the hud from passing through touches during the animation the hud will get completely hidden
            // in the done method
            if animationType == .zoomIn {
                self.transform = rotationTransform.concatenating(CGAffineTransform(scaleX: 1.5, y: 1.5))
            } else if animationType == .zoomOut {
                self.transform = rotationTransform.concatenating(CGAffineTransform(scaleX: 0.5, y: 0.5))
            }
            
            self.alpha = 0.02
            UIView.commitAnimations()
        } else {
            self.alpha = 0.0
            self.done()
        }
        self.showStarted = nil
    }
    
    @objc func animationFinished(_ animationID: String?, finished: Bool, context: UnsafeMutableRawPointer) {
        self.done()
    }
    
    fileprivate func done() {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        
        self.alpha = 0.0
        if removeFromSuperViewOnHide {
            self.removeFromSuperview()
        }
        
        if completionBlock != nil {
            self.completionBlock!()
            self.completionBlock = nil
        }
        
        delegate?.hudWasHidden(self)
    }
    
    // MARK: - Threading
    func showWhileExecuting(_ closures: @escaping DXProgressHUDExecutionClosures, animated: Bool) {
        // Launch execution in new thread
        taskInprogress = true
        closureForExecution = closures
        
        Thread.detachNewThreadSelector(#selector(launchExecution), toTarget: self, with: nil)
        
        // Show HUD view
        self.show(animated)
    }
    
    func showAnimated(_ animated: Bool, whileExecutingBlock block: @escaping ()->()) {
        self.showAnimated(animated, whileExecutingBlock: block, onQueue: DispatchQueue.global(), completionBlock: nil)
        //self.showAnimated(animated, whileExecutingBlock: block, onQueue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), completionBlock: nil)
    }
    
    func showAnimated(_ animated: Bool, whileExecutingBlock block: @escaping ()->(), completionBlock completion: DXProgressHUDCompletionBlock?) {
        self.showAnimated(animated, whileExecutingBlock: block, onQueue: DispatchQueue.global(), completionBlock: completion)
        //self.showAnimated(animated, whileExecutingBlock: block, onQueue: DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default), completionBlock: completion)
    }
    
    func showAnimated(_ animated: Bool, whileExecutingBlock block: @escaping ()->(), onQueue queue: DispatchQueue) {
        self.showAnimated(animated, whileExecutingBlock: block, onQueue: queue, completionBlock: nil)
    }
    
    func showAnimated(_ animated: Bool, whileExecutingBlock block: @escaping ()->(), onQueue queue: DispatchQueue, completionBlock completion: DXProgressHUDCompletionBlock?) {
        taskInprogress = true
        self.completionBlock = completion
        queue.async(execute: { () -> Void in
            block()
            DispatchQueue.main.async(execute: { () -> Void in
                self.cleanUp()
            })
        })
        self.show(animated)
    }
    
    @objc func launchExecution() {
        autoreleasepool { () -> () in
            closureForExecution!()
            DispatchQueue.main.async(execute: { () -> Void in
                self.cleanUp()
            })
        }
    }
    
    func cleanUp() {
        taskInprogress = false
        closureForExecution = nil
        
        self.hide(useAnimation)
    }
    
    // MARK: - UI
    fileprivate func setupLabels() {
        label = UILabel(frame: self.bounds)
        label.adjustsFontSizeToFitWidth = false
        label.textAlignment = NSTextAlignment.center
        label.isOpaque = false
        label.numberOfLines = 0
        label.backgroundColor = UIColor.clear
        label.textColor = labelColor
        label.font = labelFont
        label.text = labelText
        self.addSubview(label)
        
        detailsLabel = UILabel(frame: self.bounds)
        detailsLabel.font = detailsLabelFont
        detailsLabel.adjustsFontSizeToFitWidth = false
        detailsLabel.textAlignment = NSTextAlignment.center
        detailsLabel.isOpaque = false
        detailsLabel.backgroundColor = UIColor.clear
        detailsLabel.textColor = detailsLabelColor
        detailsLabel.numberOfLines = 0
        detailsLabel.font = detailsLabelFont
        detailsLabel.text = detailsLabelText
        self.addSubview(detailsLabel)
    }
    
    fileprivate func updateIndicators() {
        let isActivityIndicator: Bool = self.indicator is UIActivityIndicatorView
        let isRoundIndicator: Bool = self.indicator is DXRoundProgressView
        let isIndeterminatedRoundIndicator: Bool = self.indicator is DXIndeterminatedRoundProgressView

        switch self.mode {
        case .indeterminate:
            let activityIndicator = isActivityIndicator ? (self.indicator as! UIActivityIndicatorView) : UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
            
            if !isActivityIndicator {
                indicator?.removeFromSuperview()
                indicator = activityIndicator
                
                activityIndicator.startAnimating()
                addSubview(activityIndicator)
            }
            activityIndicator.color = activityIndicatorColor
            
        case .annularIndeterminate:
            if !isIndeterminatedRoundIndicator {
                indicator?.removeFromSuperview()
                indicator = DXIndeterminatedRoundProgressView()
                addSubview(self.indicator!)
            }
            
        case .determinateHorizontalBar:
            indicator?.removeFromSuperview()
            indicator = DXBarProgressView()
            self.addSubview(self.indicator!)
            
        case .determinate:
            fallthrough
            
        case .annularDeterminate:
            if !isRoundIndicator {
                DispatchQueue.main.async {
                    self.indicator?.removeFromSuperview()
                    self.indicator = DXRoundProgressView()
                    self.addSubview(self.indicator!)
                    
                    if self.mode == DXProgressHUDMode.annularDeterminate {
                        (self.indicator as! DXRoundProgressView).annular = true
                    }
                }
            }

        case .customView where self.customView != self.indicator:
            indicator?.removeFromSuperview()
            indicator = self.customView
            if let cator = indicator {
                addSubview(cator)
            }
        case .text:
            indicator?.removeFromSuperview()
            indicator = nil
            
        default:
            break
        }
        indicator?.translatesAutoresizingMaskIntoConstraints = false
        
       // indicator?.setValue(progress, forKeyPath: "progress")
        
    }
    
    // MARK: - Notificaiton
    fileprivate func registerForNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(statusBarOrientationDidChange), name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    fileprivate func unregisterFromNotifications() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation, object: nil)
    }
    
    @objc func statusBarOrientationDidChange(_ notification: Notification) {
        if let _ = self.superview {
            self.updateForCurrentOrientationAnimaged(true)
        }
    }
    
    fileprivate func updateForCurrentOrientationAnimaged(_ animated: Bool) {
        // Stay in sync with the superview in any case
        if let superView = self.superview {
            self.bounds = superView.bounds
            self.setNeedsDisplay()
        }
    }
    
    // MARK: - Layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Entirely cover the parent view
        if let parent = self.superview {
            self.frame = parent.bounds
        }
        let bounds: CGRect = self.bounds;
        
        // Determine the total widt and height needed
        let maxWidth: CGFloat = bounds.size.width - 4 * CGFloat(margin)
        var totalSize: CGSize = CGSize.zero
        
        
        var indicatorF: CGRect = ((indicator != nil) ? indicator!.bounds : CGRect.zero)
        indicatorF.size.width = min(indicatorF.size.width, maxWidth)
        totalSize.width = max(totalSize.width, indicatorF.size.width)
        totalSize.height += indicatorF.size.height
        
        var labelSize: CGSize = MB_TEXTSIZE(label.text, font: label.font)
        labelSize.width = min(labelSize.width, maxWidth)
        totalSize.width = max(totalSize.width, labelSize.width)
        totalSize.height += labelSize.height
        if labelSize.height > 0.0 && indicatorF.size.height > 0.0 {
            totalSize.height += kPadding
        }
        
        let remainingHeight: CGFloat = bounds.size.height - totalSize.height - kPadding - 4 * CGFloat(margin)
        let maxSize: CGSize = CGSize(width: maxWidth, height: remainingHeight)
        let detailsLabelSize: CGSize = MB_MULTILINE_TEXTSIZE(detailsLabel.text, font: detailsLabel.font, maxSize: maxSize, mode: detailsLabel.lineBreakMode)
        totalSize.width = max(totalSize.width, detailsLabelSize.width)
        totalSize.height += detailsLabelSize.height
        if detailsLabelSize.height > 0.0 && (indicatorF.size.height > 0.0 || labelSize.height > 0.0) {
            totalSize.height += kPadding
        }
        
        totalSize.width += 2 * CGFloat(margin)
        totalSize.height += 2 * CGFloat(margin)
        
        // Position elements
        var yPos: CGFloat = round(((bounds.size.height - totalSize.height) / 2)) + CGFloat(margin) + CGFloat(yOffset)
        let xPos: CGFloat = CGFloat(xOffset)
        
        if mode == .text {
            switch position {
            case .center:
                indicatorF.origin.y = yPos
            case .bottom:
                indicatorF.origin.y = yPos*2
            }
        }else{
            indicatorF.origin.y = yPos
        }
        
        
        indicatorF.origin.x = round((bounds.size.width - indicatorF.size.width) / 2) + xPos
        indicator?.frame = indicatorF
        yPos += indicatorF.size.height
        
        
        var labelF: CGRect = CGRect.zero
   
        if mode == .text {
            switch position {
            case .center:
                if labelSize.height > 0.0 && indicatorF.size.height > 0.0 {
                    yPos += kPadding
                }
                labelF.origin.y = yPos
            case .bottom:
                labelF.origin.y = yPos*2 - 2*kBottomPadding
            }
        }else{
            if labelSize.height > 0.0 && indicatorF.size.height > 0.0 {
                yPos += kPadding
            }
            labelF.origin.y = yPos
        }
        
        
        labelF.origin.x = round((bounds.size.width - labelSize.width) / 2) + xPos
        labelF.size = labelSize
        label.frame = labelF
        yPos += labelF.size.height
        
        
        var detailsLabelF: CGRect = CGRect.zero
        if mode == .text {
            switch position {
            case .center:
                if detailsLabelSize.height > 0.0 && (indicatorF.size.height > 0.0 || labelSize.height > 0.0) {
                    yPos += kPadding
                }
                detailsLabelF.origin.y = yPos
            case .bottom:
                detailsLabelF.origin.y = yPos*2 - 2*kBottomPadding
            }
        }else{
            if detailsLabelSize.height > 0.0 && (indicatorF.size.height > 0.0 || labelSize.height > 0.0) {
                yPos += kPadding
            }
            detailsLabelF.origin.y = yPos
        }
        
        
        detailsLabelF.origin.x = round((bounds.size.width - detailsLabelSize.width) / 2) + xPos
        detailsLabelF.size = detailsLabelSize
        detailsLabel.frame = detailsLabelF
        
        // Enforce minsize and quare rules
        if square {
            let maxWH: CGFloat = max(totalSize.width, totalSize.height);
            if maxWH <= bounds.size.width - 2 * CGFloat(margin) {
                totalSize.width = maxWH
            }
            if maxWH <= bounds.size.height - 2 * CGFloat(margin) {
                totalSize.height = maxWH
            }
        }
        if totalSize.width < minSize.width {
            totalSize.width = minSize.width
        }
        if totalSize.height < minSize.height {
            totalSize.height = minSize.height
        }
        
        size = totalSize
    }
    
    // MARK: - BG Drawing
    override func draw(_ rect: CGRect) {
        let context: CGContext = UIGraphicsGetCurrentContext()!
        UIGraphicsPushContext(context)
        
        if self.dimBackground {
            //Gradient colours
            let gradLocationsNum: size_t = 2
            let gradLocations: [CGFloat] = [0.0, 1.0]
            let gradColors: [CGFloat] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.75]
            let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient: CGGradient = CGGradient(colorSpace: colorSpace, colorComponents: gradColors, locations: gradLocations, count: gradLocationsNum)!
            //Gradient center
            let gradCenter: CGPoint = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
            //Gradient radius
            let gradRadius: CGFloat = min(self.bounds.size.width , self.bounds.size.height)
            //Gradient draw
            context.drawRadialGradient(gradient, startCenter: gradCenter, startRadius: 0, endCenter: gradCenter, endRadius: gradRadius,options: CGGradientDrawingOptions.drawsAfterEndLocation)
        }
        
        // Set background rect color
        if let color = self.color {
            context.setFillColor(color.cgColor)
        } else {
            context.setFillColor(gray: 0.0, alpha: CGFloat(opacity))
        }
        
        
        // Center HUD
        let allRect: CGRect = self.bounds
        
        var boxY : CGFloat = round((allRect.size.height - size.height) / 2) + CGFloat(self.yOffset)
        
        if mode == .text {
            switch position {
            case .center:
                boxY = round((allRect.size.height - size.height) / 2) + CGFloat(self.yOffset)
            case .bottom:
                boxY = boxY*2 - kBottomPadding
            }
        }

        // Draw rounded HUD backgroud rect
        let boxRect: CGRect = CGRect(x: round((allRect.size.width - size.width) / 2) + CGFloat(self.xOffset), y: boxY, width: size.width, height: size.height)
        let radius = cornerRadius
        context.beginPath()
        context.move(to: CGPoint(x: boxRect.minX + CGFloat(radius), y: boxRect.minY))
        context.addArc(center: CGPoint(x:boxRect.maxX - CGFloat(radius),y:boxRect.minY + CGFloat(radius)), radius: CGFloat(radius), startAngle: 3 * CGFloat(Double.pi) / 2, endAngle: 0, clockwise: false)

        context.addArc(center: CGPoint(x:boxRect.maxX - CGFloat(radius),y:boxRect.maxY - CGFloat(radius)), radius: CGFloat(radius), startAngle: 0, endAngle: CGFloat(Double.pi) / 2, clockwise: false)

        context.addArc(center: CGPoint(x:boxRect.minX + CGFloat(radius),y:boxRect.maxY - CGFloat(radius)), radius: CGFloat(radius), startAngle: CGFloat(Double.pi) / 2, endAngle: CGFloat(Double.pi), clockwise: false)

        context.addArc(center: CGPoint(x:boxRect.minX + CGFloat(radius),y:boxRect.minY + CGFloat(radius)), radius: CGFloat(radius), startAngle: CGFloat(Double.pi), endAngle: 3 * CGFloat(Double.pi) / 2, clockwise: false)

        context.closePath()
        context.fillPath()
        
        UIGraphicsPopContext()
    }

}
