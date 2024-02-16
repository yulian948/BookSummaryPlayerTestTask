//
//  BookSummaryPlayerTestTaskApp.swift
//  BookSummaryPlayerTestTask
//
//  Created by Yulian on 23.01.2024.
//

import SwiftUI
import ComposableArchitecture
import BookSummaryPlayerFeature

@main
struct BookSummaryPlayerTestTaskApp: App {
    var body: some Scene {
        WindowGroup {
            BookSummaryPlayerView(
                store: Store(initialState: BookSummaryPlayerFeature.State()) { BookSummaryPlayerFeature(
                    environement: BookSummaryPlayerEnvironment(
                        bookSummaryService: BookSummaryService(bookSummaryJsonName: "AtomicHabits")
                    )
                )
                }
            )
        }
    }
}
