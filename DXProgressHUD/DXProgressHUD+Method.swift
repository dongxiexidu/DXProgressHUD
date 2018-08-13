//
//  DXProgressHUD+Method.swift
//  DXProgressHUD_Swift
//
//  Created by fashion on 2018/8/11.
//  Copyright © 2018年 shangZhu. All rights reserved.
//

import UIKit

extension DXProgressHUD{

    class func showHUDAddedTo(_ view: UIView, animated: Bool) -> DXProgressHUD {
        let hud: DXProgressHUD = DXProgressHUD(view: view)
        hud.removeFromSuperViewOnHide = true
        view.addSubview(hud)
        hud.show(animated)
        
        return hud
    }
    @objc class func showLoadingHUDAddedTo(_ view: UIView, animated: Bool){
        let hud: DXProgressHUD = DXProgressHUD(view: view)
        hud.removeFromSuperViewOnHide = true
        view.addSubview(hud)
        hud.show(animated)
        
        //        return hud
    }
    
    class func hideHUDForView(_ view: UIView, animated: Bool) -> Bool {
        guard let hud = self.HUDForView(view) else {
            return false
        }
        
        hud.removeFromSuperViewOnHide = true
        hud.hide(animated)
        
        return true
    }
    
    class func hideAllHUDsForView(_ view: UIView, animated: Bool) -> Int {
        let huds = DXProgressHUD.allHUDsForView(view)
        for hud in huds {
            hud.removeFromSuperViewOnHide = true
            hud.hide(animated)
        }
        return huds.count
    }
    @objc class func hideAllLoadingHUDsForView(_ view: UIView, animated: Bool) {
        let huds = DXProgressHUD.allHUDsForView(view)
        for hud in huds {
            hud.removeFromSuperViewOnHide = true
            hud.hide(false)
        }
    }
    
    class func HUDForView(_ view: UIView) -> DXProgressHUD? {
        for subview in Array(view.subviews.reversed()) {
            if subview is DXProgressHUD {
                return subview as? DXProgressHUD
            }
        }
        return nil
    }
    
    class func allHUDsForView(_ view: UIView) -> [DXProgressHUD] {
        var huds: [DXProgressHUD] = []
        for aView in view.subviews {
            if aView is DXProgressHUD {
                huds.append(aView as! DXProgressHUD)
            }
        }
        return huds
    }

}
