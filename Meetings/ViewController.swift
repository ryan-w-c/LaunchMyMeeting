//
//  ViewController.swift
//  Meetings
//
//  Created by Ryan Cavanagh on 3/27/21.
//

import Cocoa
import EventKit

class ViewController: NSViewController {
    
    @IBOutlet weak var date: NSTextField!
    @IBOutlet weak var day: NSTextField!
    @IBOutlet weak var time: NSTextField!
    
    var secondTimer = Timer()
    var refreshTimer = Timer()
    var updateTimer = Timer()
    var updateTimerBool = false

    var refreshTime = 15.0 * 60.0
    
    let eventStore = EKEventStore()
        
    var allDayBool = false
    var includeEmptyCategories = false
    var terminator = true
    
    var total = 0.0
    var adjust = 0.0
    var allDayLength = 0.0
    var pastLength = 0.0
    var currentLength = 0.0
    var nextLength = 0.0
    var upcomingLength = 0.0
    var tomorrowLength = 0.0
    
    var colorNum = 0
    
    var events = [EKEvent]()
    var allDay = [EKEvent]()
    var past = [EKEvent]()
    var current = [EKEvent]()
    var next = [EKEvent]()
    var upcoming = [EKEvent]()
    var tomorrow = [EKEvent]()

    @IBOutlet weak var dayView: NSScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        forceRefresh()
        day.font = NSFont(name: "Helvetica Neue", size: CGFloat(23.0))!
        date.font = NSFont(name: "Helvetica Neue", size: CGFloat(30.0))!
        time.font = NSFont(name: "Helvetica Neue", size: CGFloat(23.0))!
        secondTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector:#selector(self.tick), userInfo: nil, repeats: true)
        refreshTimer = Timer.scheduledTimer(timeInterval: refreshTime, target: self, selector:#selector(self.forceRefresh), userInfo: nil, repeats: true)

        eventStore.requestAccess(to: .event) { (granted, error) in
            print(granted)
        }
        
        updateDate()
        refresh()
        NotificationCenter.default.addObserver(self, selector: #selector(refresh), name: .EKEventStoreChanged, object: eventStore)
    }
    
    func findLengths(array: [EKEvent], length: inout Double){
        length = 0.0
        if  !array.isEmpty || includeEmptyCategories {
            length += 77.0
            if (array.isEmpty){
                length += 40
            }
            else {
                length += 12.5 * (Double(array.count) - 1.0) + Double(array.count) * 75
            }
            total += length
        }
    }
    
    @IBAction func refreshButtonPress(_ sender: Any) {
        forceRefresh()
    }
    
    @objc func forceRefresh() {
        updateTimer.invalidate()
        let store = EKEventStore()
        store.refreshSourcesIfNecessary()
        print("refreshed")
        refreshTimer.invalidate()
        refreshTimer = Timer.scheduledTimer(timeInterval: refreshTime, target: self, selector:#selector(self.forceRefresh) , userInfo: nil, repeats: true)
    }
    
    @objc func refresh() {
        updateTimer.invalidate()
        let newEvents = fetchEvents()
        if events != newEvents {
            events = newEvents
            updateTimerBool = false
            updateEvents()
        }
    }
    
    func addCategories(title: String, array: [EKEvent], length: Double, total: Double, newLength: Double, doc: NSView) {
        var index = 0.0
        let tempEvent = NSBox(frame: NSRect(x: atAbsoluteCenter, y: Int(total + adjust - length - newLength), width:455, height:Int(length) ))
        tempEvent.title = "\n" + title
        tempEvent.titleFont = NSFont(name: "Helvetica Neue", size: CGFloat(20.0))!
        tempEvent.borderType = NSBorderType.noBorder
        if array.isEmpty {
            let text = NSTextField(frame: NSRect(x: atAbsoluteCenter, y: -20, width:430, height:65 ))
            text.stringValue = "No \(title) Events."
            text.isEditable = false
            text.font = NSFont(name: "Helvetica Neue", size: CGFloat(15.0))!
            text.isSelectable = false
            text.isBordered = false
            text.alignment = NSTextAlignment.center
            text.drawsBackground = false
            tempEvent.addSubview(text)
        }
        else {
            for event in array.reversed() {
                let button = RoundedColoredButton(frame: NSRect(x: atAbsoluteCenter, y: Int(9 + (index * 75) + (index * 12.5)), width:430, height:75 ))
                index += 1.0
                if event.isAllDay {
                    button.title = "    " + event.title + "\n    All Day\n"
                }
                else {
                    button.title = "    " + event.title + "\n    " + DateFormatter.localizedString(from: event.startDate, dateStyle: .none, timeStyle: .short) + " - " + DateFormatter.localizedString(from: event.endDate, dateStyle: .none, timeStyle: .short) + "\n"
                }
                button.alignment = NSTextAlignment.left
                button.font = NSFont(name: "Helvetica Neue", size: CGFloat(15.0))!
                if event.hasNotes {
                    button.notes = event.notes!
                }
                button.colorCode = colorNum
                if colorNum == 5 {
                    colorNum = 0
                }
                else {
                    colorNum += 1
                }
                button.target = self
                button.isBordered = false
                button.action = #selector(buttonPress(_:))
                tempEvent.addSubview(button)
            }
        }
        doc.addSubview(tempEvent)
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
    
    func updateDate() {
        date.stringValue = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        day.stringValue = DateFormatter.localizedString(from: Date(), dateStyle: .full, timeStyle: .none).components(separatedBy: ", ")[0]
        time.stringValue = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
    }
    
    func fetchEvents() -> [EKEvent] {
        let calendar = Calendar.current
        var component = DateComponents()
        component.day = -1
        let start = calendar.date(byAdding: component, to: Date())!
        component.day = 2
        let end = calendar.date(byAdding: component, to: Date())!
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        return eventStore.events(matching: predicate)
    }
    
    func fetchWidgetEvents() -> [EKEvent] {
        let predicate = eventStore.predicateForEvents(withStart: Date(), end: Date().startOfNextDay, calendars: nil)
        return eventStore.events(matching: predicate)
    }
    
    @objc func updateTimerFinish() {
        updateTimerBool = false
        updateDate()
        updateEvents()
    }
    
    func startUpdateTimer(endTime: Date) {
        updateTimer.invalidate()
        print(findSecDiff(endTime: endTime))
        updateTimer = Timer.scheduledTimer(timeInterval: (Double(findSecDiff(endTime: endTime)) + 2.0), target: self, selector: #selector(self.updateTimerFinish), userInfo: nil, repeats: false)
    }
    
    func findSecDiff(endTime: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: Date(), to: endTime).second!
    }
    
    func findMinDiff(endTime: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: Date(), to: endTime).minute!
    }
    
    func widgetTime(events: [EKEvent]) -> [Int] {
        var widgetRefresh = [Int]()
        for event in events {
            if !event.isAllDay {
                if event.startDate > Date() {
                    widgetRefresh.append(findSecDiff(endTime: event.startDate))
                }
                widgetRefresh.append(findSecDiff(endTime: event.endDate))
            }
        }
        return widgetRefresh
    }
    
    func updateEvents() {
        var nextInitialized = false
        var nextEvent = Date()
        var currentEventTime = Date()
        for event in events {
            //removes events not today or tomorrow
            if (event.startDate < Date().startOfToday && event.endDate <= Date().startOfToday) || (event.startDate >= Date().startOfNextDay.startOfNextDay) {
                continue
            }
            //sorts into correct arrays
            if event.isAllDay && event.startDate <= Date() {
                if allDayBool {
                    allDay.append(event)
                }
            }
            else if event.startDate < Date() && event.endDate < Date() {
                past.append(event)
            }
            else if event.startDate < Date() && event.endDate > Date() {
                current.append(event)
                if !updateTimerBool {
                    currentEventTime = event.endDate
                    startUpdateTimer(endTime: event.endDate)
                    updateTimerBool = true
                }
                else {
                    let newTime = findSecDiff(endTime: event.endDate)
                    if newTime < findSecDiff(endTime: currentEventTime) {
                        currentEventTime = event.endDate
                        startUpdateTimer(endTime: event.endDate)
                    }
                }
            }
            else if event.startDate >= Date().startOfNextDay {
                if (event.isAllDay && allDayBool) || !event.isAllDay {
                    tomorrow.append(event)
                }
            }
            else {
                if nextInitialized {
                    if event.startDate == nextEvent {
                        next.append(event)
                    }
                    else {
                        upcoming.append(event)
                    }
                }
                else {
                    nextInitialized = true
                    nextEvent = event.startDate
                    next.append(event)
                    if !updateTimerBool {
                        currentEventTime = event.startDate
                        startUpdateTimer(endTime: event.startDate)
                        updateTimerBool = true
                    }
                }
            }
        }
        if !updateTimerBool || findSecDiff(endTime: currentEventTime) > findSecDiff(endTime: Date().startOfNextDay){
            startUpdateTimer(endTime: Date().startOfNextDay)
            updateTimerBool = true
        }
        if current.isEmpty && next.isEmpty && upcoming.isEmpty && tomorrow.isEmpty && !includeEmptyCategories {
            if allDay.isEmpty && past.isEmpty {
                currentLength = 77.0 + 40.0
                let documentView = NSView(frame: NSRect(x:0,y:100,width:460,height: 598))
                let tempEvent = NSBox(frame: NSRect(x: atAbsoluteCenter, y: Int(598 - currentLength), width:455, height:Int(currentLength)))
                tempEvent.title = "\n"
                tempEvent.titleFont = NSFont(name: "Helvetica Neue", size: CGFloat(20.0))!
                tempEvent.borderType = NSBorderType.noBorder
                let text = NSTextField(frame: NSRect(x: atAbsoluteCenter, y: -20, width:430, height:65 ))
                text.stringValue = "No events for today and tomorrow."
                text.isEditable = false
                text.font = NSFont(name: "Helvetica Neue", size: CGFloat(15.0))!
                text.isSelectable = false
                text.isBordered = false
                text.alignment = NSTextAlignment.center
                text.drawsBackground = false
                tempEvent.addSubview(text)
                documentView.addSubview(tempEvent)
                dayView.documentView = documentView
            }
            else {
                pastAndDay()
                currentLength = 77.0 + 40.0
                adjust = 598.0
                let documentView = NSView(frame: NSRect(x:0,y:100,width:460,height:Int(total + adjust)))
                total += currentLength

                var newLength = 0.0
                if pastLength > 0 {
                    addCategories(title: "Past", array: past, length: pastLength, total: total - currentLength, newLength: newLength, doc: documentView)
                    newLength += pastLength
                }
                if allDayLength > 0 {
                    addCategories(title: "All Day", array: allDay, length: allDayLength, total: total - currentLength, newLength: newLength, doc: documentView)
                    newLength += allDayLength
                }
//                addCategories(title: "Current", array: current, length: currentLength, total: total - currentLength, newLength: newLength, doc: documentView)
                let tempEvent = NSBox(frame: NSRect(x: atAbsoluteCenter, y: Int(total - currentLength + adjust - currentLength - newLength), width:455, height:Int(currentLength) ))
                tempEvent.title = "\n"
                tempEvent.titleFont = NSFont(name: "Helvetica Neue", size: CGFloat(20.0))!
                tempEvent.borderType = NSBorderType.noBorder
                let text = NSTextField(frame: NSRect(x: atAbsoluteCenter, y: -20, width:430, height:65 ))
                text.stringValue = "No events for the rest of today and tomorrow."
                text.isEditable = false
                text.font = NSFont(name: "Helvetica Neue", size: CGFloat(15.0))!
                text.isSelectable = false
                text.isBordered = false
                text.alignment = NSTextAlignment.center
                text.drawsBackground = false
                tempEvent.addSubview(text)
                documentView.addSubview(tempEvent)
                dayView.documentView = documentView
            }
        }
        else {
            pastAndDay()
            findLengths(array: current, length: &currentLength)
            findLengths(array: next, length: &nextLength)
            findLengths(array: upcoming, length: &upcomingLength)
            findLengths(array: tomorrow, length: &tomorrowLength)
            
            adjust = 598.0 - (currentLength + nextLength + upcomingLength + tomorrowLength)
            if adjust < 0.0 {
                adjust = 0.0
            }
            let documentView = NSView(frame: NSRect(x:0,y:100,width:460,height:Int(total + adjust)))
            var newLength = 0.0
            if pastLength > 0 {
                addCategories(title: "Past", array: past, length: pastLength, total: total, newLength: newLength, doc: documentView)
                newLength += pastLength
            }
            if allDayLength > 0 {
                addCategories(title: "All Day", array: allDay, length: allDayLength, total: total, newLength: newLength, doc: documentView)
                newLength += allDayLength
            }
            if currentLength > 0 {
                addCategories(title: "Current", array: current, length: currentLength, total: total, newLength: newLength, doc: documentView)
                newLength += currentLength
            }
            if nextLength > 0 {
                addCategories(title: "Next Up", array: next, length: nextLength, total: total, newLength: newLength, doc: documentView)
                newLength += nextLength
            }
            if upcomingLength > 0 {
                addCategories(title: "Upcoming", array: upcoming, length: upcomingLength, total: total, newLength: newLength, doc: documentView)
                newLength += upcomingLength
            }
            if tomorrowLength > 0 {
                addCategories(title: "Tomorrow", array: tomorrow, length: tomorrowLength, total: total, newLength: newLength, doc: documentView)
                newLength += tomorrowLength
            }
            dayView.documentView = documentView
//            dayView.documentView?.scroll(CGPoint(x: 0, y: (currentLength + nextLength + upcomingLength + tomorrowLength) - 598))
        }
        dayView.documentView?.scroll(CGPoint(x: 0, y: (currentLength + nextLength + upcomingLength + tomorrowLength) - 598))
        past = []
        allDay = []
        current = []
        next = []
        upcoming = []
        tomorrow = []
    }
    
    func pastAndDay() {
        allDayLength = 0.0
        total = 0.0
        if allDayBool && (!allDay.isEmpty || includeEmptyCategories) {
            allDayLength += 77.0
            if (allDay.isEmpty){
                allDayLength += 40
            }
            else {
                allDayLength += 12.5 * (Double(allDay.count) - 1.0) + Double(allDay.count) * 75
            }
            total += allDayLength
        }
        findLengths(array: past, length: &pastLength)
    }
    
    @objc func buttonPress(_ sender: RoundedColoredButton) {
        let urls = checkForUrls(text: sender.notes)
        if urls.count == 1 {
            NSWorkspace.shared.open(urls[0])
            if terminator {
                NSApplication.shared.terminate(self)
            }
        }
        else {
            let controller = NSViewController()
            controller.view = NSView(frame: CGRect(x: CGFloat(100), y: CGFloat(50), width: CGFloat(250), height: CGFloat(400)))

            let popover = NSPopover()
            popover.contentViewController = controller
            popover.contentSize = controller.view.frame.size

            popover.behavior = .transient
            popover.animates = true
            
            let title = NSTextField(frame: NSRect(x: atAbsoluteCenter, y: 350, width:240, height:40 ))
            title.isSelectable = true
            title.isEditable = false
            title.isBordered = false
            title.drawsBackground = false
            title.stringValue = " Meeting Notes:"
            title.font = NSFont(name: "Helvetica Neue", size: CGFloat(20.0))!
            controller.view.addSubview(title)
            
            //scrollable text view
            let textView:NSTextView?

            let scrollView = NSTextView.scrollableTextView()
            textView = scrollView.documentView as? NSTextView

            textView?.isEditable = false
            textView?.isSelectable = true
            textView?.drawsBackground = false
            
            let attributes = [NSAttributedString.Key.font: NSFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: NSColor.labelColor]
            
            var attributedString = NSMutableAttributedString(string: "This meeting has no notes.", attributes: attributes)
            
            if sender.notes != "" {
                //detects and embeds links from notes
                let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
                let matches = detector.matches(in: sender.notes, options: [], range: NSRange(location: 0, length: sender.notes.utf16.count))

                attributedString = NSMutableAttributedString(string: sender.notes, attributes: attributes)
                if matches.count > 0{
                    for match in matches {
                        guard let range = Range(match.range, in: sender.notes) else { continue }
                        let url = sender.notes[range]

                        attributedString.setAttributes([.link: url, .font: NSFont.systemFont(ofSize: 15)], range: match.range)
                    }
                }
            }
            textView?.textStorage?.setAttributedString(attributedString)
            
            controller.view.addSubview(scrollView)

            scrollView.translatesAutoresizingMaskIntoConstraints = false

            scrollView.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor, constant: 10.0).isActive = true
            scrollView.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor).isActive = true
            scrollView.topAnchor.constraint(equalTo: controller.view.topAnchor, constant: 50.0).isActive = true
            scrollView.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor).isActive = true
            popover.show(relativeTo: sender.bounds, of: sender as NSView, preferredEdge: NSRectEdge.maxX)
        }
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    @objc func tick() {
        time.stringValue = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
    }

}

class RoundedColoredButton: NSButton {
    @IBInspectable var cornerRadius: CGFloat = 20
    @IBInspectable var gradientAngle: CGFloat = 155.0
    @IBInspectable var colorCode = 0
    @IBInspectable var dark: NSColor = .red
    @IBInspectable var light: NSColor = .red
    @IBInspectable var mid: NSColor = .red
    
    @IBInspectable var notes: String = ""
     
    override func draw(_ dirtyRect: NSRect) {
        if colorCode == 0 {
            //Green yellow
            light = NSColor.init(calibratedRed: 0.98, green: 0.98, blue: 0.43, alpha: 1.0)
            mid = NSColor.init(calibratedRed: 0.45, green: 0.52, blue: 0.23, alpha: 1.0)
            dark = NSColor.init(calibratedRed: 0.19, green: 0.23, blue: 0.0, alpha: 1.0)
        }
        else if colorCode == 1 {
            // red
            light = NSColor.init(calibratedRed: 0.91, green: 0.77, blue: 0.77, alpha: 1.0)
            mid = NSColor.init(calibratedRed: 0.77, green: 0.18, blue: 0.19, alpha: 1.0)
            dark = NSColor.init(calibratedRed: 0.51, green: 0.0, blue: 0.0, alpha: 1.0)
        }
        else if colorCode == 2 {
            //purple orange
            light = NSColor.init(calibratedRed: 1.0, green: 0.46, blue: 0.0, alpha: 1.0)
            mid = NSColor.init(calibratedRed: 0.67, green: 0.21, blue: 0.33, alpha: 1.0)
            dark = NSColor.init(calibratedRed: 0.20, green: 0.1333, blue: 0.24, alpha: 1.0)
        }
        else if colorCode == 3{
            //blue
//            light = NSColor.init(calibratedRed: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
//            mid = NSColor.init(calibratedRed: 0.19, green: 0.19, blue: 0.72, alpha: 1.0)
            dark = NSColor.init(calibratedRed: 0.008, green: 0.0, blue: 0.34, alpha: 1.0)
            light = NSColor.init(calibratedRed: 0.0, green: 1.0, blue: 1.0, alpha: 1.0)
            mid = NSColor.init(calibratedRed: 0.13, green: 0.51, blue: 0.69, alpha: 1.0)
//            dark = NSColor.init(calibratedRed: 0.20, green: 0.11, blue: 0.73, alpha: 1.0)
        }
        else if colorCode == 4 {
            //green
            light = NSColor.init(calibratedRed: 0.012, green: 1.0, blue: 0.0, alpha: 1.0)
            mid = NSColor.init(calibratedRed: 0.19, green: 0.66, blue: 0.20, alpha: 1.0)
            dark = NSColor.init(calibratedRed: 0.03, green: 0.32, blue: 0.05, alpha: 1.0)
        }
        else {
            //gray
            light = NSColor.init(calibratedRed: 0.87, green: 0.90, blue: 0.92, alpha: 1.0)
            mid = NSColor.init(calibratedRed: 0.40, green: 0.54, blue: 0.63, alpha: 1.0)
            dark = NSColor.init(calibratedRed: 0.04, green: 0.25, blue: 0.40, alpha: 1.0)
        }
        
        var gradient = NSGradient(colors: [
            light, mid, dark
        ])
        
        // Draw the gradient
        gradient?.draw(in: bounds, angle: gradientAngle)
        
        // set string color
        let attributedString = NSAttributedString(string: title, attributes: [NSAttributedString.Key.foregroundColor: NSColor.white])
        self.attributedTitle = attributedString
        
        // Round Corners
        self.layer?.cornerRadius = cornerRadius
        
        super.draw(dirtyRect)
    }
}

extension Date {
    var startOfNextDay: Date {
        return Calendar.current.nextDate(after: self, matching: DateComponents(hour: 0, minute: 0), matchingPolicy: .nextTimePreservingSmallerComponents)!
    }
    var startOfToday: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
