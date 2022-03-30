//
//  UIInfomationVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/30.
//

import UIKit;

class UIInfomationVC: UIViewController {
    @IBOutlet weak var infoTextView: UITextView!;
    
    var infoTextString: String?;
    
    override func viewDidLoad() {
        if (self.infoTextString != nil) {
            self.infoTextView.text = self.infoTextString;
        }
    }
}
