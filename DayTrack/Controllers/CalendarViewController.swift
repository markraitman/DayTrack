//
//  ViewController.swift
//  DayTrack
//
//  Created by Марк Райтман on 16.12.2024.
//

import UIKit
import CalendarKit
import EventKit
import EventKitUI

class CalendarViewController: DayViewController  {
    
    // MARK: - Properties
    private let eventStore = EKEventStore()
    
    
    // MARK: - UI Components
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "DayTrack"
        
        requestAccessToCalendar()
        subscribeToNotifications()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }
    
    
    // MARK: - Methods
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: .event) {success, error in
            
        }
    }
    
    override func eventsForDate(_ date: Date) -> [any EventDescriptor] {
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        let endDate = calendar.date(byAdding: oneDayComponents, to: startDate)!
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let eventKitEvents = eventStore.events(matching: predicate)
        
        let calendarKitEvents = eventKitEvents.map(EKWrapper.init)
        
        return calendarKitEvents
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: eventStore)
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        reloadData()
    }
    
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? EKWrapper else { return }
        
        let ekEvent = ckEvent.ekEvent
        let eventViewController = EKEventViewController()
        eventViewController.event = ekEvent
        eventViewController.allowsCalendarPreview = true
        eventViewController.allowsEditing = true
        navigationController?.pushViewController(eventViewController, animated: true)
    }
    
    
    
}

