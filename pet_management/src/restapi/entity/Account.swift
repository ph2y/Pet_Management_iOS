//
//  Account.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/14.
//

import Foundation

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
