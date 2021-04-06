//
//  Preferences.swift
//  Meetings
//
//  Created by Ryan Cavanagh on 4/5/21.
//

import Cocoa

class PreferencesViewController: NSViewController {
    @IBOutlet weak var terminate: NSSwitch!
    @IBOutlet weak var allDay: NSSwitch!
    @IBOutlet weak var emptyCat: NSSwitch!
    
    override func viewDidLoad() {
        allDay.state = NSControl.StateValue.init(boolToInt(change: UserDefaults.standard.bool(forKey: "allDay")))
        terminate.state = NSControl.StateValue.init(boolToInt(change: UserDefaults.standard.bool(forKey: "terminate")))
        emptyCat.state = NSControl.StateValue.init(boolToInt(change: UserDefaults.standard.bool(forKey: "emptyCat")))
    }
    
    func boolToInt(change: Bool) -> Int {
        if change == false {
            return 0
        }
        else {
            return 1
        }
    }
    
    func intToBool(change: Int) -> Bool {
        if change == 0 {
            return false
        }
        else {
            return true
        }
    }
    
    @IBAction func toggleTerminate(_ sender: Any) {
        
        UserDefaults.standard.set(intToBool(change: terminate.state.rawValue), forKey: "terminate")
//        print(UserDefaults.standard.bool(forKey: "terminate"))
    }

    @IBAction func toggleAllDay(_ sender: Any) {
        UserDefaults.standard.set(intToBool(change: allDay.state.rawValue), forKey: "allDay")
//        print(UserDefaults.standard.bool(forKey: "allDay"))
    }

    @IBAction func toggleEmpty(_ sender: Any) {
        UserDefaults.standard.set(intToBool(change: emptyCat.state.rawValue), forKey: "emptyCat")
//        print(UserDefaults.standard.bool(forKey: "emptyCat"))
    }
    
}
