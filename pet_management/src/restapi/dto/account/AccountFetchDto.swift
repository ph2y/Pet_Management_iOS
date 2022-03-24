//
//  AccountFetchDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/21.
//

struct AccountFetchDto: Decodable {
    var _metadata: HttpMetaData;
    var id: Int?;
    var username: String?;
    var email: String?;
    var phone: String?;
    var marketing: Bool?;
    var nickname: String?;
    var photoUrl: String?;
    var userMessage: String?;
    var representativePetId: Int?;
    var fcmRegistrationToken: String?;
    var mapSearchRadius: Float?;
    var notification: Bool?;
}
