//
//  Comment.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/16.
//

import UIKit;
import Alamofire;

struct Comment: Decodable {
    let id: Int;
    var author: Account;
    var postId: Int?;
    var parentCommentId: Int?;
    var childCommentCnt: Int;
    var contents: String;
    var timestamp: String;
    var edited: Bool;
}

class CommentUtil {
    static func reqHttpCreateComment(postId: Int? = nil, parentCommentId: Int? = nil, contents: String, sender: UIViewController, resHandler: @escaping (DataResponse<CommentCreateDto, AFError>) -> Void) {
        let reqApi = "comment/create";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        if (postId != nil) {
            reqBody["postId"] = String(postId!);
        } else if (parentCommentId != nil) {
            reqBody["parentCommentId"] = String(parentCommentId!);
        } else {
            return;
        }
        reqBody["contents"] = contents;
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: CommentCreateDto.self) {
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
    
    static func reqHttpFetchComment(postId: Int? = nil, parentCommentId: Int? = nil, pageIdx: Int? = nil, topCommentId: Int? = nil, sender: UIViewController, resHandler: @escaping (DataResponse<CommentFetchDto, AFError>) -> Void) {
        let reqApi = "comment/fetch";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        var reqBody = Dictionary<String, String>();
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        if (postId != nil) {
            reqBody["postId"] = String(postId!);
        } else if (parentCommentId != nil) {
            reqBody["parentCommentId"] = String(parentCommentId!);
        } else {
            return;
        }
        if (pageIdx != nil && topCommentId != nil) {
            reqBody["pageIndex"] = String(pageIdx!);
            reqBody["topCommentId"] = String(topCommentId!);
        }
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: CommentFetchDto.self) {
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
    
    static func reqHttpUpdateComment(commentId: Int, contents: String, sender: UIViewController, resHandler: @escaping (DataResponse<CommentUpdateDto, AFError>) -> Void) {
        let reqApi = "comment/update";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqBody: Dictionary<String, String> = [
            "id": String(commentId),
            "contents": contents
        ];
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: CommentUpdateDto.self) {
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
    
    static func reqHttpDeleteComment(commentId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<CommentDeleteDto, AFError>) -> Void) {
        let reqApi = "comment/delete";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqBody: Dictionary<String, String> = [
            "id": String(commentId)
        ];
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: CommentDeleteDto.self) {
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
    
    // func reqHttpReportComment
    static func reqHttpReportComment(commentId: Int, sender: UIViewController, resHandler: @escaping (DataResponse<CommentReportDto, AFError>) -> Void) {
        let reqApi = "comment/report";
        let reqUrl = APIBackendUtil.getUrl(api: reqApi);
        let reqHeader: HTTPHeaders = APIBackendUtil.getAuthHeader();
        let reqBody = [
            "id": String(commentId)
        ];
        
        AF.request(reqUrl, method: .post, parameters: reqBody, encoding: JSONEncoding.default, headers: reqHeader).responseDecodable(of: CommentReportDto.self) {
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
