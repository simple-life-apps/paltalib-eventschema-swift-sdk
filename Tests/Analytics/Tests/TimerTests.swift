//
//  TimerTests.swift
//  PaltaLibTests
//
//  Created by Vyacheslav Beltyukov on 04.04.2022.
//

import XCTest
import PaltaAnalyticsModel
@testable import PaltaAnalytics

final class TimerTests: XCTestCase {
    func testSchedule() {
        let timerIsFired = expectation(description: "Timer is fired")
        let timerIsntFired = expectation(description: "Timer isn't fired")
        timerIsntFired.isInverted = true

        let dispatchQueue = DispatchQueue(label: "TimerTests.testSchedule")

        TimerImpl().scheduleTimer(timeInterval: 0.05, on: dispatchQueue) {
            timerIsFired.fulfill()
            timerIsntFired.fulfill()
        }

        wait(for: [timerIsntFired], timeout: 0.04)
        wait(for: [timerIsFired], timeout: 0.5)
    }

    func testCancel() {
        let timerIsntFired = expectation(description: "Timer isn't fired")
        timerIsntFired.isInverted = true

        let dispatchQueue = DispatchQueue(label: "TimerTests.testSchedule")

        let token = TimerImpl().scheduleTimer(timeInterval: 0.02, on: dispatchQueue) {
            timerIsntFired.fulfill()
        }

        token.cancel()

        wait(for: [timerIsntFired], timeout: 0.5)
    }

    func testCancelAfterDelay() {
        let timerIsntFired = expectation(description: "Timer isn't fired")
        timerIsntFired.isInverted = true

        let dispatchQueue = DispatchQueue(label: "TimerTests.testSchedule")

        let token = TimerImpl().scheduleTimer(timeInterval: 0.02, on: dispatchQueue) {
            timerIsntFired.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            token.cancel()
        }

        waitForExpectations(timeout: 0.5) { _ in
        }
    }
}
