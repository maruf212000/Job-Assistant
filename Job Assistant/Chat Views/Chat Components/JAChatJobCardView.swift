//
//  JAChatJobCardView.swift
//  Job Assistant
//
//  Created by Maruf Memon on 20/01/24.
//

import SwiftUI

struct JARandomAlphabetImage: View {
    let alphabet: String

    var body: some View {
        ZStack {
            Color.blue
            .edgesIgnoringSafeArea(.all)

            Text(alphabet)
                .font(.system(size: 16, weight: .semibold, design: .default))
                .foregroundColor(.white)
        }
        .frame(width: 32, height: 32)
        .cornerRadius(16, corners: .allCorners)
    }
}

struct JAChatJobCardView: View {
    @EnvironmentObject var itemStore: JAChatItemsStore
    
    let jobItem: JAChatJobItem
    
    var body: some View {
        let space: CGFloat = 2;
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top) {
                if let company_name = jobItem.job.company_name {
                    JARandomAlphabetImage(alphabet: String(company_name.prefix(1)).uppercased())
                }
                VStack(alignment: .leading, spacing: space) {
                    if let job_role = jobItem.job.job_role {
                        HStack(spacing: 4) {
                            Text(job_role)
                                .lineLimit(1)
                                .font(Font.system(size: 17, weight: .semibold))
                            Spacer()
                            
                        }
                    }
                    if let company_name = jobItem.job.company_name {
                        Text(company_name)
                            .lineLimit(1)
                            .font(Font.system(size: 13, weight: .medium))
                    }
                    
                    if let job_desc = jobItem.job.job_description?.trimmingCharacters(in: .whitespacesAndNewlines) {
                        Text(job_desc)
                            .lineLimit(1)
                            .font(Font.system(size: 13, weight: .medium))
                    }
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
            .onTapGesture {
                itemStore.addReply(for: jobItem.job)
            }
        }
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(20)
        .onTapGesture {
            
        }
    }
}
