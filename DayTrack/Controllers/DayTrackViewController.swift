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

class DayTrackViewController: DayViewController, EKEventEditViewDelegate {

    // MARK: - Properties
    private let taskService = TaskService()

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

    /// Access to Apple Calendar app
    func requestAccessToCalendar() {
            taskService.requestAccess { success, _ in
                if success {
                    // Access granted, handle accordingly
                } else {
                    // Handle the error if needed
                }
            }
        }

    /// Fetching tasks
    override func eventsForDate(_ date: Date) -> [any EventDescriptor] {
        let startDate = date
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        let events = taskService.fetchEvents(for: date)
        let calendarKitEvents = events.map(EKWrapper.init)

        return calendarKitEvents
    }

    /// Notifications fo task changes
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: taskService.getEventStore())
    }
    @objc private func storeChanged(_ notification: Notification) {
        reloadData()

        if let topController = navigationController?.topViewController, topController is EKEventViewController {
            navigationController?.popViewController(animated: true)
        }
    }

    /// Day task selection and display
    override func dayViewDidSelectEventView(_ eventView: EventView) {
        guard let ckEvent = eventView.descriptor as? EKWrapper else { return }

        let ekEvent = ckEvent.ekEvent
        let eventViewController = EKEventViewController()
        eventViewController.event = ekEvent
        eventViewController.allowsCalendarPreview = true
        eventViewController.allowsEditing = true
        navigationController?.pushViewController(eventViewController, animated: true)
    }

    /// Long press on task observing
    override func dayViewDidLongPressEventView(_ eventView: EventView) {
        endEventEditing()
        guard let ckEvent = eventView.descriptor as? EKWrapper else { return }
        beginEditing(event: ckEvent, animated: true)
    }

    /// Task editing
    override func dayView(dayView: DayView, didUpdate event: any EventDescriptor) {
        guard let editingEvent = event as? EKWrapper else { return }
        if let originalEvent = event.editedEvent {
            editingEvent.commitEditing()

            if originalEvent === editingEvent {
                presentEditingViewForEvent(editingEvent.ekEvent)
            } else {
                do {
                    try taskService.saveEvent(editingEvent.ekEvent)
                } catch {
                    print("Failed to save event: \(error.localizedDescription)")
                }
            }
        }
        reloadData()
    }
    private func presentEditingViewForEvent(_ ekEvent: EKEvent) {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.event = ekEvent
        eventEditViewController.eventStore = taskService.getEventStore()
        eventEditViewController.editViewDelegate = self
        present(eventEditViewController, animated: true, completion: nil)
    }

    /// Dismissing editing view controller after "cancel" or "done"
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

    /// Creating new task
    override func dayView(dayView: DayView, didLongPressTimelineAt date: Date) {
        let newEvent = taskService.createEvent(startDate: date, duration: 3600, title: "New Task")

        let newEKWrapper = EKWrapper(eventKitEvent: newEvent)
        newEKWrapper.editedEvent = newEKWrapper

        create(event: newEKWrapper, animated: true)
    }
}
