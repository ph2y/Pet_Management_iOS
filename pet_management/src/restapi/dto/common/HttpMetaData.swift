//
//  Metadata.swift
//  pet_management
//
//  Created by newcentury99 on 2022/01/15.
//

struct HttpMetaData: Decodable {
    let status: Bool;
    let message: String;
    let exception: String?;
}
