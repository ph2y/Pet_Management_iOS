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
    
    var comment: Comment?;
    
    func initCell() {
        self.displayCommentContents();
    }
    
    func displayCommentContents() {
        self.authorNameLabel.text = self.comment!.author.nickname;
        self.contentTextView.isScrollEnabled = false;
        self.contentTextView.text = self.comment!.contents;
        self.contentTextView.sizeToFit();
        self.replyButton.setTitle("댓답글 \(self.comment!.childCommentCnt)개", for: .normal);
    }
    
    
    @IBAction func menuButtonOnClick(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet);
        let accountDetail = try! JSONSerialization.jsonObject(with: UserDefaults.standard.object(forKey: "loginAccountDetail") as! Data, options: []) as! [String: Any];
        if (self.comment!.author.id == accountDetail["id"] as! Int) {
            alertController.addAction(UIAlertAction(title: "수정", style: .default) {
                (sender) in
                
            });
            alertController.addAction(UIAlertAction(title: "삭제", style: .destructive) {
                (sender) in
                CommentUtil.reqHttpDeleteComment(commentId: self.comment!.id, sender: self.senderVC!) {
                    (res) in
                    self.delegate!.refreshComment();
                }
            });
        } else {
            alertController.addAction(UIAlertAction(title: "게시물 신고", style: .destructive) {
                (sender) in
            });
        }
        alertController.addAction(UIAlertAction(title: "닫기", style: .cancel));
        self.senderVC!.present(alertController, animated: true);
    }
    @IBAction func replyButtonOnClick(_ sender: UIButton) {
        self.senderVC!.performSegue(withIdentifier: "replyToCommentSegue", sender: self.senderVC);
    }
}
