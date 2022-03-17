//
//  UIPostReplyVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/17.
//

import UIKit;
import Alamofire;

class UIPostReplyVC: UIViewController, UIPostCommentCellDelegate {
    @IBOutlet weak var replyTableView: UITableView!;
    @IBOutlet weak var newReplyTextField: UITextField!;
    @IBOutlet weak var replyPublishButton: UIButton!;
    
    var replyList: [Comment] = [];
    var parentComment: Comment?;
    var topReplyId: Int?;
    var loadedPageCnt: Int = 0;
    var isLastPage: Bool = false;
    var isLoading: Bool = true;
    
    override func viewDidLoad() {
        self.replyTableView.delegate = self;
        self.replyTableView.dataSource = self;
        
        CommentUtil.reqHttpFetchComment(parentCommentId: self.parentComment!.id, sender: self, resHandler: self.replyFetch);
        self.initPullToRefresh();
    }
    
    // func initPullToRefresh
    // No Params
    // Return Void
    // Init pull-to-refresh cell
    func initPullToRefresh() {
        let refresh = UIRefreshControl();
        refresh.addTarget(self, action: #selector(self.refreshReply(refresh:)), for: .valueChanged);
        refresh.attributedTitle = NSAttributedString(string: "새로운 댓답글을 로드합니다...");
        self.replyTableView.refreshControl = refresh;
    }
    
    // reference for delegate
    func refreshComment() {
        self.refreshReply();
    }
    
    // func refreshReply
    // No Params
    // Return Void
    // Reset commentTableView
    func refreshReply() {
        self.replyList = [];
        self.topReplyId = nil;
        self.loadedPageCnt = 0;
        self.isLastPage = false;
        self.isLoading = true;
        self.replyTableView.reloadData();
        CommentUtil.reqHttpFetchComment(parentCommentId: self.parentComment!.id, sender: self, resHandler: self.replyFetch);
    }
    
    // objc func refreshReply
    // refresh: UIRefreshControl - The controller class of UIRefresh
    // Return Void
    // Call CommentListTableView & Show refresh animation
    @objc func refreshReply(refresh: UIRefreshControl) {
        self.refreshReply();
        refresh.endRefreshing();
    }
    
    func replyFetch(res: DataResponse<CommentFetchDto, AFError>) {
        self.replyList.append(contentsOf: res.value?.commentList ?? []);
        self.replyTableView.reloadData();
        self.loadedPageCnt += 1;
        self.isLastPage = res.value!.isLast;
        self.isLoading = false;
        
        // Set topReplyId if it was first fetch
        if (self.topReplyId == nil && res.value != nil && !self.replyList.isEmpty) {
            self.topReplyId = res.value!.commentList[0].id;
        }
    }
    
    
    // Action Methods
    @IBAction func replyPublishButtonOnClick(_ sender: UIButton) {
        CommentUtil.reqHttpCreateComment(parentCommentId: self.parentComment!.id, contents: self.newReplyTextField.text!, sender: self) {
            (res) in
            self.newReplyTextField.text = "";
            self.replyPublishButton.backgroundColor = UIColor.lightGray;
            self.replyPublishButton.isEnabled = false;
            self.refreshReply();
        }
    }
    @IBAction func newReplyTextFieldOnChange(_ sender: UITextField) {
        if (self.newReplyTextField.text!.isEmpty) {
            self.replyPublishButton.backgroundColor = UIColor.lightGray;
            self.replyPublishButton.isEnabled = false;
        } else {
            self.replyPublishButton.backgroundColor = UIColor(red: CGFloat(196.0/255), green: CGFloat(92.0/255), blue: CGFloat(36.0/255), alpha: CGFloat(1.0));
            self.replyPublishButton.isEnabled = true;
        }
    }
}

extension UIPostReplyVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.replyList.isEmpty) {
            return 2;
        } else {
            return self.replyList.count + 1;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (indexPath.row == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCommentCell")! as! UIPostCommentCell;
            cell.delegate = self;
            cell.senderVC = self;
            cell.indexPath = indexPath;
            cell.comment = self.parentComment;
            cell.initCell();
            cell.replyButton.isEnabled = false;
            return cell;
        } else if (self.replyList.isEmpty) {
            return tableView.dequeueReusableCell(withIdentifier: "postCommentEmpty")!;
        } else {
            let comment = self.replyList[indexPath.row - 1];
            let cell = tableView.dequeueReusableCell(withIdentifier: "postReplyCell")! as! UIPostCommentCell;
            cell.delegate = self;
            cell.senderVC = self;
            cell.indexPath = indexPath;
            cell.comment = comment;
            cell.initCell();
            return cell;
        }
    }
}

extension UIPostReplyVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.replyTableView.contentOffset.y > self.replyTableView.contentSize.height - self.replyTableView.bounds.size.height && !self.isLastPage && !self.isLoading) {
            self.isLoading = true;
            CommentUtil.reqHttpFetchComment(parentCommentId: self.parentComment!.id, pageIdx: self.loadedPageCnt, topCommentId: self.topReplyId, sender: self, resHandler: self.replyFetch);
        }
    }
}
