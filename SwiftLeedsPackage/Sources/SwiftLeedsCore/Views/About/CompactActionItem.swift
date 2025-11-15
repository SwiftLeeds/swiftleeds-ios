//
//  CompactActionItem.swift
//  SwiftLeeds
//
//  Created by Muralidharan Kathiresan on 09/09/2025.
//

import SwiftUI

struct CompactActionItem: View {
    let icon: String
    let title: String
    let accessibilityHint: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(.accentColor)
                    .frame(height: 32)
                
                Text(title)
                    .font(.caption)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(
                Color.cellBackground,
                in: RoundedRectangle(cornerRadius: Constants.cellRadius)
            )
        }
        .buttonStyle(SquishyButtonStyle())
        .accessibilityHint(accessibilityHint)
    }
}

