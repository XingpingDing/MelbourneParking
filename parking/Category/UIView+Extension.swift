//
//  UIView+Extension.swift
//  parking
//
//  Created by Xingping Ding on 2018/4/25.
//  Copyright © 2018年 Xingping Ding. All rights reserved.
//

import UIKit
import MBProgressHUD

let KeyWindow : UIWindow = UIApplication.shared.keyWindow!

private var HUDKey = "VRHUD"
extension UIView
{
    var hud : MBProgressHUD?
    {
        get{
            return objc_getAssociatedObject(self, &HUDKey) as? MBProgressHUD
        }
        set{
            objc_setAssociatedObject(self, &HUDKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    // Show hud in view with content
    func showHudInView(view: UIView, content: String){
        let HUD = MBProgressHUD(view: view)
        HUD.label.text = content
        //        HUD.margin = 10.0
        view.addSubview(HUD)
        HUD.show(animated: true)
        hud = HUD
    }
    
    // Show hud in view
    func showHudInView(view: UIView){
        let HUD = MBProgressHUD(view: view)
        //        HUD.margin = 10.0
        view.addSubview(HUD)
        HUD.show(animated: true)
        hud = HUD
    }
    
    // Show text hud in keywindow
    func showTextHud(content: String) {
        let view = KeyWindow
        let HUD = MBProgressHUD(view: view)
        view.addSubview(HUD)
        HUD.isUserInteractionEnabled = false
        HUD.mode = .text
        HUD.label.text = content
        HUD.show(animated: true)
        HUD.removeFromSuperViewOnHide = false
        HUD.hide(animated: true, afterDelay: 2)
        hud = HUD
    }
    
    // Hide hud
    func hideHud() {
        if (hud != nil) {
            hud!.hide(animated: true)
        }
    }
}
