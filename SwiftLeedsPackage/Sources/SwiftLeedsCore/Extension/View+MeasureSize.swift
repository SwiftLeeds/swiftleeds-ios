//
//  View+MeasureSize.swift
//  SwiftLeeds
//
//  Created by Alex Logan on 17/07/2022.
//

import Foundation
import SwiftUI

struct SizePreferenceKey: PreferenceKey {
  static var defaultValue: CGSize = .zero

  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
      if nextValue() == .zero { return }
      value = nextValue()
  }
}

struct SizeMeasuringModifier: ViewModifier {
  func body(content: Content) -> some View {
    content.background(GeometryReader { geometry in
       Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
    })
  }
}

extension View {
  func measureSize(perform action: @escaping (CGSize) -> Void) -> some View {
    self.modifier(SizeMeasuringModifier())
      .onPreferenceChange(SizePreferenceKey.self, perform: action)
  }
}
