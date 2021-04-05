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
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
//        let events = WidgetFunctions().fetchWidgetEvents()
//        let refreshTime = WidgetFunctions().widgetTime(events: events)
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for min in [0,1,2,3,4,5] {
            let entryDate = Calendar.current.date(byAdding: .minute, value: min, to: currentDate)!
            let entry = SimpleEntry(date: entryDate)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
//    let calEvent: [CalendarEvent] = WidgetFunctions().createCalendarEvents()
}

struct MeetingWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        widgetInstance
    }
}

@main
struct MeetingWidget: Widget {
    let kind: String = "MeetingWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "UpNext", provider: Provider()) { entry in
            MeetingWidgetEntryView(entry: entry).frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(LinearGradient(gradient: Gradient(colors: [Color(red: 0.4588, green: 0.0980, blue: 0.0980), Color(red: 0.7137, green: 0.0039, blue: 0.0039)]), startPoint: .leading, endPoint: .trailing))
                .widgetURL(URL(string: "launch-meeting://widget/\( widgetInstance.returnUrl())"))
        }
        .configurationDisplayName("Up Next")
        .description("This shows your newest event.")
        
    }
}

struct MeetingWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CalEventView()
                .previewContext(WidgetPreviewContext(family: .systemSmall))
//                .widgetURL(URL(string: "www.google.com"))
        }
        
    }
}
