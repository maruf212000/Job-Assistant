//
//  JAChatAnswerView.swift
//  Job Assistant
//
//  Created by Maruf Memon on 23/01/24.
//

import SwiftUI

@available(macOS 10.15, *)
struct AnswerViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

struct JAChatAnswerView: View {
    @ObservedObject var answerItem: JAAnswerTextItem
    var isUserReply: Bool = false
    @State var answerHeight: CGFloat = 0
    @EnvironmentObject var itemStore: JAChatItemsStore
    
    init(cardItem: JAAnswerTextItem) {
        self.answerItem = cardItem
        self.isUserReply = cardItem.isUserReply
    }
    
    func updateScrollerIfNeeded() {
        if (answerHeight < (UIScreen.main.bounds.height / 5)) {
            itemStore.updateScroll += 1
        }
    }
    
    var body: some View {
        let width = UIScreen.main.bounds.width * 0.15
        let moreRoundedCorners: RectCorner = isUserReply ? [.bottomLeft, .bottomRight, .topLeft] : [.bottomLeft, .bottomRight, .topRight]
        let lessRoundedCorners: RectCorner = isUserReply ? [.topRight] : [.topLeft]
        if (answerItem.answer.isEmpty) {
            VStack(alignment: .leading) {
                if (answerItem.context.count > 0) {
                    Text(answerItem.context)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color.blue)
                        .padding(.horizontal, 16)
                }
                JAChatTypingIndicatorView()
            }
            .padding(.horizontal, 16)
        } else {
            VStack(spacing: 8) {
                HStack {
                    VStack(alignment: .leading) {
                        if (answerItem.context.count > 0) {
                            Text(answerItem.context)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(Color.blue)
                                .padding(.horizontal, 16)
                        }
                        VStack(alignment: .leading) {
                            Text(answerItem.answer)
                                .padding(.vertical, 10)
                                .padding(.horizontal, 16)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineLimit(nil)
                                .background(GeometryReader {
                                    Color.clear.preference(key: AnswerViewHeightKey.self,
                                                           value: $0.frame(in: .local).size.height)
                                })
                                .onPreferenceChange(AnswerViewHeightKey.self) { height in
                                    answerHeight = height
                                    updateScrollerIfNeeded()
                                }
                                .textSelection(.enabled)
                        }
                        .background(isUserReply ? Color(uiColor: .link) :  Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(20, corners: moreRoundedCorners)
                        .cornerRadius(4, corners: lessRoundedCorners)
                        if (!answerItem.isComplete) {
                            Color.clear
                                .frame(width: 2, height: 36, alignment: .bottom)
                                .id("last item")
                        }
                    }
                    Spacer(minLength: width)
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
