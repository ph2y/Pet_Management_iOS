//
//  Pageable.swift
//  pet_management
//
//  Created by newcentury99 on 2022/02/17.
//

struct Pageable: Decodable {
    let sort: Sort;
    let pageNumber: Int;
    let pageSize: Int;
    let offset: Int;
    let unpaged: Bool;
    let paged: Bool;
}

struct Sort: Decodable {
    let sorted: Bool;
    let unsorted: Bool;
    let empty: Bool;
}
