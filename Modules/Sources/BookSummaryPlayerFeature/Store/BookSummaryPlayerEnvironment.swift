//
//  BookSummaryPlayerEnvironment.swift
//  
//
//  Created by Yulian on 23.01.2024.
//

import Foundation

public struct BookSummaryPlayerEnvironment {
    let bookSummaryService: BookSummaryServiceProtocol

    public init(bookSummaryService: BookSummaryServiceProtocol) {
        self.bookSummaryService = bookSummaryService
    }
}
