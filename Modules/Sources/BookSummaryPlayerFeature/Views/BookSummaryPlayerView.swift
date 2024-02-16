//
//  BookSummaryPlayerView.swift
//  BookSummaryPlayerTestTask
//
//  Created by Yulian on 23.01.2024.
//

import ComposableArchitecture

import SwiftUI

import Resources
import CustomUIElements

public struct BookSummaryPlayerView: View {
    private let store: StoreOf<BookSummaryPlayerFeature>
    
    public init(store: StoreOf<BookSummaryPlayerFeature>) {
        self.store = store
    }
    
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Color.accent.ignoresSafeArea()
                
                VStack(alignment: .center, spacing: 10) {
                    ZStack {
                        let uiImage: UIImage = (viewStore.bookCoverImageName != nil)
                        ? UIImage(named: viewStore.bookCoverImageName!, in: Bundle.module, with: nil)!
                        : UIImage(systemName: "photo.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 60, weight: .regular, scale: .large))!
                        
                        Image(uiImage: uiImage)
                            .resizable()
                            .cornerRadius(8)
                        
                        if viewStore.isLoading {
                            ProgressView()
                        }
                    }
                    .frame(width: 217)
                    .aspectRatio(1.2, contentMode: .fit)
                    .padding(.bottom, 27)
                    
                    Text(viewStore.keyPointTitle)
                        .textCase(.uppercase)
                        .foregroundStyle(.gray)
                        .font(.system(size: 14, weight: .medium))
                    Text(viewStore.keyPointDescription)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4.0)
                        .foregroundStyle(.primary)
                        .font(.system(size: 14, weight: .regular))
                        .frame(height: 38)
                        .padding(.bottom, 10)
                    
                    HStack(alignment: .center) {
                        Text(viewStore.currentTimeString)
                            .foregroundStyle(.gray)
                            .font(.system(size: 14, weight: .regular))
                            .frame(width: 40, alignment: .leading)
                        CustomizableSlider(value: viewStore.binding(
                            get: \.currentTimeSeconds,
                            send: { .seekTo($0) }),
                                           maxValue: viewStore.playerItemDurationSeconds,
                                           thumbColor: UIColor(Color.playerBlue), thumbSize: 15.0,
                                           minTrackColor: UIColor(Color.playerBlue))
                        Text(viewStore.playerItemDurationString)
                            .foregroundStyle(.gray)
                            .font(.system(size: 14, weight: .regular))
                            .frame(width: 40, alignment: .trailing)
                    }
                    .padding(.bottom, 12)
                    
                    Button(action: {
                        viewStore.send(.toggleRate)
                    }, label: {
                        Text(viewStore.playerRate.rateString)
                            .foregroundStyle(Color.playerButtonForeground)
                            .font(.system(size: 14, weight: .medium))
                    })
                    .buttonStyle(.bordered)
                    .padding(.bottom, 24)
                    
                    BookSummaryPlayerControlsView(store: self.store)
                        .frame(height: 75)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.top, 30)
                .padding([.leading, .trailing, .bottom])
                
            }
            .onAppear {
                viewStore.send(.loadSummary)
            }
        }
    }
}

#Preview {
    BookSummaryPlayerView(
        store: Store(
            initialState: BookSummaryPlayerFeature.State()) { BookSummaryPlayerFeature(environement: BookSummaryPlayerEnvironment(bookSummaryService: BookSummaryService(bookSummaryJsonName: "AtomicHabits"))) } )
}
