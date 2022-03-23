//
//  UIPostFeedVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/04.
//

import UIKit;
import Alamofire;
import CoreLocation;

class UIPostFeedVC: UIViewController, UIPostCellDelegate {
    //TODO: TableDelegate와 TableDataSource를 분리하여 마이펫 탭의 피드와 코드 중복도 개선할 방법 찾기
    @IBOutlet weak var postFeedTableView: UITableView!;
    
    let locationManager = CLLocationManager();
    var postList: [Post] = [];
    var loadedPageCnt: Int = 0;
    var isLastPage: Bool = false;
    var isLoading: Bool = true;
    var currentPosition: Position?;

    override func viewDidLoad() {
        self.postFeedTableView.delegate = self;
        self.postFeedTableView.dataSource = self;
        self.initPullToRefresh();
        self.initPostFetchWithGeoTag();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "CommentViewSegue") {
            let dest = segue.destination;
            guard let destVC = dest as? UIPostCommentVC else {
                return;
            }
            let index = sender as! IndexPath;
            destVC.postId = self.postList[index.row].id;
        }
        if (segue.identifier == "PostEditorSegue") {
            let dest = segue.destination;
            guard let destVC = dest as? UIPostEditorVC else {
                return;
            }
            let index = sender as! IndexPath;
            destVC.isNewPost = false;
            destVC.currentPost = self.postList[index.row];
        }
    }
    
    func initPostFetchWithGeoTag() {
        self.locationManager.requestWhenInUseAuthorization();
        if (CLLocationManager.locationServicesEnabled()) {
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            self.locationManager.startUpdatingLocation();
        } else {
            self.currentPosition = nil;
            PostUtil.reqHttpFetchPosts(pageIdx: self.loadedPageCnt, currentPostion: nil, sender: self, resHandler: self.postFetch);
        }
    }
    
    // func initRefresh
    // No Params
    // Return Void
    // Init pull-to-refresh cell
    func initPullToRefresh() {
        let refresh = UIRefreshControl();
        refresh.addTarget(self, action: #selector(self.refreshPostFeed(refresh:)), for: .valueChanged);
        refresh.attributedTitle = NSAttributedString(string: "새로운 게시물을 로드합니다...");
        self.postFeedTableView.refreshControl = refresh;
    }
    
    // objc func refreshPostFeed
    // refresh: UIRefreshControl - The controller class of UIRefresh
    // Return Void
    // Call PetPostListTableView & Show refresh animation
    @objc func refreshPostFeed(refresh: UIRefreshControl) {
        self.refreshPostFeed();
        refresh.endRefreshing();
    }
    
    // func refreshPostFeed
    // No Params
    // Return Void
    // Reset PetPostListTableView
    func refreshPostFeed() {
        self.postList = [];
        self.loadedPageCnt = 0;
        self.isLastPage = false;
        self.isLoading = true;
        self.postFeedTableView.reloadData();
        PostUtil.reqHttpFetchPosts(pageIdx: self.loadedPageCnt, currentPostion: self.currentPosition, sender: self, resHandler: self.postFetch);
    }
    
    // func postFetch
    // Param res: DataResponse<PostFetchDto, AFError> - http response/error
    // Return Void
    // Append post to feed that loaded from server
    func postFetch(res: DataResponse<PostFetchDto, AFError>) {
        self.postList.append(contentsOf: res.value?.postList ?? []);
        self.postFeedTableView.reloadData();
        self.loadedPageCnt += 1;
        self.isLastPage = res.value!.isLast;
        self.isLoading = false;
    }
    
    // Action Methods
    @IBAction func unwindToCommunityFeed(_ segue: UIStoryboardSegue) {
        self.refreshPostFeed();
    }
}

extension UIPostFeedVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postList.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.postList[indexPath.row];
        
        if (self.postList.count == 0) {
            return tableView.dequeueReusableCell(withIdentifier: "postEmpty")!;
        } else if (post.imageAttachments == nil || post.imageAttachments!.count == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "post") as! UIPostCellVC;
            cell.post = post;
            cell.fileAttachmentList = PostUtil.decodeAttachmentMetadata(attachmentMetadata: post.fileAttachments);
            cell.indexPath = indexPath;
            cell.senderVC = self;
            cell.delegate = self;
            cell.initCell();
            return cell;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "postWithImage") as! UIPostWithImageCellVC;
            cell.post = post;
            cell.fileAttachmentList = PostUtil.decodeAttachmentMetadata(attachmentMetadata: post.fileAttachments);
            cell.indexPath = indexPath;
            cell.senderVC = self;
            cell.delegate = self;
            cell.initCell();
            return cell;
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
}

// Extension - UIScrollViewDelegate
extension UIPostFeedVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.postFeedTableView.contentOffset.y > self.postFeedTableView.contentSize.height - self.postFeedTableView.bounds.size.height && !self.isLastPage && !self.isLoading) {
            self.isLoading = true;
            PostUtil.reqHttpFetchPosts(pageIdx: self.loadedPageCnt, currentPostion: self.currentPosition, topPostId: self.postList[0].id, sender: self, resHandler: self.postFetch);
        }
    }
}

// Extenstion - CLLocationManagerDelegate
extension UIPostFeedVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last! as CLLocation;
        var firstLoad = false;
        if (self.currentPosition == nil) {
            firstLoad = true;
        }
        self.currentPosition = Position(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude);
        if (firstLoad == true) {
            self.refreshPostFeed();
        }
    }
}
