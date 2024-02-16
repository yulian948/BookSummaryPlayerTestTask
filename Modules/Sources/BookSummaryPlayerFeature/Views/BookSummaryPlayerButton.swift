//
//  BookSummaryPlayerButton.swift
//  BookSummaryPlayerTestTask
//
//  Created by Yulian on 23.01.2024.
//

import SwiftUI

import Resources

enum BookSummaryPlayerButtonType {
    case previous
    case backward5sec
    case play
    case pause
    case forward10sec
    case next

    var systemImage: Image {
        switch self {
        case .previous:
            Image(systemName: "backward.end.fill")
        case .backward5sec:
            Image(systemName: "gobackward.5")
        case .play:
            Image(systemName: "play.fill")
        case .pause:
            Image(systemName: "pause.fill")
        case .forward10sec:
            Image(systemName: "goforward.10")
        case .next:
            Image(systemName: "forward.end.fill")
        }
    }
    
    var size: CGFloat {
        switch self {
        case .play, .pause: 40
        case .backward5sec, .forward10sec: 29
        case .previous, .next: 23
        }
    }
}

struct BookSummaryPlayerButton: View {
    let type: BookSummaryPlayerButtonType
    let disabled: Bool
    let action: (() -> Void)?
    
    init(_ type: BookSummaryPlayerButtonType, disabled: Bool = false, action: (() -> Void)? = nil) {
        self.type = type
        self.action = action
        self.disabled = disabled
    }
    
    var body: some View {
        return Button(action: { action?() } , label: {
            type.systemImage
        })
        .buttonStyle(BookSummaryPlayerButtonStyle(size: type.size, isDisabled: disabled))
        .disabled(disabled)
    }
}

struct BookSummaryPlayerButtonStyle: ButtonStyle {
    var size: CGFloat
    var isDisabled: Bool
    
    func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding()
                .font(.system(size: size, weight: .medium))
                .foregroundStyle(isDisabled
                                 ? Color.playerGray
                                 : Color.playerButtonForeground)
                .scaleEffect(configuration.isPressed
                             ? 0.85
                             : 1.0)
                .background(Circle()
                    .fill(configuration.isPressed
                          ? Color.playerGray
                          : .clear)
                        .scaleEffect(0.85))
        }
}
