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
    var isLikedPost = false;
    
    
    func initCell() {
        self.decodeFileMetadata();
        self.displayPetImage();
        self.displayPostContents();
        print(self.fileAttachmentList);
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
        self.authorAndPetNameLabel.text = "\(self.post!.author.nickname) 님의 \(self.post!.pet.name)";
        self.contentTextView.isScrollEnabled = false;
        self.contentTextView.text = self.post!.contents;
        self.contentTextView.sizeToFit();
        self.postTagLabel.text = self.post!.serializedHashTags;
        self.attachmentFileBtn.setTitle("첨부파일\(self.fileAttachmentList.count)개", for: .normal);
        PostUtil.reqHttpFetchLike(postId: self.post!.id, sender: self.senderVC!, resHandler: self.displayPostLikes);
        self.commentBtn.setTitle("댓글 X개", for: .normal);
    }
    
    func displayPostLikes(res: DataResponse<LikeFetchDto, AFError>) {
        let loginUserDetail =  try! JSONSerialization.jsonObject(with: UserDefaults.standard.object(forKey: "loginAccountDetail") as! Data, options: []) as! [String: Any];
        self.likeBtn.setTitle("좋아요 \(res.value!.likedCount)개", for: .normal);
        self.isLikedPost = res.value!.likedAccountIdList.contains(loginUserDetail["id"] as! Int);
    }
    
    // Action Methods
    @IBAction open func attachementFileBtnOnClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: "첨부파일 목록", message: "다운로드 받을 파일을 선택합니다", preferredStyle: .actionSheet);
        for (index, file) in self.fileAttachmentList.enumerated() {
            alertController.addAction(UIAlertAction(title: file.name, style: .default) {
                (action) in
                PostUtil.reqHttpFetchPostFile(postId: self.post!.id, index: index, sender: self.senderVC!) {
                    (res) in
                    if (res.data != nil) {
                        let activityViewController = UIActivityViewController(activityItems: ["첨부파일 저장 및 공유", res.data!], applicationActivities: nil);
                        self.senderVC!.present(activityViewController, animated: true);
                    }
                }
            })
        }
        alertController.addAction(UIAlertAction(title: "닫기", style: .cancel, handler: nil));
        self.senderVC!.present(alertController, animated: true);
    }
    @IBAction open func commentBtnOnClick(_ sender: UIButton) {
    }
    @IBAction open func likeBtnOnClick(_ sender: UIButton) {
        if (self.isLikedPost) {
            PostUtil.reqHttpUnLike(postId: self.post!.id, sender: self.senderVC!) {
                (res) in
                PostUtil.reqHttpFetchLike(postId: self.post!.id, sender: self.senderVC!, resHandler: self.displayPostLikes);
            }
        } else {
            PostUtil.reqHttpLike(postId: self.post!.id, sender: self.senderVC!) {
                (res) in
                PostUtil.reqHttpFetchLike(postId: self.post!.id, sender: self.senderVC!, resHandler: self.displayPostLikes);
            }
        }
    }
}
