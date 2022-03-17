//
//  UIPostCommentCell.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/16.
//

import UIKit;

protocol UIPostCommentCellDelegate: AnyObject {
    func refreshComment();
}

class UIPostCommentCell: UITableViewCell {
    @IBOutlet weak var authorNameLabel: UILabel!;
    @IBOutlet weak var contentTextView: UITextView!;
    @IBOutlet weak var replyButton: UIButton!;
    
    weak var delegate: UIPostCommentCellDelegate?;
    var senderVC: UIViewController?;
    var indexPath: IndexPath?;
    var comment: Comment?;
    
    func initCell() {
        self.displayCommentContents();
    }
    
    func displayCommentContents() {
        self.authorNameLabel.text = self.comment!.author.nickname;
        self.contentTextView.isScrollEnabled = false;
        self.contentTextView.text = self.comment!.contents;
        self.contentTextView.sizeToFit();
        if (self.replyButton != nil) {
            self.replyButton.setTitle("댓답글 \(self.comment!.childCommentCnt)개", for: .normal);
        }
    }
    
    
    @IBAction func menuButtonOnClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        let accountDetail = try! JSONSerialization.jsonObject(with: UserDefaults.standard.object(forKey: "loginAccountDetail") as! Data, options: []) as! [String: Any];
        if (self.comment!.author.id == accountDetail["id"] as! Int) {
            alertController.addAction(UIAlertAction(title: "수정", style: .default) {
                (sender) in
                let commentEditorAlert = UIAlertController(title: "댓글/댓답글 수정", message: "", preferredStyle: .alert);
                
                commentEditorAlert.addTextField() {
                    (textfield) in
                    textfield.placeholder = "댓글/댓답글 내용을 입력하세요";
                    textfield.text = self.comment!.contents;
                };
                commentEditorAlert.addAction(UIAlertAction(title: "수정", style: .default) {
                    (sender) in
                    guard (commentEditorAlert.textFields != nil && !commentEditorAlert.textFields![0].text!.isEmpty) else {
                        self.senderVC!.present(UIUtil.makeSimplePopup(title: "댓글/댓답글 수정 에러", message: "내용을 입력하세요", onClose: nil), animated: true);
                        return;
                    }
                    let newCommentContents = commentEditorAlert.textFields![0].text!;
                    CommentUtil.reqHttpUpdateComment(commentId: self.comment!.id, contents: newCommentContents, sender: self.senderVC!) {
                        (res) in
                        self.delegate!.refreshComment();
                    }
                });
                commentEditorAlert.addAction(UIAlertAction(title: "취소", style: .cancel));
                self.senderVC!.present(commentEditorAlert, animated: true);
            });
            alertController.addAction(UIAlertAction(title: "삭제", style: .destructive) {
                (sender) in
                CommentUtil.reqHttpDeleteComment(commentId: self.comment!.id, sender: self.senderVC!) {
                    (res) in
                    self.delegate!.refreshComment();
                    
                    // Unwind to comment page if parent comment deleted from replyView
                    if (self.replyButton != nil && self.replyButton.isEnabled == false) {
                        self.senderVC!.performSegue(withIdentifier: "ViewReplyUnwindSegue", sender: self.senderVC!);
                    }
                }
            });
        } else {
            alertController.addAction(UIAlertAction(title: "댓글/댓답글 신고", style: .destructive) {
                (sender) in
                CommentUtil.reqHttpReportComment(commentId: self.comment!.id, sender: self.senderVC!) {
                    (res) in
                    self.senderVC!.present(UIUtil.makeSimplePopup(title: "댓글/댓답글 신고", message: "댓글/댓답글 신고가 성공적으로 접수되었습니다.", onClose: nil), animated: true);
                }
            });
        }
        alertController.addAction(UIAlertAction(title: "닫기", style: .cancel));
        self.senderVC!.present(alertController, animated: true);
    }
    @IBAction func replyButtonOnClick(_ sender: UIButton) {
        self.senderVC!.performSegue(withIdentifier: "ReplyViewSegue", sender: self.indexPath);
    }
}
