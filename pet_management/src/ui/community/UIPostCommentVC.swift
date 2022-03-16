//
//  UIPostCommentVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/16.
//

import UIKit;
import Alamofire

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
    
    // objc func refreshCommentFeed
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
        CommentUtil.reqHttpFetchComment(postId: self.postId, topCommentId: self.topCommentId, sender: self, resHandler: self.commentFetch);
    }
    
    func commentFetch(res: DataResponse<CommentFetchDto, AFError>) {
        self.commentList.append(contentsOf: res.value?.commentList ?? []);
        self.commentTableView.reloadData();
        self.loadedPageCnt += 1;
        self.isLastPage = res.value!.isLast;
        self.isLoading = false;
        
        // Set topCommentId if it was first fetch
        if (self.topCommentId == nil && res.value != nil) {
            self.topCommentId = res.value!.commentList[0].id;
        }
    }
    
    
    // Action methods
    @IBAction func unwindToComment(_ segue: UIStoryboardSegue) {
        self.refreshComment();
    }
    @IBAction func commentPublishBtnOnClick(_ sender: UIButton) {
    }
}

extension UIPostCommentVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.commentList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let comment = self.commentList[indexPath.row];
        
        if (self.commentList.count == 0) {
            return tableView.dequeueReusableCell(withIdentifier: "postCommentEmpty")!;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postCommentCell")!;
            return cell;
        }
    }
}
