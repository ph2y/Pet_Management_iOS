//
//  FollowingFetchDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/23.
//

struct FollowingFetchDto: Decodable {
    let _metadata: HttpMetaData;
    var followingList: [Account];
}
