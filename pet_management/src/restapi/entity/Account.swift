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
    var mapSearchRadius: Double;
}

struct AccountUtil {
    // static func getAccountFromFetchedDto
    static func getAccountFromFetchedDto(dto: AccountFetchDto) -> Account {
        return Account(id: dto.id!, username: dto.username!, email: dto.email!, phone: dto.phone!, marketing: dto.marketing!, nickname: dto.nickname!, photoUrl: dto.photoUrl, userMessage: dto.userMessage, representativePetId: dto.representativePetId, fcmRegistrationToken: dto.fcmRegistrationToken, notification: dto.notification!, mapSearchRadius: dto.mapSearchRadius!);
    }
    
    // static func reqHttpFetchAccount
    static func reqHttpFetchAccount(resume: Bool, sender: UIViewController, resHandler: @escaping (DataResponse<AccountFetchDto, AFError>) -> Void) {
        let reqApi = "account/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: AccountFetchDto.self) {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            guard (res.value?._metadata.status == true) else {
                if (!resume) {
                    sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.value?._metadata.message), animated: true);
                }
                return;
            }
            resHandler(res);
        }
    }
    
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
                resHandler(res);
            }
    }
    
    // static func reqHttpUpdateAccountPhoto
    static func reqHttpUpdateAccount(email: String? = nil, phone: String? = nil, marketing: Bool? = nil, nickname: String? = nil, representativePetId: Int? = nil, notification: Bool? = nil, mapSearchRadius: Double? = nil, sender: UIViewController, resHandler: @escaping (DataResponse<AccountUpdateDto, AFError>) -> Void) {
        let reqApi = "account/update";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader = APIBackendUtil.getAuthHeader();
        
        if (email != nil) {
            reqBody["email"] = email!;
        }
        if (phone != nil) {
            reqBody["phone"] = phone!;
        }
        if (marketing != nil) {
            reqBody["marketing"] = String(marketing!);
        }
        if (nickname != nil) {
            reqBody["nickname"] = nickname!;
        }
        if (notification != nil) {
            reqBody["notification"] = String(notification!);
        }
        if (mapSearchRadius != nil) {
            reqBody["mapSearchRadius"] = String(mapSearchRadius!);
        }
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: AccountUpdateDto.self) {
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
    
    // static func reqHttpFetchAccountPhoto
    static func reqHttpFetchAccountPhoto(accountId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<Data, AFError>) -> Void) {
        let reqApi = "account/photo/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["id"] = String(accountId);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseData() {
            (res) in
            guard (res.error == nil) else {
                APIBackendUtil.logHttpError(reqApi: reqApi, errMsg: res.error?.localizedDescription);
                sender.present(APIBackendUtil.makeHttpErrorPopup(errMsg: res.error?.localizedDescription), animated: true);
                return;
            }
            resHandler(res);
        }
    }
    
    // TODO: Implement static func reqHttpUpdateAccountPhoto
    
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
