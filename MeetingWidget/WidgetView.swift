//
//  WidgetView.swift
//  Meetings
//
//  Created by Ryan Cavanagh on 4/3/21.
//

import SwiftUI
import WidgetKit
import EventKit

struct CalEventView {
    private var calEvent: [CalendarEvent]!
    let eventStore = EKEventStore()
    private var timeLine = [0]

    init() {
        self.calEvent = self.createCalendarEvents()
    }
    
    func getEvents() -> [CalendarEvent] {
        return calEvent
    }
    
    mutating func createCalendarEvents() -> [CalendarEvent] {
        let fetch = fetchWidgetEvents()
        var temp = [CalendarEvent]()
        let currentDate = Date()
        var timeDiffStart = 0
        var timeDiffEnd = 0
        var currType = ""
        var previous = 0
        
        for event in fetch {
            if event.isAllDay {
                continue
            }
            currType = findType(event: event)
            if currType != "Current" {
                timeDiffStart = findSecDiff(currTime: currentDate, endTime: event.startDate)
            }
            timeDiffEnd = findSecDiff(currTime: currentDate, endTime: event.endDate)
            if fetch.isEmpty {
                if currType == "Current" {
                    if timeDiffEnd > 300 {
                        timeLine.append(timeDiffEnd - 300)
                        temp.append(CalendarEvent(event, eventType: currType, eventUrl: findURL(notes: event.notes ?? "www.cavanagh.dev")))
                        previous = timeDiffEnd - 300
                    }
                }
                else {
                    if timeDiffEnd - timeDiffStart > 600 {
                        timeLine.append(timeDiffStart)
                        timeLine.append(timeDiffEnd - 300)
                        temp.append(CalendarEvent(event, eventType: currType, eventUrl: findURL(notes: event.notes ?? "www.cavanagh.dev")))
                        temp.append(CalendarEvent(event, eventType: "Current", eventUrl: findURL(notes: event.notes ?? "www.cavanagh.dev")))
                        previous = timeDiffEnd - 300
                    }
                }
            }
            else {
                if currType == "Current" {
                    if timeDiffEnd - 600 > previous {
                        timeLine.append(timeDiffEnd - 300)
                        temp.append(CalendarEvent(event, eventType: currType, eventUrl: findURL(notes: event.notes ?? "www.cavanagh.dev")))
                        previous = timeDiffEnd - 300
                    }
                }
                else {
                    //meeting start after the previous
                    if (timeDiffStart > previous) {
                        //meeting is at least 10 minutes
                        if timeDiffEnd - timeDiffStart > 600 {
                            timeLine.append(timeDiffStart)
                            temp.append(CalendarEvent(event, eventType: currType, eventUrl: findURL(notes: event.notes ?? "www.cavanagh.dev")))
                            temp.append(CalendarEvent(event, eventType: "Current", eventUrl: findURL(notes: event.notes ?? "www.cavanagh.dev")))
                            timeLine.append(timeDiffEnd - 300)
                            previous = timeDiffEnd - 300
                        }
                    }
                    //meeting starts during previous
                    else {
                        //meeting finishes with at least 10 minutes not overlapped with previous
                        if timeDiffEnd - 600 > previous {
                            timeLine.append(timeDiffEnd - 300)
                            temp.append(CalendarEvent(event, eventType: "Current", eventUrl: findURL(notes: event.notes ?? "www.cavanagh.dev")))
                            previous = timeDiffEnd - 300
                        }
                    }
                }
            }
        }
        let lastTime = findSecDiff(currTime: currentDate, endTime: currentDate.startOfNextDay)
        if previous < lastTime {
            timeLine.append(lastTime + 60)
        }
        temp.append(CalendarEvent(eventType: "No events today.", eventUrl: URL(string: "www.cavanagh.dev")!))
        temp.append(CalendarEvent(eventType: "No events today.", eventUrl: URL(string: "www.cavanagh.dev")!))

        return temp
    }
    
    mutating func findType(event: EKEvent) -> String {
        if event.startDate < Date() && event.endDate > Date() {
            return "Current"
        }
        else {
            return "Next"
        }
    }
    
    func returnColor(event: CalendarEvent) -> LinearGradient {
        if calEvent.isEmpty {
            return LinearGradient(gradient: Gradient(colors: [Color(red: 0.4588, green: 0.0980, blue: 0.0980), Color(red: 0.7137, green: 0.0039, blue: 0.0039)]), startPoint: .leading, endPoint: .trailing)
        }
        else if event.type == "Current"{
            return LinearGradient(gradient: Gradient(colors: [Color(red: 0.4588, green: 0.0980, blue: 0.0980), Color(red: 0.7137, green: 0.0039, blue: 0.0039)]), startPoint: .leading, endPoint: .trailing)
        }
        else {
            return LinearGradient(gradient: Gradient(colors: [Color(red: 0.0, green: 0.2078, blue: 0.5804), Color(red: 0.3804, green: 0.6431, blue: 1.0)]), startPoint: .leading, endPoint: .trailing)
        }
    }
    
    func returnUrl() -> URL {
        if calEvent.isEmpty {
            return URL(string: "https://www.cavanagh.dev")!
        }
        return calEvent[0].url
    }
    
    func getTimeline() -> [Int] {
        print(timeLine)
        return timeLine
    }
    
    func checkForUrls(text: String) -> [URL] {
        let types: NSTextCheckingResult.CheckingType = .link

        do {
            let detector = try NSDataDetector(types: types.rawValue)

            let matches = detector.matches(in: text, options: .reportCompletion, range: NSMakeRange(0, text.count))
        
            return matches.compactMap({$0.url})
        } catch let error {
            debugPrint(error.localizedDescription)
        }

        return []
    }
    
    func findURL(notes: String) -> URL {
        let urls = checkForUrls(text: notes)
        if urls.count == 1 {
            return urls[0]
        }
        else {
            return URL(string: "https://www.cavanagh.dev")!
        }
    }

    func fetchWidgetEvents() -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: Date(), end: Date().startOfNextDay, calendars: nil)
        return eventStore.events(matching: predicate)
    }

    func findSecDiff(currTime: Date, endTime: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: currTime, to: endTime).second!
    }

}

struct theWidgetView: View {
    private var event: EKEvent? = nil
    private var type: String
    
    
    init(event: CalendarEvent) {
        self.event = event.event
        self.type = event.type
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if event == nil {
                Text(type).font(.title2)
            }
            else {
                Text(type).font(.title2).padding(.init(top: 20, leading: 0, bottom: 5, trailing: 0))
                Text(event!.title).font(.title)
                Text(DateFormatter.localizedString(from: event!.startDate, dateStyle: .none, timeStyle: .short) + " - " + DateFormatter.localizedString(from: event!.endDate, dateStyle: .none, timeStyle: .short)).font(.title3)
                Spacer()
            }
        }
    }
}
