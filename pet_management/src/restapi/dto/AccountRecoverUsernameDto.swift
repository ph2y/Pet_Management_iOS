//
//  AccountRecoverUsernameDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/16.
//

struct AccountRecoverUsernameDto: Decodable {
    let _metadata: HttpMetaData;
    let username: String?;
}
