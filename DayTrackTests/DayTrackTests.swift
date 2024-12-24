//
//  DayTrackTests.swift
//  DayTrackTests
//
//  Created by Марк Райтман on 16.12.2024.
//

import XCTest
import EventKit
@testable import DayTrack

final class DayTrackTests: XCTestCase {

    var taskService: TaskService!
    
    override func setUpWithError() throws {
        taskService = TaskService()
    }

    override func tearDownWithError() throws {
        taskService = nil
    }

    class MockEventStore: EKEventStore {
        var savedEvents: [EKEvent] = []

        override func save(_ event: EKEvent, span: EKSpan, commit: Bool) throws {
            savedEvents.append(event)
        }
    }

    func testSaveEvent() throws {
        // Given
        let mockEventStore = MockEventStore()
        let taskService = TaskService(eventStore: mockEventStore)
        
        let event = EKEvent(eventStore: mockEventStore)
        event.title = "Test Event"
        
        // When
        try taskService.saveEvent(event)
        
        // Then
        XCTAssertEqual(mockEventStore.savedEvents.count, 1, "The event must be saved")
        XCTAssertEqual(mockEventStore.savedEvents.first?.title, "Test Event", "The title of the saved event must be 'Test Event'")
    }

    func testCreateEvent() throws {
        // Given
        let startDate = Date()
        let duration: TimeInterval = 3600
        let title = "Test Event"
        
        // When
        let event = taskService.createEvent(startDate: startDate, duration: duration, title: title)
        
        // Then
        XCTAssertEqual(event.title, title, "The event header must matc")
        XCTAssertEqual(event.endDate.timeIntervalSince(event.startDate), duration, "The duration of the event should coincide")
        
        // Comparing only the date components
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: startDate)
        let eventComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: event.startDate)
        XCTAssertEqual(startComponents, eventComponents, "The start date of the event must match to the second")
    }
}
