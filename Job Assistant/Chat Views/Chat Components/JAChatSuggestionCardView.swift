//
//  JAChatSuggestionCardView.swift
//  Job Assistant
//
//  Created by Maruf Memon on 23/01/24.
//

import SwiftUI

struct JAChatSuggestionCardView: View {
    @EnvironmentObject var itemStore: JAChatItemsStore
    
    let item: JAChatSuggestionItem
    
    var body: some View {
        VStack {
            HStack {
                Text(item.title)
                    .font(.system(size: 15))
                    .lineLimit(2)
                    .foregroundColor(Color.white)
                Image(systemName: "arrow.up.forward")
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(Color.white)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 12, height: 12)
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 16)
        }
        .background(Color(uiColor: .darkGray))
        .cornerRadius(20)
        .onTapGesture {
            itemStore.userQuery(item.title, isFromSuggestionItem: true)
        }
    }
}
