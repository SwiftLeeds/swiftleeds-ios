//
//  SwiftLeedsWidgetEntry.swift
//  SwiftLeedsWidgetExtension
//
//  Created by Karim Ebrahem on 11/09/2022.
//  

import SwiftLeedsCore
import SwiftUI
import WidgetKit

struct SwiftLeedsWidgetEntry: TimelineEntry {
    var date: Date
    let slot: Schedule.Slot
}
