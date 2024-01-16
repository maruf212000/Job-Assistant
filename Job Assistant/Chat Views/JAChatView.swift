//
//  JAChatView.swift
//  Job Assistant
//
//  Created by Maruf Memon on 16/01/24.
//

import SwiftUI

struct JAChatView: View {
    @ObservedObject var itemStore: JAChatItemsStore = JAChatItemsStore()
    @State private var userInput: String = ""
    //    @State private var showInput: Bool = false
    //    @State private var focusTextField: Bool = false
    @State var wholeSize: CGSize = .zero
    @State var scrollViewSize: CGSize = .zero
    let spaceName = "chat scroll view"
    @ObservedObject var keyboard = KeyboardResponder()
    
    func chatDidLoad() {
        if (itemStore.items.count == 0) {
            itemStore.initializeChat()
        }
    }
    
    func endEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func textView(textItem: JAChatTextItem) -> some View {
        let width = UIScreen.main.bounds.width * 0.15
        
        if (textItem.isUserReply) {
            return AnyView(HStack {
                Spacer(minLength: width)
                JAChatTextView(cardItem: textItem)
            })
            .padding(.horizontal, 16)
        } else {
            return AnyView(HStack {
                JAChatTextView(cardItem: textItem)
                Spacer(minLength: width)
            })
            .padding(.horizontal, 16)
        }
    }
    
    func sectionView() -> some View {
        let rootView: some View = LazyVStack(alignment: .leading) {
            ForEach(itemStore.items, id: \.id) { item in
                if (item.type == .chatItemTextType) {
                    let textItem = item as! JAChatTextItem
                    let anchor = textItem.isUserReply ? UnitPoint.topTrailing : UnitPoint.topLeading
                    textView(textItem: textItem)
                        .transition(AnyTransition.scaleInAndFadeOut(anchor: anchor))
                        .id(item.id)
                }
            }
        }
            .padding(.vertical, 16)
        return JAChildSizeReader(size: $wholeSize) {
            ScrollView(showsIndicators: false) {
                JAChildSizeReader(size: $scrollViewSize) {
                    rootView
                        .background(
                            GeometryReader { proxy in
                                Color.clear.preference(
                                    key: JAViewOffsetKey.self,
                                    value: -1 * proxy.frame(in: .named(spaceName)).origin.y
                                )
                            }
                        )
                        .onPreferenceChange(
                            JAViewOffsetKey.self,
                            perform: { value in
                                if value >= scrollViewSize.height - wholeSize.height - 20 {
                                    itemStore.shouldScrollToBottom = true
                                } else {
                                    itemStore.shouldScrollToBottom = false
                                }
                            }
                        )
                }
            }
            .coordinateSpace(name: spaceName)
            .frame(maxWidth: .infinity)
            .onAppear() {
                chatDidLoad()
            }
        }
    }
    
    func textField() -> some View {
        return TextField("Ask me anything...", text: $userInput)
            .padding(.leading, 12)
            .padding(.trailing, 12)
            .padding(Edge.Set([.top, .bottom]), 8)
            .overlay(RoundedRectangle(cornerRadius: 20.0).strokeBorder(Color(uiColor: UIColor.separator), style: StrokeStyle(lineWidth: 1.0)))
            .padding(4)
            .textFieldStyle(PlainTextFieldStyle())
            .onSubmit {
                if (userInput.count > 0) {
                    itemStore.append(JAChatTextItem(title: userInput, isUserReply: true))
                    userInput = ""
                }
            }
    }
    
    func barView() -> some View {
        return HStack {
                textField()
                Button {
                    if (userInput.count > 0) {
                        itemStore.append(JAChatTextItem(title: userInput, isUserReply: true))
                        userInput = ""
                    }
                } label: {
                    Image(systemName: "paperplane.circle.fill")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(Color.blue)
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 34, alignment: .trailing)
                        .rotationEffect(.degrees(45))
                }.buttonStyle(PlainButtonStyle())
            }
            .padding(.top, 4)
            .padding(.bottom, 8)
            .padding(.horizontal, 16)
        }
    
    var body: some View {
            ScrollViewReader { scroller in
                sectionView()
                    .environmentObject(itemStore)
                    .onChange(of: itemStore.items.count) { oldValue, newValue in
                        withAnimation {
                            scroller.scrollTo(itemStore.items.last?.id, anchor: .top)
                        }
                    }.onChange(of: itemStore.updateScroll) { oldValue, newValue in
                        withAnimation {
                            if (itemStore.shouldScrollToBottom) {
                                scroller.scrollTo(itemStore.items.last?.id, anchor: .bottom)
                            }
                        }
                    }.onTapGesture {
                        endEditing()
                    }
            }
            barView()
    }
}

#Preview {
    JAChatView()
}