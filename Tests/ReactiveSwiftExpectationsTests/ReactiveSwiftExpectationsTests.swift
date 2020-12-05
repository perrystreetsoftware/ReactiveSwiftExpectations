import XCTest
import ReactiveSwift
@testable import ReactiveSwiftExpectations

final class ReactiveSwiftExpectationsTests: XCTestCase {
    
    func testAwaitSignalValue() throws {
        let property = MutableProperty<Bool>(false)
        let value = try awaitValue(property.signal, executeBeforeWait: { property.value = true }).valueOrThrow()
        XCTAssertEqual(value, true)
    }

    func testAwaitSignalValueFail() throws {
        let property = MutableProperty<Bool>(false)

        XCTAssertThrowsError(try awaitValue(property.signal, executeBeforeWait: {
            property.value = true
            property.value = false
        }))
    }

    func testAwaitSignalValues() throws {
        let property = MutableProperty<Bool>(false)
        let values = try awaitValues(property.signal.take(first: 2), executeBeforeWait: {
            property.value = true
            property.value = false
        }).valueOrThrow()

        XCTAssertEqual(values, [true, false])
    }

    func testAwaitSignalProducerValueFail() throws {
        let signalProducer = SignalProducer<Bool, Error> { (a, _) in
            a.send(value: true)
            a.send(value: false)
            a.sendCompleted()
        }
        XCTAssertThrowsError(try awaitValue(signalProducer))
    }

    func testAwaitSignalProducerValues() throws {
        let signalProducer = SignalProducer<Bool, Error> { (a, _) in
            a.send(value: true)
            a.send(value: false)
            a.sendCompleted()
        }

        let values = try awaitValues(signalProducer).valueOrThrow()

        XCTAssertEqual(values, [true, false])
    }

    static var allTests = [
        ("testAwaitSignalValue", testAwaitSignalValue),
        ("testAwaitSignalValueFail", testAwaitSignalValueFail),
        ("testAwaitSignalValues", testAwaitSignalValues),
        ("testAwaitSignalProducerValueFail", testAwaitSignalProducerValueFail),
        ("testAwaitSignalProducerValues", testAwaitSignalProducerValues)
    ]
}
