//
//  CalendarEvent.swift
//  Meetings
//
//  Created by Ryan Cavanagh on 4/3/21.
//

import Foundation
import EventKit

struct CalendarEvent {

    let url: URL
    var type: String
    var event: EKEvent? = nil
    
    init(_ event: EKEvent, eventType: String, eventUrl: URL) {
        self.event = event
        self.url = eventUrl
        self.type = eventType
    }
    
    init(eventType: String, eventUrl: URL) {
        self.url = eventUrl
        self.type = eventType
    }
    
}
