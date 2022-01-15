//
//  CreateAccountDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/15.
//

struct CreateAccountDto: Decodable {
    let _metadata: HttpMetaData;
    
    private enum CodingKeys: String, CodingKey {
        case _metadata = "_metadata"
    }
}
