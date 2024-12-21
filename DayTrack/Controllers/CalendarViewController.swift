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

class CalendarViewController: DayViewController, EKEventEditViewDelegate  {
    
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
        
        if let topController = navigationController?.topViewController, topController is EKEventViewController {
            navigationController?.popViewController(animated: true)
        }
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
    
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        endEventEditing()
        guard let ckEvent = eventView.descriptor as? EKWrapper else { return }
        beginEditing(event: ckEvent, animated: true)
    }
    
    override func dayView(dayView: DayView, didUpdate event: any EventDescriptor) {
        guard let editingEvent = event as? EKWrapper else { return }
        if let originalEvent = event.editedEvent {
            editingEvent.commitEditing()
            
            if originalEvent === editingEvent {
                presentEditingViewForEvent(editingEvent.ekEvent)
            } else {
                try! eventStore.save(editingEvent.ekEvent, span: .thisEvent)
            }
        }
        reloadData()
    }
    
    private func presentEditingViewForEvent(_ ekEvent: EKEvent) {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.event = ekEvent
        eventEditViewController.eventStore = eventStore
        eventEditViewController.editViewDelegate = self
        present(eventEditViewController, animated: true, completion: nil)
    }
    
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        endEventEditing()
        reloadData()
        controller.dismiss(animated: true, completion: nil)
    }
    
    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
    }
    
    override func dayViewDidBeginDragging(dayView: DayView) {
        endEventEditing()
    }
    
    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        let newEKEvent = EKEvent(eventStore: eventStore)
        newEKEvent.calendar = eventStore.defaultCalendarForNewEvents
        
        var oneHourComponents = DateComponents()
        oneHourComponents.hour = 1
        
        let endDate = Calendar.current.date(byAdding: oneHourComponents, to: date)!
        
        newEKEvent.startDate = date
        newEKEvent.endDate = endDate
        newEKEvent.title = "New Event"
        
        let newEKWrapper = EKWrapper(eventKitEvent: newEKEvent)
        newEKWrapper.editedEvent = newEKWrapper
        
        create(event: newEKWrapper, animated: true)
    }
    
}
