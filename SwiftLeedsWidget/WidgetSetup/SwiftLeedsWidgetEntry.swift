//
//  SwiftLeedsWidgetEntry.swift
//  SwiftLeedsWidgetExtension
//
//  Created by Karim Ebrahem on 11/09/2022.
//  

import WidgetKit
import SwiftUI

struct SwiftLeedsWidgetEntry: TimelineEntry {
    var date: Date
    let slot: Schedule.Slot
}
