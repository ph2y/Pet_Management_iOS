//
//  UIPostWithImageCellVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/16.
//

import UIKit;
import Alamofire;

class UIPostWithImageCellVC: UIPostCellVC {
    @IBOutlet weak var pageControl: UIPageControl!;
    @IBOutlet weak var postImageView: UIImageView!;
    
    var imageAttachementList: [Attachment] = [];
    var videoAttachmentList: [Attachment] = [];
    let decoder = JSONDecoder();
    
    override func initCell() {
        self.imageAttachementList = PostUtil.decodeAttachmentMetadata(attachmentMetadata: self.post!.imageAttachments);
        self.videoAttachmentList = PostUtil.decodeAttachmentMetadata(attachmentMetadata: self.post!.videoAttachments);
        self.setupImageViewGesture();
        self.setupImagePagerControl();
        self.displayPetImage();
        self.displayPostContents();
        PostUtil.reqHttpFetchPostPhoto(postId: self.post!.id, index: 0, sender: self.senderVC!) {
            (res) in
            var reloadIndexPathList: [IndexPath] = [];
            reloadIndexPathList.append(self.indexPath!);
            self.postImageView.image = UIImage(data: res.data!);
        }
    }
    
    func setupImageViewGesture() {
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeForNextImage(_:)));
        swipeLeft.direction = UISwipeGestureRecognizer.Direction.left;
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeForPrevImage(_:)));
        swipeRight.direction = UISwipeGestureRecognizer.Direction.right;
        self.postImageView.addGestureRecognizer(swipeLeft);
        self.postImageView.addGestureRecognizer(swipeRight);
    }
    
    func setupImagePagerControl() {
        self.pageControl.numberOfPages = imageAttachementList.count + videoAttachmentList.count;
        self.pageControl.currentPage = 0;
        self.pageControl.pageIndicatorTintColor = UIColor.lightGray;
        self.pageControl.currentPageIndicatorTintColor = UIColor.black;
    }
    
    // TODO: 나중에 복수개의 이미지/동영상 불러오는 로직 짜면서 코드 정리 및 범용화할것
    func reqHttpFetchPostVideo(cell: UIPostWithImageCellVC, cellIndex: IndexPath, postId: Int, imageIndex: Int) {
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
                self.senderVC!.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
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
        PostUtil.reqHttpFetchPostPhoto(postId: self.post!.id, index: self.pageControl.currentPage, sender: self.senderVC!) {
            (res) in
            var reloadIndexPathList: [IndexPath] = [];
            reloadIndexPathList.append(self.indexPath!);
            self.postImageView.image = UIImage(data: res.data!);
        }
    }
    
    @objc func swipeForPrevImage(_ gesture: UIGestureRecognizer) {
        pageControl.currentPage -= 1;
        PostUtil.reqHttpFetchPostPhoto(postId: self.post!.id, index: self.pageControl.currentPage, sender: self.senderVC!) {
            (res) in
            var reloadIndexPathList: [IndexPath] = [];
            reloadIndexPathList.append(self.indexPath!);
            self.postImageView.image = UIImage(data: res.data!);
        }
    }
    
    // Action Methods
    @IBAction func pageChanged(_ sender: UIPageControl) {
        PostUtil.reqHttpFetchPostPhoto(postId: self.post!.id, index: self.pageControl.currentPage, sender: self.senderVC!) {
            (res) in
            var reloadIndexPathList: [IndexPath] = [];
            reloadIndexPathList.append(self.indexPath!);
            self.postImageView.image = UIImage(data: res.data!);
        }
    }
}
