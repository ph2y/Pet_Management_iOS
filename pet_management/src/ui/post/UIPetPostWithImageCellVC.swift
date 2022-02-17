//
//  UIPetPostWithImageCellVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/16.
//

import UIKit;
import Alamofire;

class UIPetPostWithImageCellVC: UIPetPostCellVC {
    @IBOutlet weak var postImageView: UIImageView!;
    
    // TODO: 나중에 복수개의 이미지 불러오는 로직 짜면서 코드 정리 및 범용화할것
    func reqHTTPFetchPostImage() {
        let reqApi = "post/image/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["id"] = String(self.post!.id);
        reqBody["index"] = "0";
        reqBody["imageType"] = "0";
        /*
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable() {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.delegate?.presentPopup(alert: APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription));
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                self.delegate?.presentPopup(alert: APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message));
                return;
            }
            self.reqHTTPFetchLike();
         }
         */
    }
}
