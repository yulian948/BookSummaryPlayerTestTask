//
//  AudioPlayerFeatureError.swift
//  BookSummaryPlayerTestTask
//
//  Created by  Yulian on 23.01.2024.
//

import Foundation

public enum BookSummaryFeatureError: Error, Equatable {
    case invalidJSON
    case fileNotFound
    case decodingError(Error)
}

public func == (lhs: Error, rhs: Error) -> Bool {
    guard type(of: lhs) == type(of: rhs) else { return false }
    let error1 = lhs as NSError
    let error2 = rhs as NSError
    return error1.domain == error2.domain && error1.code == error2.code && "\(lhs)" == "\(rhs)"
}

public extension Equatable where Self : Error {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs as Error == rhs as Error
    }
}
