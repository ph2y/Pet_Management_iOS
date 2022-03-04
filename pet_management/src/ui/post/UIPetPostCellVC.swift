//
//  UIPetPostCellVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/16.
//

import UIKit;
import Alamofire;

protocol UIPetPostCellDelegate: AnyObject {
    func presentPopup(alert: UIAlertController);
}

class UIPetPostCellVC: UITableViewCell {
    @IBOutlet open weak var petImage: UIImageView!;
    @IBOutlet open weak var authorAndPetNameLabel: UILabel!;
    @IBOutlet open weak var contentTextView: UITextView!;
    @IBOutlet open weak var postTagLabel: UILabel!;
    @IBOutlet open weak var attachmentFileBtn: UIButton!;
    @IBOutlet open weak var commentBtn: UIButton!;
    @IBOutlet open weak var likeBtn: UIButton!;

    let decoder = JSONDecoder();
    weak var delegate: UIPetPostCellDelegate?;
    
    var senderVC: UIViewController?;
    var indexPath: IndexPath?;
    var post: Post?;
    var fileAttachmentList: [Attachment] = [];
    
    
    func initCell() {
        self.decodeFileMetadata();
        self.displayPetImage();
        self.displayPostContents();
    }
    
    func decodeFileMetadata() {
        if (self.post?.fileAttachments?.data(using: .utf8) != nil) {
            self.fileAttachmentList = try! decoder.decode([Attachment].self, from: self.post!.fileAttachments!.data(using: .utf8)!);
        }
    }
    
    func displayPetImage() {
        if (post!.pet.photoUrl != nil) {
            PetUtil.reqHttpFetchPetPhoto(petId: post!.pet.id, sender: self.senderVC!) {
                (petPhoto) in
                self.petImage.image = petPhoto;
            };
        } else {
            self.petImage.image = UIImage(named: "ICBaselinePets60WithPadding")!;
        }
    }
    
    func displayPostContents() {
        self.authorAndPetNameLabel.text = "\(post!.author.nickname) 님의 \(self.post!.pet.name)";
        self.contentTextView.isScrollEnabled = false;
        self.contentTextView.text = self.post!.contents;
        self.contentTextView.sizeToFit();
        self.postTagLabel.text = self.post!.serializedHashTags;
        self.attachmentFileBtn.setTitle("첨부파일\(self.fileAttachmentList.count)개", for: .normal);
        self.reqHttpFetchLike();
        self.commentBtn.setTitle("댓글 X개", for: .normal);
    }
    
    func reqHttpFetchLike() {
        let reqApi = "like/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["postId"] = String(self.post!.id);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: LikeFetchDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.delegate?.presentPopup(alert: APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription));
                return;
            }
            guard (res.value?._metadata.status == true) else {
                self.delegate?.presentPopup(alert: APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message));
                self.reqHttpUnLike();
                return;
            }
            
            self.likeBtn.setTitle("좋아요 \(res.value!.likedCount)개", for: .normal);
        }
    }
    
    func reqHttpLike() {
        let reqApi = "like/create";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["postId"] = String(self.post!.id);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: LikeCreateDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.delegate?.presentPopup(alert: APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription));
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                self.delegate?.presentPopup(alert: APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message));
                self.reqHttpUnLike();
                return;
            }
            self.reqHttpFetchLike();
        }
    }
    
    func reqHttpUnLike() {
        let reqApi = "like/delete";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["postId"] = String(self.post!.id);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: LikeDeleteDto.self) {
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
            self.reqHttpFetchLike();
        }
    }
    
    // Action Methods
    @IBAction open func attachementFileBtnOnClick(_ sender: UIButton) {
    }
    @IBAction open func commentBtnOnClick(_ sender: UIButton) {
    }
    @IBAction open func likeBtnOnClick(_ sender: UIButton) {
        self.reqHttpLike();
    }
}
