//
//  DXConfig.swift
//  DXProgressHUD_Swift
//
//  Created by fashion on 2018/8/11.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

//MARK: - DXProgressHUDDelegate
public protocol DXProgressHUDDelegate {

}
// 可选方法
public extension DXProgressHUDDelegate {
    func hudWasHidden(_ hud: DXProgressHUD){
        
    }
}

//MARK: - ENUM
public  enum DXProgressHUDMode: Int {
    /// 不确定的
    case indeterminate = 0
    /// 环形不确定的
    case annularIndeterminate
    /// 固定的
    case determinate
    case determinateHorizontalBar
    case annularDeterminate
    case customView
    case text
}

public enum DXProgressHUDAnimation: Int {
    case fade = 0
    case zoom
    case zoomOut
    case zoomIn
}

/// 仅仅在only text 模式下有效
public enum DXProgressPosition: Int {
    case center = 0
    case bottom
}

//MARK: - Global var and func
public typealias DXProgressHUDCompletionBlock = () -> Void
public typealias DXProgressHUDExecutionClosures = () -> Void


let kPadding: CGFloat = 4.0
let kLabelFontSize: CGFloat = 16.0
let kDetailsLabelFontSize: CGFloat = 12.0
let kBottomPadding: CGFloat = 10.0

public func MB_TEXTSIZE(_ text: String?, font: UIFont) -> CGSize {
    guard let textTemp = text, textTemp.count > 0 else {
        return CGSize.zero
    }
    
    return textTemp.size(withAttributes: [NSAttributedString.Key.font: font])
}

public func MB_MULTILINE_TEXTSIZE(_ text: String?, font: UIFont, maxSize: CGSize, mode: NSLineBreakMode) -> CGSize {
    guard let textTemp = text, textTemp.count > 0 else {
        return CGSize.zero
    }
    
    return textTemp.boundingRect(with: maxSize, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil).size
}
