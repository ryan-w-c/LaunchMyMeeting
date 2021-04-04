//
//  CalendarEvent.swift
//  Meetings
//
//  Created by Ryan Cavanagh on 4/3/21.
//

import Foundation
import EventKit

struct CalendarEvent {
    let title: String
    let start: Date
    let end: Date
    let url: URL
    var type: String
    let event: EKEvent
    
    init(_ event: EKEvent, eventType: String, eventUrl: URL) {
        self.title = event.title
        self.event = event
        self.start = event.startDate
        self.end = event.endDate
        self.url = eventUrl
        self.type = eventType
    }
    
}
