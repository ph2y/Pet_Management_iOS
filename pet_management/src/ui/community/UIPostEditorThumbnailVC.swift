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
    let imageManager = PHImageManager.default();
    let option = PHImageRequestOptions();
    var delegate: UIPostEditorDelegate?;
    var thumbnailAsset: PHAsset?;
    
    override func viewDidLoad() {
        option.isSynchronous = true;
        
        if (self.thumbnailAsset != nil) {
            imageManager.requestImage(for: self.thumbnailAsset!, targetSize: CGSize(width: 75, height: 75), contentMode: .aspectFit, options: option) {
                (result, info) in
                self.thumbnailImageView.image = result!;
            }
        }
    }
    
    // Action Methods
    @IBAction func removeImageButtonOnClick(_ sender: UIButton) {
        if (self.delegate != nil) {
            self.delegate!.removeAttachedPhotoAsset(sender: self);
        }
    }
}
