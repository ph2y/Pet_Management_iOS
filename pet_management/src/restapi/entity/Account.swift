//
//  Account.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/14.
//

import UIKit;
import Foundation;
import Alamofire;

struct Account: Decodable, Encodable {
    let id: Int;
    var username: String;
    var email: String;
    var phone: String;
    var password: String?;
    var marketing: Bool;
    var nickname: String;
    var photoUrl: String?;
    var userMessage: String?;
    var representativePetId: Int?;
    var fcmRegistrationToken: String?;
    var notification: Bool;
    var mapSearchRadius: Float;
}

struct AccountUtil {
    // static func reqHttpFetchAccountByNickname
    static func reqHttpFetchAccountByNickname(nickname: String, sender: UIViewController, resHandler: @escaping (DataResponse<AccountFetchDto, AFError>) -> Void) {
            let reqApi = "account/fetch";
            let reqUrl = APIBackendUtil.getUrl(api: reqApi);
            var reqBody = Dictionary<String, String>();
            let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
            reqBody["nickname"] = nickname;
            
            AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: AccountFetchDto.self) {
                (res) in
                guard (res.error == nil) else {
                    APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                    sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                    return;
                }
                
                guard (res.value?._metadata.status == true) else {
                    sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                    return;
                }
                resHandler(res);
            }
    }
    
    // static func reqHttpCreateFollow
    static func reqHttpCreateFollow(accountId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<FollowCreateDto, AFError>) -> Void) {
        let reqApi = "community/follow/create";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["id"] = String(accountId);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: FollowCreateDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            resHandler(res);
        }
    }
    
    // static func reqHttpFetchFollower
    static func reqHttpFetchFollower(accountId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<FollowerFetchDto, AFError>) -> Void) {
        let reqApi = "community/follower/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: FollowerFetchDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            resHandler(res);
        }
    }
    
    // static func reqHttpFetchFollowing
    static func reqHttpFetchFollowing(accountId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<FollowingFetchDto, AFError>) -> Void) {
        let reqApi = "community/following/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: FollowingFetchDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            resHandler(res);
        }
    }
    
    // static func reqHttpDeleteFollow
    static func reqHttpDeleteFollow(accountId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<FollowDeleteDto, AFError>) -> Void) {
        let reqApi = "community/follow/delete";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["id"] = String(accountId);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: FollowDeleteDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            
            guard (res.value?._metadata.status == true) else {
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                return;
            }
            resHandler(res);
        }
    }
}
