//
//  BookSummaryService.swift
//
//
//  Created by Yulian on 23.01.2024.
//

import Models

import Combine
import Foundation

public protocol BookSummaryServiceProtocol {
    func fetchBookSummaries() async -> Result<BookSummary, BookSummaryFeatureError>
}

public  final class BookSummaryService {
    let jsonDecoder = JSONDecoder()

    let bookSummaryJsonName: String
    
    public init(bookSummaryJsonName name: String) {
        self.bookSummaryJsonName = name
    }
}

extension BookSummaryService: BookSummaryServiceProtocol {
    public func fetchBookSummaries() async -> Result<BookSummary, BookSummaryFeatureError> {
        do {
            if let url = Bundle.module.url(forResource: bookSummaryJsonName, withExtension: "json") {
                let data = try Data(contentsOf: url)
                let bookSummary = try JSONDecoder().decode(BookSummary.self, from: data)
                return .success(bookSummary)
            } else {
                return .failure(.fileNotFound)
            }
        } catch {
            return .failure(.invalidJSON)
        }
    }
}
