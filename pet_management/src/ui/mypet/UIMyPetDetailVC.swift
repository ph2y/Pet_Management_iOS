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
    var loadedPageCnt: Int = 0;
    var isLastPage: Bool = false;
    var isLoading: Bool = true;
    
    override func viewDidLoad() {
        self.petPostTableView.delegate = self;
        self.petPostTableView.dataSource = self;
        if (self.pet != nil) {
            self.showPetDetails();
            PostUtil.reqHttpFetchPetPosts(petId: self.pet!.id, pageIdx: self.loadedPageCnt, sender: self, resHandler: self.petPostFetch);
        }
        self.initPullToRefresh();
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
    
    // func initRefresh
    // No Params
    // Return Void
    // Init pull-to-refresh cell
    func initPullToRefresh() {
        let refresh = UIRefreshControl();
        refresh.addTarget(self, action: #selector(self.refreshPostFeed(refresh:)), for: .valueChanged);
        refresh.attributedTitle = NSAttributedString(string: "새로운 게시물을 로드합니다...");
        self.petPostTableView.refreshControl = refresh;
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
        self.petPostList = [];
        self.loadedPageCnt = 0;
        self.isLastPage = false;
        self.isLoading = true;
        self.petPostTableView.reloadData();
        PostUtil.reqHttpFetchPetPosts(petId: self.pet!.id, pageIdx: self.loadedPageCnt, sender: self, resHandler: self.petPostFetch);
    }
    
    // func showPetDetails
    // No Params
    // Return Void
    // Display pet infomation to the card view
    func showPetDetails() {
        self.petNameLabel.text = self.pet!.name;
        self.petAgeLabel.text = "\(PetUtil.convertAge(birth: self.pet!.birth))살";
        self.petGenderLabel.text = PetUtil.convertGender(gender: self.pet!.gender);
        if (self.pet!.photoUrl == nil) {
            self.petImage.image = UIImage(named: "ICBaselinePets60WithPadding");
        } else {
            PetUtil.reqHttpFetchPetPhoto(petId: self.pet!.id, sender: self) {
                (petPhoto) in
                self.petImage.image = petPhoto;
            }
        }
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
    
    // func petPostFetch
    // Param res: DataResponse<PostFetchDto, AFError> - http response/error
    // Return Void
    // Append post to feed that loaded from server
    func petPostFetch(res: DataResponse<PostFetchDto, AFError>) {
        self.petPostList.append(contentsOf: res.value?.postList ?? []);
        self.petPostTableView.reloadData();
        self.loadedPageCnt += 1;
        self.isLastPage = res.value!.isLast;
        self.isLoading = false;
    }

    // func presentPopup
    // Param alert: UIAlertController - UIController for alert popup
    // Return Void
    // Show error popup on current UIView
    func presentPopup(alert: UIAlertController) {
        self.present(alert, animated: true);
    }
    
    // Action Methods
    @IBAction func unwindToMyPetDetail(_ segue: UIStoryboardSegue) {
        self.reqHttpFetchPetDetails();
        self.refreshPostFeed();
    }
}

extension UIMyPetDetailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.petPostList.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = self.petPostList[indexPath.row];
        
        if (self.petPostList.count == 0) {
            return tableView.dequeueReusableCell(withIdentifier: "petPostEmpty")!;
        } else if (post.imageAttachments == nil || post.imageAttachments!.count == 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "petPost") as! UIPetPostCellVC;
            cell.post = post;
            cell.indexPath = indexPath;
            cell.senderVC = self;
            cell.initCell();
            return cell;
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "petPostWithImage") as! UIPetPostWithImageCellVC;
            cell.post = post;
            cell.indexPath = indexPath;
            cell.senderVC = self;
            cell.initCell();
            return cell;
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
}

extension UIMyPetDetailVC: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (self.petPostTableView.contentOffset.y > self.petPostTableView.contentSize.height - self.petPostTableView.bounds.size.height && !self.isLastPage && !self.isLoading) {
            self.isLoading = true;
            PostUtil.reqHttpFetchPetPosts(petId: self.pet!.id, pageIdx: self.loadedPageCnt, sender: self, resHandler: self.petPostFetch);
        }
    }
}
