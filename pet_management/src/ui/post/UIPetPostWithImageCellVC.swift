//
//  UIPetPostWithImageCellVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/16.
//

import UIKit;
import Alamofire;

class UIPetPostWithImageCellVC: UIPetPostCellVC {
    @IBOutlet weak var pageControl: UIPageControl!;
    @IBOutlet weak var postImageView: UIImageView!;
    
    // TODO: 나중에 복수개의 이미지/동영상 불러오는 로직 짜면서 코드 정리 및 범용화할것
    func reqHttpFetchPostImage(cell: UIPetPostWithImageCellVC, cellIndex: IndexPath, postId: Int, imageIndex: Int) {
        let reqApi = "post/image/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["id"] = String(postId);
        reqBody["index"] = String(imageIndex);
        reqBody["imageType"] = "1";
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseData() {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.delegate?.presentPopup(alert: APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription));
                return;
            }
            guard (res.data != nil) else {
                return;
            }
            var reloadIndexPathList: [IndexPath] = [];
            reloadIndexPathList.append(cellIndex);
            cell.postImageView.image = UIImage(data: res.data!);
        }
    }
    
    func reqHttpFetchPostVideo(cell: UIPetPostWithImageCellVC, cellIndex: IndexPath, postId: Int, imageIndex: Int) {
        let reqApi = "post/image/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["id"] = String(postId);
        reqBody["index"] = String(imageIndex);
        reqBody["imageType"] = "1";
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseData() {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.delegate?.presentPopup(alert: APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription));
                return;
            }
            guard (res.data != nil) else {
                return;
            }
            var reloadIndexPathList: [IndexPath] = [];
            reloadIndexPathList.append(cellIndex);
            cell.postImageView.image = UIImage(data: res.data!);
        }
    }
    
    @objc func swipeForNextImage(_ gesture: UIGestureRecognizer) {
        pageControl.currentPage += 1;
        self.reqHttpFetchPostImage(cell: self, cellIndex: self.indexPath!, postId: self.post!.id, imageIndex: self.pageControl.currentPage);
    }
    
    @objc func swipeForPrevImage(_ gesture: UIGestureRecognizer) {
        pageControl.currentPage -= 1;
        self.reqHttpFetchPostImage(cell: self, cellIndex: self.indexPath!, postId: self.post!.id, imageIndex: self.pageControl.currentPage);
    }
    
    // Action Methods
    @IBAction func pageChanged(_ sender: UIPageControl) {
        self.reqHttpFetchPostImage(cell: self, cellIndex: self.indexPath!, postId: self.post!.id, imageIndex: self.pageControl.currentPage);
    }
}
