//
//  MeetingWidget.swift
//  MeetingWidget
//
//  Created by Ryan Cavanagh on 4/1/21.
//

import WidgetKit
import SwiftUI
import EventKit

var widgetInstance = CalEventView()

struct Provider: TimelineProvider {
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), event: CalendarEvent(EKEvent(), eventType: "Loading", eventUrl: URL(string: "www.cavanagh.dev")!))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), event: CalendarEvent(EKEvent(), eventType: "Loading", eventUrl: URL(string: "www.cavanagh.dev")!))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        widgetInstance = CalEventView()
        let currentDate = Date()
        let timeLine = widgetInstance.getTimeline()
        let events = widgetInstance.getEvents()
        for i in 0 ..< (timeLine.count) {
            let entryDate = Calendar.current.date(byAdding: .second, value: timeLine[i], to: currentDate)!
            let entry = SimpleEntry(date: entryDate, event: events[i])
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let event: CalendarEvent
}

struct MeetingWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        theWidgetView(event: entry.event)
    }
}

@main
struct MeetingWidget: Widget {
    let kind: String = "MeetingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "UpNext", provider: Provider()) { entry in
            MeetingWidgetEntryView(entry: entry)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(widgetInstance.returnColor(event: entry.event))
                .widgetURL(URL(string: "launch-meeting://widget/\(widgetInstance.returnUrl())"))
        }
        .configurationDisplayName("Up Next")
        .description("Quick Launch your Event.")
        
    }
}

struct MeetingWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            theWidgetView(event: widgetInstance.getEvents()[0])
                .previewContext(WidgetPreviewContext(family: .systemSmall))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(widgetInstance.returnColor(event: CalendarEvent(EKEvent(), eventType: "Next", eventUrl: URL(string: "www.google.com")!)))
            //                .widgetURL(URL(string: "www.google.com"))
//            CalEventView()
//                .previewContext(WidgetPreviewContext(family: .systemSmall))
//                .widgetURL(URL(string: "www.google.com"))
        }
        
    }
}
