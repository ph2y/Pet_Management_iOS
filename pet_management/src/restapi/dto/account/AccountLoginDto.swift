//
//  AccountLoginDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/19.
//

struct AccountLoginDto: Decodable {
    let _metadata: HttpMetaData;
    let token: String?;
}
