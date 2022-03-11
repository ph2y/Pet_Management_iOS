//
//  UIPostEditorFileVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/11.
//

import UIKit;

class UIPostEditorFileVC: UIViewController {
    @IBOutlet weak var fileNameLabel: UILabel!;
    
    var delegate: UIPostEditorDelegate?;
    var fileUrl: URL?;
    
    override func viewDidLoad() {
        self.fileNameLabel.text = fileUrl?.lastPathComponent ?? "알 수 없는 파일";
    }
    
    // Action Methods
    @IBAction func removeFileButtonOnClick(_ sender: UIButton) {
        if (self.delegate != nil) {
            self.delegate!.removeAttachedFileAsset(sender: self);
        }
    }
}
