//
//  Post.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/14.
//

import UIKit;
import Alamofire;

struct Post: Decodable, Encodable {
    let id: Int;
    var author: Account;
    var pet: Pet;
    var contents: String;
    var timestamp: String;
    var edited: Bool;
    var serializedHashTags: String;
    var disclosure: String;
    var geoTagLat: Float;
    var geoTagLong: Float;
    var imageAttachments: String?;
    var videoAttachments: String?;
    var fileAttachments: String?;
}

class PostUtil {
    // func repHttpFetchPetPosts
    // No Params
    // Return Void
    // Request to the server to get pet posts data
    static func reqHttpFetchPetPosts(petId: Int, pageIdx: Int, sender: UIViewController, resHandler: @escaping (DataResponse<PetPostFetchDto, AFError>) -> Void) {
        let reqApi = "post/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["pageIndex"] = String(pageIdx);
        reqBody["petId"] = String(petId);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetPostFetchDto.self) {
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
    
    // func reqHttpFetchPosts
    // No Params
    // Return Void
    // Request to the server to get post feed data
    static func reqHttpFetchPosts(pageIdx: Int, sender: UIViewController, resHandler: @escaping (DataResponse<PetPostFetchDto, AFError>) -> Void) {
        let reqApi = "post/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["pageIndex"] = String(pageIdx);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: PetPostFetchDto.self) {
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
    
    // func reqHttpFetchLike
    // No Params
    // Return Void
    // Request to the server to get post like data
    static func reqHttpFetchLike(postId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<LikeFetchDto, AFError>) -> Void) {
        let reqApi = "like/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["postId"] = String(postId);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: LikeFetchDto.self) {
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
    
    // func reqHttpLike
    // No Params
    // Return Void
    // Request to the server to like post
    static func reqHttpLike(postId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<LikeCreateDto, AFError>) -> Void) {
        let reqApi = "like/create";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["postId"] = String(postId);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: LikeCreateDto.self) {
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
    
    // func reqHttpUnLike
    // No Params
    // Return Void
    // Request to the server to unlike post
    static func reqHttpUnLike(postId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<LikeDeleteDto, AFError>) -> Void) {
        let reqApi = "like/delete";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        reqBody["postId"] = String(postId);
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: LikeDeleteDto.self) {
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
