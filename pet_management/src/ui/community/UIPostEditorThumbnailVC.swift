//
//  UIPostEditorThumbnailVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/10.
//

import UIKit;
import Photos;

class UIPostEditorThumbnailVC: UIViewController {
    @IBOutlet weak var thumbnailImageView: UIImageView!;
    
    var delegate: UIPostEditorDelegate?;
    var thumbnail: UIImage?;
    var asset: PHAsset?;
    
    override func viewDidLoad() {
        if (self.thumbnail != nil) {
            self.thumbnailImageView.image = thumbnail;
        }
    }
    
    // Action Methods
    @IBAction func removeImageButtonOnClick(_ sender: UIButton) {
        if (self.delegate != nil) {
            self.delegate!.removeAttachedPhotoAsset(sender: self);
        }
    }
}
