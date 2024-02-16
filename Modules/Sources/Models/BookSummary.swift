//
//  BookSummary.swift
//  BookSummaryPlayerTestTask
//
//  Created by Yulian on 23.01.2024.
//

import Foundation

public struct BookSummary: Codable, Equatable {
    public let id: Int
    public let title: String
    public let bookCover: String
    public let chapters: [Chapter]
}

public struct Chapter: Codable, Equatable {
    public let fileName: String
    public let fileType: String
    public let keyPoint: String
}
