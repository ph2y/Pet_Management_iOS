//
//  PostUpdateDto.swift
//  pet_management
//
//  Created by newcentury99 on 2022/03/18.
//

struct PostUpdateParam: Encodable {
    var id: Int?;
    var petId: Int?;
    var contents: String = "";
    var hashTags: [String] = [];
    var disclosure: String = "PUBLIC";
    var geoTagLat: Double = 0;
    var geoTagLong: Double = 0;
}

struct PostUpdateDto: Decodable {
    let _metadata: HttpMetaData;
}
