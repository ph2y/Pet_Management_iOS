//
//  UIPostCommentVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/16.
//

import UIKit;
import Alamofire;

class UIPostCommentVC: UIViewController, UIPostCommentCellDelegate {
    @IBOutlet weak var commentTableView: UITableView!;
    @IBOutlet weak var newCommentTextField: UITextField!;
    @IBOutlet weak var commentPublishButton: UIButton!;
    
    var commentList: [Comment] = [];
    var postId: Int?;
    var topCommentId: Int?;
    var loadedPageCnt: Int = 0;
    var isLastPage: Bool = false;
    var isLoading: Bool = true;
    
    override func viewDidLoad() {
        self.commentTableView.delegate = self;
        self.commentTableView.dataSource = self;
        
        CommentUtil.reqHttpFetchComment(postId: self.postId, sender: self, resHandler: self.commentFetch);
        self.initPullToRefresh();
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "ReplyViewSegue") {
            let dest = segue.destination;
            guard let destVC = dest as? UIPostReplyVC else {
                return;
            }
            let index = sender as! IndexPath;
            destVC.parentComment = self.commentList[index.row];
        }
    }
    
    // func initPullToRefresh
    // No Params
    // Return Void
    // Init pull-to-refresh cell
    func initPullToRefresh() {
        let refresh = UIRefreshControl();
        refresh.addTarget(self, action: #selector(self.refreshComment(refresh:)), for: .valueChanged);
        refresh.attributedTitle = NSAttributedString(string: "새로운 댓글을 로드합니다...");
        self.commentTableView.refreshControl = refresh;
    }
    
    // objc func refreshComment
    // refresh: UIRefreshControl - The controller class of UIRefresh
    // Return Void
    // Call CommentListTableView & Show refresh animation
    @objc func refreshComment(refresh: UIRefreshControl) {
        self.refreshComment();
        refresh.endRefreshing();
    }

    // func refreshComment
    // No Params
    // Return Void
    // Reset commentTableView
    func refreshComment() {
        self.commentList = [];
        self.topCommentId = nil;
        self.loadedPageCnt = 0;
        self.isLastPage = false;
        self.isLoading = true;
        self.commentTableView.reloadData();
        CommentUtil.reqHttpFetchComment(postId: self.postId, sender: self, resHandler: self.commentFetch);
    }
    
    func commentFetch(res: DataResponse<CommentFetchDto, AFError>) {
        self.commentList.append(contentsOf: res.value?.commentList ?? []);
        self.commentTableView.reloadData();
        self.loadedPageCnt += 1;
        self.isLastPage = res.value!.isLast;
        self.isLoading = false;
        
        // Set topCommentId if it was first fetch
        if (self.topCommentId == nil && res.value != nil && !self.commentList.isEmpty) {
            self.topCommentId = res.value!.commentList[0].id;
        }
    }
    
    
    // Action methods
    @IBAction func unwindToComment(_ segue: UIStoryboardSegue) {
        self.refreshComment();
    }
    @IBAction func newCommentTextFieldOnChange(_ sender: UITextField) {
        if (self.newCommentTextField.text!.isEmpty) {
            self.commentPublishButton.backgroundColor = UIColor.lightGray;
            self.commentPublishButton.isEnabled = false;
        } else {
            self.commentPublishButton.backgroundColor = UIColor(red: CGFloat(196.0/255), green: CGFloat(92.0/255), blue: CGFloat(36.0/255), alpha: CGFloat(1.0));
            self.commentPublishButton.isEnabled = true;
        }
    }
    @IBAction func commentPublishBtnOnClick(_ sender: UIButton) {
        CommentUtil.reqHttpCreateComment(postId: self.postId, contents: self.newCommentTextField.text!, sender: self) {
            (res) in
            self.newCommentTextField.text = "";
            self.commentPublishButton.backgroundColor = UIColor.lightGray;
            self.commentPublishButton.isEnabled = false;
            self.refreshComment();
        }
    }
}

extension UIPostCommentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.commentList.isEmpty) {
            return 1;
        } else {
            return self.commentList.count;
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (self.commentList.isEmpty) {
            return tableView.dequeueReusableCell(withIdentifier: "postCommentEmpty")!;
        } else {
            let comment = self.commentList[indexPath.row];
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCommentCell")! as! UIPostCommentCell;
            cell.delegate = self;
            cell.senderVC = self;
            cell.indexPath = indexPath;
            cell.comment = comment;
            cell.initCell();
            return cell;
        }
    }
}

extension UIPostCommentVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.commentTableView.contentOffset.y > self.commentTableView.contentSize.height - self.commentTableView.bounds.size.height && !self.isLastPage && !self.isLoading) {
            self.isLoading = true;
            CommentUtil.reqHttpFetchComment(postId: self.postId, pageIdx: self.loadedPageCnt, topCommentId: self.topCommentId, sender: self, resHandler: self.commentFetch);
        }
    }
}
