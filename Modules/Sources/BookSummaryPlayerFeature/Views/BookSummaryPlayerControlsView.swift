//
//  BookSummaryPlayerControlsView.swift
//  BookSummaryPlayerTestTask
//
//  Created by Yulian on 23.01.2024.
//

import SwiftUI

import ComposableArchitecture

struct BookSummaryPlayerControlsView: View {
    private let store: StoreOf<BookSummaryPlayerFeature>
    
    public init(store: StoreOf<BookSummaryPlayerFeature>) {
        self.store = store
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            
            HStack(alignment: .center, spacing: -3) {
                BookSummaryPlayerButton(.previous, disabled: viewStore.isFirstChapter) {
                    viewStore.send(.previousChapter)
                }
                BookSummaryPlayerButton(.backward5sec, disabled: viewStore.bookSummary == nil) {
                    viewStore.send(.backwards5)
                }
                
                if viewStore.isLoading {
                    ProgressView()
                } else {
                    BookSummaryPlayerButton(viewStore.playerMode.is(\.playing) ? .pause : .play, disabled: viewStore.bookSummary == nil) {
                        viewStore.send(.playPause)
                    }
                    .frame(width: 68)
                }
                BookSummaryPlayerButton(.forward10sec, disabled: viewStore.bookSummary == nil) {
                    viewStore.send(.forward10)
                }
                BookSummaryPlayerButton(.next, disabled: viewStore.isLastChapter) {
                    viewStore.send(.nextChapter)
                }
            }
        }
    }
}

#Preview {
    BookSummaryPlayerControlsView(store: Store(
        initialState: BookSummaryPlayerFeature.State()) { BookSummaryPlayerFeature(environement: BookSummaryPlayerEnvironment(bookSummaryService: BookSummaryService(bookSummaryJsonName: "AtomicHabits"))) } )
}
