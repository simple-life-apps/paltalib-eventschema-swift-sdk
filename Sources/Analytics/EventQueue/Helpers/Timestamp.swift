//
//  Timestamp.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 07/06/2022.
//

import Foundation

#if DEBUG
var mockedTimestamp: Int?
#endif

func currentTimestamp() -> Int {
    #if DEBUG
    return mockedTimestamp ?? realCurrentTimestamp()
    #else
    return realCurrentTimestamp()
    #endif
}

private func realCurrentTimestamp() -> Int {
    appStartTimestamp + getClock() - appStartClock
}

private var appStartTimestamp: Int {
    if let _appStartTimestamp = _appStartTimestamp {
        return _appStartTimestamp
    } else {
        recordTime()
        return _appStartTimestamp!
    }
}

private var appStartClock: Int {
    if let _appStartClock = _appStartClock {
        return _appStartClock
    } else {
        recordTime()
        return _appStartClock!
    }
}

private func getClock() -> Int {
    let nanosecs = clock_gettime_nsec_np(CLOCK_MONOTONIC_RAW)
    return Int(nanosecs / 1_000_000)
}

private var _appStartTimestamp: Int?
private var _appStartClock: Int?

private func recordTime() {
    _appStartTimestamp = Int((Date().timeIntervalSince1970 * 1000).rounded())
    _appStartClock = getClock()
}
