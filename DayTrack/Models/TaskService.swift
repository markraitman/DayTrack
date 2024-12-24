//
//  TaskService.swift
//  DayTrack
//
//  Created by Марк Райтман on 23.12.2024.
//

import Foundation
import EventKit

final class TaskService {
    // MARK: - Init
    init(eventStore: EKEventStore = EKEventStore()) {
            self.eventStore = eventStore
        }

    // MARK: - Properties
    var eventStore = EKEventStore()

    // MARK: - Methods
    /// Requests access to the calendar
    func requestAccess(completion: @escaping (Bool, Error?) -> Void) {
        eventStore.requestAccess(to: .event) { success, error in
            completion(success, error)
        }
    }

    /// Gets events for the specified day
    func fetchEvents(for date: Date) -> [EKEvent] {
        let startDate = date
        let endDate = Calendar.current.date(byAdding: .day, value: 1, to: startDate)!
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        return eventStore.events(matching: predicate)
    }

    /// Saves the event
    func saveEvent(_ event: EKEvent) throws {
        try eventStore.save(event, span: .thisEvent)
    }

    /// Deletes the event
    func deleteEvent(_ event: EKEvent) throws {
        try eventStore.remove(event, span: .thisEvent)
    }

    /// Creates a new event with the specified parameters
    func createEvent(startDate: Date, duration: TimeInterval, title: String) -> EKEvent {
        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.calendar = eventStore.defaultCalendarForNewEvents

        let endDate = Calendar.current.date(byAdding: .second, value: Int(duration), to: startDate)!

        newEvent.startDate = startDate
        newEvent.endDate = endDate
        newEvent.title = title
        return newEvent
    }

    /// Returns an instance of `EKEventStore`
    func getEventStore() -> EKEventStore {
        return eventStore
    }
}
