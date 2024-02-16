//
//  BookSummaryPlayerStore.swift
//  BookSummaryPlayerTestTask
//
//  Created by Yulian on 23.01.2024.
//

import ComposableArchitecture

import AudioPlayerClient
import Models

import CoreMedia
import Foundation

public enum PlayingRate: Float, CaseIterable {
    case half = 0.5
    case threeQuarters = 0.75
    case defaultRate = 1
    case oneAndQuarter = 1.25
    case oneAndHalf = 1.5
    case oneAndThreeQuarters = 1.75
    case two = 2
    
    var rateString: String {
        "Speed x\(self.rawValue.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", self.rawValue) : String(self.rawValue))"
    }
    
    var next: Self {
        let all = Self.allCases
        let idx = all.firstIndex(of: self)!
        let next = all.index(after: idx)
        return all[next == all.endIndex ? all.startIndex : next]
    }
}

public struct BookSummaryPlayerFeature: Reducer {
    private let environement: BookSummaryPlayerEnvironment
    @Dependency(\.audioPlayerClient) private var audioPlayerClient
    
    @CasePathable
    @dynamicMemberLookup
    public enum PlayerMode: Equatable {
      case notPlaying
      case playing
    }
    
    private enum CancelID { 
        case play
        case didPlayToEndTime
    }
    
    public struct State: Equatable {
        public var currentChapterIndex = 0
        public var bookSummary: BookSummary? = nil
        public var isLoading: Bool = false
        
        public var playerMode = PlayerMode.notPlaying
        public var playerRate = PlayingRate.defaultRate
        
        public var currentTimeString: String = "00:00"
        public var currentTimeSeconds: Float64 = 0
        
        public var playerItemDurationString: String = "00:00"
        public var playerItemDurationSeconds: Float64 = 0
        
        public var bookCoverImageName: String? {
            bookSummary?.bookCover ?? nil
        }
        
        public var keyPointTitle: String {
            var title = ""
            
            if let bookSummary {
                let chaptersCount = bookSummary.chapters.count
                
                if chaptersCount != 0 {
                    title = "Key point \(currentChapterIndex + 1) of \(chaptersCount)"
                }
            }
            
            return title
        }
        
        public var keyPointDescription: String {
            var description = ""
            
            if let currentChapter {
                description = currentChapter.keyPoint
            }
            
            return description
        }

        public var isFirstChapter: Bool {
             currentChapterIndex == 0
        }
        
        public var isLastChapter: Bool {
            if let bookSummary = bookSummary {
                return currentChapterIndex == bookSummary.chapters.count - 1
            } else { return true }
        }
        
        var currentChapter: Chapter? {
            var chapter: Chapter?
            
            if let bookSummary {
                let chaptersCount = bookSummary.chapters.count
                
                if chaptersCount > currentChapterIndex {
                    chapter = bookSummary.chapters[currentChapterIndex]
                }
            }
            
            return chapter
        }
        
        public init(summary: BookSummary? = nil) {
            self.bookSummary = summary
        }
    }
    
    public enum Action {
        case loadSummary
        
        case loadAudioPlayer
        case playPause
        
        case currentTimeUpdated(CMTime)
        case setPlayerRate(Float)
        case toggleRate
        case backwards5
        case forward10
        case seekTo(Float64)
        case didPlayToEndTime
        
        case previousChapter
        case nextChapter
        
        case gotItemDuration(CMTime?)
        
        case summaryLoaded(Result<BookSummary, BookSummaryFeatureError>)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .loadSummary:
                state.isLoading = true
                
                return .run { send in
                    let result = await environement
                        .bookSummaryService
                        .fetchBookSummaries()
                    
                    await send(.summaryLoaded(result))
                }
                
            case .loadAudioPlayer:
                if let currentChapter = state.currentChapter,
                   let summaryAudioUrl = Bundle.module.url(forResource: currentChapter.fileName, withExtension: currentChapter.fileType) {
                    
                    state.playerMode = .notPlaying
                    
                    self.audioPlayerClient.load(summaryAudioUrl)
                    
                    return .run { send in
                        let duration = await self.audioPlayerClient.duration(summaryAudioUrl)
                        await send(.gotItemDuration(duration))
                    }
                }
                
                return .none // TODO:
            case .playPause:
                switch state.playerMode {
                case .notPlaying:
                    if let currentChapter = state.currentChapter,
                       let summaryAudioUrl = Bundle.module.url(forResource: currentChapter.fileName, withExtension: currentChapter.fileType) {
                        state.playerMode = .playing
                        let currentRate = state.playerRate.rawValue
                        
                        return .merge(
                            .run { send in
                                await send(.gotItemDuration(await self.audioPlayerClient.duration(summaryAudioUrl)))
                            },
                            .run { send in
                                for try await time in self.audioPlayerClient.play(summaryAudioUrl, currentRate) {
                                    await send(.currentTimeUpdated(time))
                                }
                            }.cancellable(id: CancelID.play, cancelInFlight: true),
                            .publisher {
                                NotificationCenter.default.publisher(for: NSNotification.Name.AVPlayerItemDidPlayToEndTime)
                                    .map { _ in
                                        return .didPlayToEndTime
                                    }
                            }.cancellable(id: CancelID.didPlayToEndTime, cancelInFlight: true)
                        )
                    } else {
                        return .none // TODO:
                    }
                case .playing:
                    state.playerMode = .notPlaying
                    
                    self.audioPlayerClient.pause()
                    
                    return .merge(.cancel(id: CancelID.play), .cancel(id:CancelID.didPlayToEndTime))
                }
                
            case let .currentTimeUpdated(time):
                state.currentTimeSeconds = CMTimeGetSeconds(time)
                state.currentTimeString = self.formattedTimeString(time)
                
                return .none
            case let .setPlayerRate(playerRate):
                self.audioPlayerClient.setRate(playerRate)
                
                return .none
            case .toggleRate:
                state.playerRate = state.playerRate.next
                
                if state.playerMode == .playing {
                    self.audioPlayerClient.setRate(state.playerRate.rawValue)
                }
                
                return .none
            case .backwards5:
                self.audioPlayerClient.seek5SecBackwards()
                return .none
            case .forward10:
                self.audioPlayerClient.seek10SecForward()
                return .none
            case let .seekTo(seconds):
                self.audioPlayerClient.seekTo(CMTimeMakeWithSeconds(seconds, preferredTimescale: 1))
                return .none
            case .didPlayToEndTime:
                if !state.isLastChapter {
                    return .send(.nextChapter)
                } else {
                    return .send(.playPause)
                }
                
            case .previousChapter:
                if !state.isFirstChapter {
                    state.currentChapterIndex -= 1
                }
                
                switch state.playerMode {
                case .notPlaying: 
                    return .concatenate(
                        .cancel(id:CancelID.didPlayToEndTime),
                        .cancel(id: CancelID.play),
                        .send(.loadAudioPlayer))
                case .playing:
                    state.playerMode = .notPlaying
                    return .concatenate(
                        .cancel(id:CancelID.didPlayToEndTime),
                        .cancel(id: CancelID.play),
                        .send(.playPause))
                }
            case .nextChapter:
                if !state.isLastChapter {
                    state.currentChapterIndex += 1
                }
                
                switch state.playerMode {
                case .notPlaying:
                    return .concatenate(
                        .cancel(id:CancelID.didPlayToEndTime),
                        .cancel(id: CancelID.play),
                        .send(.loadAudioPlayer))
                case .playing:
                    state.playerMode = .notPlaying
                    return .concatenate(
                        .cancel(id:CancelID.didPlayToEndTime),
                        .cancel(id: CancelID.play),
                        .send(.playPause))
                }
            case let .gotItemDuration(duration):
                state.playerItemDurationString = self.formattedTimeString(duration)
                state.playerItemDurationSeconds = CMTimeGetSeconds(duration ?? .zero)
                
                return .none
            case let .summaryLoaded(result):
                state.isLoading = false
                
                switch result {
                case let .success(bookSummary):
                    state.bookSummary = bookSummary
                    state.currentChapterIndex = 0
                    
                    return .send(.loadAudioPlayer)
                case .failure:
                    return .none // TODO:
                }
            }
        }
        
    }
    
    public init(environement: BookSummaryPlayerEnvironment) {
        self.environement = environement
    }
    
    func formattedTimeString(_ time: CMTime?) -> String {
        guard let time else { return "00:00" }
        
        let totalSeconds = CMTimeGetSeconds(time)
        let minutes = Int(totalSeconds / 60)
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
