//
//  UIMyPetPageVC.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/21.
//

import UIKit;
import Alamofire;

class UIMyPetPageVC: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    var myPetCardViewList: [UIViewController] = [];
    
    override func viewDidLoad() {
        super.viewDidLoad();
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.reqHttpFetchMyPetList();
    }
    
    func loadPages() {
        self.dataSource = nil;
        self.dataSource = self;
        self.delegate = self;
        if let firstVC = self.myPetCardViewList.first{
            self.setViewControllers([firstVC], direction: .forward, animated: true, completion: nil);
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.myPetCardViewList.firstIndex(of: viewController) else {
            return nil;
        }
        let previousIndex = index - 1;
        if previousIndex < 0 {
            return nil;
        }
        return self.myPetCardViewList[previousIndex];
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.myPetCardViewList.firstIndex(of: viewController) else {
            return nil;
        }
        let nextIndex = index + 1;
        if nextIndex >= self.myPetCardViewList.count {
            return nil;
        }
        return self.myPetCardViewList[nextIndex];
    }
    
    func reqHttpFetchMyPetList() {
        let reqApi = "pet/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
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
            
            guard (res.value?.petList != nil && res.value?.petList?.count != 0) else {
                self.myPetCardViewList = [];
                self.myPetCardViewList.append(self.initMyPetEmptyVC(isEmpty: true));
                self.loadPages();
                return;
            }
            
            self.myPetCardViewList = res.value!.petList?.map() {
                (pet) in
                return self.initMyPetCardVC(pet: pet);
            } ?? [];
            self.myPetCardViewList.append(self.initMyPetEmptyVC(isEmpty: false));
            self.loadPages();
        }
    }
    
    func initMyPetCardVC(pet: Pet) -> UIViewController {
        let newMyPetCardVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyPetCardVC") as! UIMyPetCardVC;
        newMyPetCardVC.pet = pet;
        return newMyPetCardVC;
    }
    
    func initMyPetEmptyVC(isEmpty: Bool) -> UIViewController {
        let myPetEmptyVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MyPetEmptyVC") as! UIMyPetEmptyVC;
        myPetEmptyVC.isMyPetEmpty = isEmpty;
        return myPetEmptyVC;
    }
    
    // Action Methods
    @IBAction func unwindToPetPage(_ segue: UIStoryboardSegue) {
    }
}
