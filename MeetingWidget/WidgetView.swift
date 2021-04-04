//
//  WidgetView.swift
//  Meetings
//
//  Created by Ryan Cavanagh on 4/3/21.
//

import SwiftUI
import WidgetKit
import EventKit

struct CalEventView: View {
    private var calEvent: [CalendarEvent]!
    let eventStore = EKEventStore()
    var nextInitialized = false
    var nextTime: Date = Date()

    init() {
        self.calEvent = self.createCalendarEvents()
    }
    
    mutating func createCalendarEvents() -> [CalendarEvent] {
        let fetch = fetchWidgetEvents()
        var temp = [CalendarEvent]()
        for event in fetch {
            temp.append(CalendarEvent(event, eventType: findType(event: event), eventUrl: findURL(notes: event.notes!)))
        }
        return temp
    }
    
    mutating func findType(event: EKEvent) -> String {
        if event.startDate < Date() && event.endDate < Date() {
            return "Past"
        }
        else if event.startDate < Date() && event.endDate > Date() {
            return "Current"
        }
        else if !nextInitialized {
            nextInitialized = true
            nextTime = event.startDate
            return "Next"
        }
        else if nextInitialized && event.startDate == nextTime {
            return "Next"
        }
        else {
            return "Upcoming"
        }
    }
    
    func returnTime() -> Date {
        return calEvent[0].end
    }
    
    mutating func current() -> Bool {
        var currType = findType(event: calEvent[0].event)
        if currType == "Past" {
            return false
        }
        else {
            calEvent[0].type = findType(event: calEvent[0].event)
            return true
        }
    }
    
    mutating func removeCurrent() {
        while !current() {
            calEvent.remove(at: 0)
        }
    }
    
    func returnUrl() -> URL {
        return calEvent[0].url
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
            return URL(string: "www.cavanagh.dev")!
        }
    }

    func fetchWidgetEvents() -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: Date(), end: Date().startOfNextDay, calendars: nil)
        return eventStore.events(matching: predicate)
    }

    func findSecDiff(endTime: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: Date(), to: endTime).second!
    }

    var body: some View {
        VStack(alignment: .leading) {
            if calEvent.count == 0 {
                Text("No events today.")
            }
            else {
                Text(calEvent[0].type).font(.title2).padding(.init(top: 20, leading: 0, bottom: 5, trailing: 0))
                Text(calEvent[0].title).font(.title)
                Text(DateFormatter.localizedString(from: calEvent[0].start, dateStyle: .none, timeStyle: .short) + " - " + DateFormatter.localizedString(from: calEvent[0].end, dateStyle: .none, timeStyle: .short)).font(.title3)
                Spacer()
            }
        }
    }
}


struct WidgetView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CalEventView()
                .previewLayout(.fixed(width: 160, height: 160))
        }
    }
}
