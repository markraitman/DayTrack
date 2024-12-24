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

    // MARK: - Lifecycle
    /// Installing custom view
    override func loadView() {
        let customView = DayTrackView()
        self.view = customView
        self.dayView = customView.dayView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupController()
        requestAccessToCalendar()
        subscribeToNotifications()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: false)
    }

    // MARK: - Setup
    private func setupController() {
        title = "DayTrack"
    }

    // MARK: - Methods

    // MARK: Calendar Access
    func requestAccessToCalendar() {
            taskService.requestAccess { success, _ in
                if success {
                    // Access granted, handle accordingly
                } else {
                    // Handle the error if needed
                }
            }
        }

    // MARK: Notifications
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: taskService.getEventStore())
    }
    @objc private func storeChanged(_ notification: Notification) {
        reloadData()

        if let topController = navigationController?.topViewController, topController is EKEventViewController {
            navigationController?.popViewController(animated: true)
        }
    }

    // MARK: Event Handling
    /// Fetching tasks
    override func eventsForDate(_ date: Date) -> [any EventDescriptor] {
        var oneDayComponents = DateComponents()
        oneDayComponents.day = 1
        let events = taskService.fetchEvents(for: date)
        let calendarKitEvents = events.map(EKWrapper.init)

        return calendarKitEvents
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

    /// Task update
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

    /// Event editing
    private func presentEditingViewForEvent(_ ekEvent: EKEvent) {
        let eventEditViewController = EKEventEditViewController()
        eventEditViewController.event = ekEvent
        eventEditViewController.eventStore = taskService.getEventStore()
        eventEditViewController.editViewDelegate = self
        present(eventEditViewController, animated: true, completion: nil)
    }

    /// Event selection
    override func dayView(dayView: DayView, didTapTimelineAt date: Date) {
        endEventEditing()
    }

    /// Event dragging
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

    /// Dismissing editing view controller after "cancel" or "done"
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        endEventEditing()
        reloadData()
        controller.dismiss(animated: true, completion: nil)
    }
}
