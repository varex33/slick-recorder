// Result.swift
//
<<<<<<< HEAD
// Copyright (c) 2014–2016 Alamofire Software Foundation (http://alamofire.org/)
=======
// Copyright (c) 2014–2015 Alamofire Software Foundation (http://alamofire.org/)
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/**
    Used to represent whether a request was successful or encountered an error.

    - Success: The request and all post processing operations were successful resulting in the serialization of the 
               provided associated value.
    - Failure: The request encountered an error resulting in a failure. The associated values are the original data 
               provided by the server as well as the error that caused the failure.
*/
<<<<<<< HEAD
public enum Result<Value, Error: ErrorType> {
    case Success(Value)
    case Failure(Error)
=======
public enum Result<Value> {
    case Success(Value)
    case Failure(NSData?, ErrorType)
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31

    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .Success:
            return true
        case .Failure:
            return false
        }
    }

    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }

    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case .Success(let value):
            return value
        case .Failure:
            return nil
        }
    }

<<<<<<< HEAD
    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: Error? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error):
=======
    /// Returns the associated data value if the result is a failure, `nil` otherwise.
    public var data: NSData? {
        switch self {
        case .Success:
            return nil
        case .Failure(let data, _):
            return data
        }
    }

    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: ErrorType? {
        switch self {
        case .Success:
            return nil
        case .Failure(_, let error):
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
            return error
        }
    }
}

// MARK: - CustomStringConvertible

extension Result: CustomStringConvertible {
<<<<<<< HEAD
    /// The textual representation used when written to an output stream, which includes whether the result was a 
    /// success or failure.
=======
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
    public var description: String {
        switch self {
        case .Success:
            return "SUCCESS"
        case .Failure:
            return "FAILURE"
        }
    }
}

// MARK: - CustomDebugStringConvertible

extension Result: CustomDebugStringConvertible {
<<<<<<< HEAD
    /// The debug textual representation used when written to an output stream, which includes whether the result was a
    /// success or failure in addition to the value or error.
=======
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
    public var debugDescription: String {
        switch self {
        case .Success(let value):
            return "SUCCESS: \(value)"
<<<<<<< HEAD
        case .Failure(let error):
            return "FAILURE: \(error)"
=======
        case .Failure(let data, let error):
            if let
                data = data,
                utf8Data = NSString(data: data, encoding: NSUTF8StringEncoding)
            {
                return "FAILURE: \(error) \(utf8Data)"
            } else {
                return "FAILURE with Error: \(error)"
            }
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
        }
    }
}
