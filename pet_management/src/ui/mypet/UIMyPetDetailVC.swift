//
//  UIMyPetDetailVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/23.
//

import UIKit;
import Alamofire;

class UIMyPetDetailVC: UIViewController, UIPetPostCellDelegate {
    @IBOutlet weak var petNameLabel: UILabel!;
    @IBOutlet weak var petAgeLabel: UILabel!;
    @IBOutlet weak var petGenderLabel: UILabel!;
    @IBOutlet weak var petImage: UIImageView!;
    @IBOutlet weak var petPostTableView: UITableView!;
    
    var pet: Pet?;
    var petPostList: [Post] = [];
    var lastPageIndex: Int = 0;
    
    override func viewDidLoad() {
        if (self.pet != nil) {
            self.showPetDetails();
        }
        self.reqHttpFetchPetPosts();
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "MyPetEditSegue") {
            let destVC = segue.destination;
            guard let myPetEditorVC = destVC as? UIMyPetEditorVC else {
                return;
            }
            myPetEditorVC.pet = self.pet;
            myPetEditorVC.isNewPet = false;
        }
    }
    
    // func showPetDetails
    // No Params
    // Return Void
    // Display pet infomation to the card view
    func showPetDetails() {
        self.petNameLabel.text = self.pet!.name;
        self.petAgeLabel.text = "\(PetUtil.convertAge(birth: self.pet!.birth))살";
        self.petGenderLabel.text = PetUtil.convertGender(gender: self.pet!.gender);
        self.petImage.image = PetUtil.convertImage(photoUrl: self.pet!.photoUrl);
    }
    
    // func reqHttpFetchPetDetails
    // No Params
    // Return Void
    // Renew pet infomation when card list view is appeared
    func reqHttpFetchPetDetails() {
        let reqApi = "pet/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["id"] = String(self.pet!.id);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetFetchDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            
            self.pet = res.value?.petList?[0];
            self.showPetDetails();
        }
    }
    
    // func repHttpFetchPetPosts
    // No Params
    // Return Void
    // Request to the server to get pet posts data
    func reqHttpFetchPetPosts() {
        let reqApi = "post/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["pageIndex"] = String(self.lastPageIndex);
        reqBody["petId"] = String(self.pet!.id);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetPostFetchDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                self.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            
            self.petPostList = res.value?.postList ?? [];
            self.petPostTableView.delegate = self;
            self.petPostTableView.dataSource = nil;
            self.petPostTableView.dataSource = self;
        }
    }
    
    func presentPopup(alert: UIAlertController) {
        self.present(alert, animated: true);
    }
    
    // Action Methods
    @IBAction func unwindToMyPetDetail(_ segue: UIStoryboardSegue) {
        self.reqHttpFetchPetDetails();
    }
}

extension UIMyPetDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.petPostList.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let decoder = JSONDecoder();
        let post = self.petPostList[indexPath.row];
        var imageAttachementList: [Attachment] = [];
        var videoAttachmentList: [Attachment] = [];
        var fileAttachmentList: [Attachment] = [];
        if (post.imageAttachments?.data(using: .utf8) != nil) {
            imageAttachementList = try! decoder.decode([Attachment].self, from: post.imageAttachments!.data(using: .utf8)!);
        }
        if (post.videoAttachments?.data(using: .utf8) != nil) {
            videoAttachmentList = try! decoder.decode([Attachment].self, from: post.videoAttachments!.data(using: .utf8)!);
        }
        if (post.fileAttachments?.data(using: .utf8) != nil) {
            fileAttachmentList = try! decoder.decode([Attachment].self, from: post.fileAttachments!.data(using: .utf8)!);
        }
        
        if (self.petPostList.count == 0) {
            return tableView.dequeueReusableCell(withIdentifier: "petPostEmpty")!;
        } else if (imageAttachementList.count == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "petPost") as! UIPetPostCellVC;
            cell.post = post;
            if (post.pet.photoUrl != nil) {
                let imageData = try! Data(contentsOf: URL(string: post.pet.photoUrl!)!);
                cell.petImage.image = UIImage(data: imageData);
            }
            cell.authorAndPetNameLabel.text = "\(post.author.nickname) 님의 \(post.pet.name)";
            cell.contentTextView.text = post.contents;
            cell.postTagLabel.text = post.serializedHashTags;
            cell.attachmentFileBtn.setTitle( "첨부파일\(fileAttachmentList.count)개", for: .normal);
            cell.reqHttpFetchLike();
            cell.commentBtn.setTitle("댓글 X개", for: .normal);
            return cell;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "petPostWithImage") as! UIPetPostWithImageCellVC;
            cell.indexPath = indexPath;
            cell.post = post;
            if (post.pet.photoUrl != nil) {
                let imageData = try! Data(contentsOf: URL(string: post.pet.photoUrl!)!);
                cell.petImage.image = UIImage(data: imageData);
            }
            
            let swipeLeft = UISwipeGestureRecognizer(target: cell, action: #selector(cell.swipeForNextImage(_:)));
            swipeLeft.direction = UISwipeGestureRecognizer.Direction.left;
            let swipeRight = UISwipeGestureRecognizer(target: cell, action: #selector(cell.swipeForPrevImage(_:)));
            swipeRight.direction = UISwipeGestureRecognizer.Direction.right;
            cell.postImageView.addGestureRecognizer(swipeLeft);
            cell.postImageView.addGestureRecognizer(swipeRight);
            
            cell.pageControl.numberOfPages = imageAttachementList.count + videoAttachmentList.count;
            cell.pageControl.currentPage = 0;
            cell.pageControl.pageIndicatorTintColor = UIColor.lightGray;
            cell.pageControl.currentPageIndicatorTintColor = UIColor.black;
            cell.reqHttpFetchPostImage(cell: cell, cellIndex: indexPath, postId: post.id, imageIndex: 0);
            cell.authorAndPetNameLabel.text = "\(post.author.nickname) 님의 \(post.pet.name)";
            cell.contentTextView.isScrollEnabled = false;
            cell.contentTextView.text = post.contents;
            cell.contentTextView.sizeToFit();
            cell.postTagLabel.text = post.serializedHashTags;
            cell.attachmentFileBtn.setTitle( "첨부파일\(fileAttachmentList.count)개", for: .normal);
            cell.reqHttpFetchLike();
            cell.commentBtn.setTitle("댓글 X개", for: .normal);
            return cell;
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
}

extension UIMyPetDetailVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.petPostTableView.contentOffset.y > self.petPostTableView.contentSize.height - self.petPostTableView.bounds.size.height) {
            self.petPostTableView.reloadData();
        }
    }
}
