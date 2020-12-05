//
//  AwaitExtensions.swift
//  UnitTests
//
//  Created by Petr Pavlik on 17/04/2020.
//

import XCTest
import ReactiveSwift

public extension XCTestCase {

    // Returns after the stream completes, so you probably want to use `.take(first: 3)` or something like that.
    func awaitValues<T, E: Error>(_ signal: Signal<T, E>, timeout: TimeInterval = 5, executeBeforeWait: (() -> Void)? = nil) -> Result<[T], E> {

        var resultToReturn: Result<[T], E>!
        let resultExpectation = expectation(description: "expectation for: \(signal)")

        signal
            .collect()
            .observeResult { (result) in
                resultToReturn = result
                resultExpectation.fulfill()
        }

        executeBeforeWait?()

        wait(for: [resultExpectation], timeout: timeout)

        return resultToReturn
    }

    // Returns after receiving first value.
    func awaitValue<T, E: Error>(_ signal: Signal<T, E>, timeout: TimeInterval = 5, executeBeforeWait: (() -> Void)? = nil) throws -> Result<T, E> {

        var resultToReturn: Result<T, E>!
        var fullfilmentCount = 0
        let resultExpectation = expectation(description: "expectation for: \(signal)")
        resultExpectation.assertForOverFulfill = false

        signal
            .observeResult { (result) in
                resultToReturn = result
                fullfilmentCount += 1
                resultExpectation.fulfill()
        }

        executeBeforeWait?()

        wait(for: [resultExpectation], timeout: timeout)

        guard fullfilmentCount == 1 else {
            throw NSError(domain: "com.perrystreet.await", code: 0, userInfo: [NSLocalizedDescriptionKey: "received \(fullfilmentCount) values, expected 1"])
        }

        return resultToReturn
    }

    // Returns after receiving first value.
    func awaitValue<T, E: Error>(_ signalProducer: SignalProducer<T, E>, timeout: TimeInterval = 5) throws -> Result<T, E> {

        var resultToReturn: Result<T, E>!
        var fullfilmentCount = 0
        let resultExpectation = expectation(description: "expectation for: \(signalProducer)")
        resultExpectation.assertForOverFulfill = false

        signalProducer.startWithResult { result in
            resultToReturn = result
            fullfilmentCount += 1
            resultExpectation.fulfill()
        }

        wait(for: [resultExpectation], timeout: timeout)

        guard fullfilmentCount == 1 else {
            throw NSError(domain: "com.perrystreet.await", code: 0, userInfo: [NSLocalizedDescriptionKey: "received \(fullfilmentCount) values, expected 1"])
        }

        return resultToReturn
    }

    func awaitValues<T, E: Error>(_ signalProducer: SignalProducer<T, E>, timeout: TimeInterval = 5) throws -> Result<[T], E> {

        var resultToReturn: Result<[T], E>!
        let resultExpectation = expectation(description: "expectation for: \(signalProducer)")

        signalProducer.collect().startWithResult { result in
            resultToReturn = result
            resultExpectation.fulfill()
        }

        wait(for: [resultExpectation], timeout: timeout)

        return resultToReturn
    }

    func awaitCompleted<T, E: Error>(_ signalProducer: SignalProducer<T, E>, timeout: TimeInterval = 5) throws {

        let resultExpectation = expectation(description: "expectation for: \(signalProducer)")
        resultExpectation.assertForOverFulfill = false

        signalProducer.startWithCompleted {
            resultExpectation.fulfill()
        }

        wait(for: [resultExpectation], timeout: timeout)
    }
}
