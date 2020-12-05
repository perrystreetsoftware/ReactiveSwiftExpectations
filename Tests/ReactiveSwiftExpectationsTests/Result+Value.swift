//
//  Result+Value.swift
//  Husband Material
//
//  Created by Petr Pavlik on 14/01/2020.
//

import Foundation

extension Result {

    init(success: Success) {
        self = .success(success)
    }

    var value: Success? {
        switch self {
        case let .success(value): return value
        case .failure: return nil
        }
    }

    var error: Failure? {
        switch self {
        case .success: return nil
        case let .failure(error): return error
        }
    }

    func valueOrThrow() throws -> Success {
        switch self {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}
