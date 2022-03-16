//
//  LikeFetchDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/17.
//

struct LikeFetchDto: Decodable {
    let _metadata: HttpMetaData;
    let likedCount: Int;
    let likedAccountIdList: [Int];
}
