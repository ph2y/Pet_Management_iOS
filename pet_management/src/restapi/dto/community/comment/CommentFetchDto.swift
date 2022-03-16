//
//  CommentFetchDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/16.
//

struct CommentFetchDto: Decodable {
    let _metadata: HttpMetaData;
    var commentList: [Comment];
    var pageable: Pageable;
    var isLast: Bool;
}
