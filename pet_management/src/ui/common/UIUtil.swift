//
//  UIAlert.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/19.
//

import UIKit

class UIUtil {
    // func makeSimplePopup
    // Param - title: String - popup title
    // Param - message: String - the message which is displayed at popup
    // Param - onClose: ((UIAlertAction) -> Void)? - operation to do when popup closes
    // Return UIAlertController
    // Make simple popup alert controller
    static func makeSimplePopup(title: String?, message: String, onClose: ((UIAlertAction) -> Void)?) -> UIAlertController {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert);
        let approveAction = UIAlertAction(title: "확인", style: UIAlertAction.Style.default, handler: onClose);
        alertController.addAction(approveAction);
        return alertController;
    }
    
    // func showToast
    // Param - message: String - the message which is displayed at toast
    // Return Void
    // Show toast message with given string
    static func showToast(view: UIView, message : String) {
        // Toast messsage view position setting
        let width_variable:CGFloat = 10;
        let toastLabel = UILabel(frame: CGRect(x: width_variable, y: view.frame.size.height-100, width: view.frame.size.width-2*width_variable, height: 35));
        
        // Toast message style setting
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6);
        toastLabel.textColor = UIColor.white;
        toastLabel.textAlignment = .center;
        toastLabel.font = UIFont(name: "Montserrat-Light", size: 10.0)
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        
        // Toast message appear
        view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
}
