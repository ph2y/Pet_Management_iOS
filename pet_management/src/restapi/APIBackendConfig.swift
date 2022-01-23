//
//  APIBackendConfig.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/15.
//

import UIKit;
import Alamofire;

enum APIBackendConfig: String {
    case host = "http://220.85.251.6:9000/api/";
}

class APIBackendUtil {
    static var host = "http://220.85.251.6:9000/api/";
    
    static func getUrl(api: String) -> String {
        return "\(host)\(api)";
    }
    
    static func getAuthHeader() -> HTTPHeaders {
        return [
            "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "loginToken")!)"
        ];
    }
    
    static func logHttpError(reqApi: String, errMsg: String?) {
        print("=================================================");
        print("API Request Failure : \(reqApi)");
        print(errMsg ?? "Unknown Error");
        print("=================================================");
    }
    
    static func makeHttpErrorPopup(errMsg: String?) -> UIAlertController {
        return UIUtil.makeSimplePopup(title: "네트워크 요청 에러", message: errMsg ?? "알 수 없는 오류", onClose: nil);
    }
}
