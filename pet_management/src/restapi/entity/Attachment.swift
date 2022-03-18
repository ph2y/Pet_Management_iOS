//
//  File.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/16.
//

import Photos;
import UIKit

struct Attachment: Decodable {
    var name: String;
    var size: Int;
    var entity: String;
    var type: String;
    var url: String;
}

class AttachmentUtil {
    static func getImageFromPHAsset(asset: PHAsset, size: CGSize? = CGSize(width: 75, height: 75)) -> UIImage {
        let imageManager = PHImageManager.default();
        let option = PHImageRequestOptions();
        var resultImage = UIImage();
        option.isSynchronous = true;
        
        
        imageManager.requestImage(for: asset, targetSize: CGSize(width: 75, height: 75), contentMode: .aspectFit, options: option) {
            (result, info) in
            resultImage = result ?? UIImage();
        }
        return resultImage;
    }
}
