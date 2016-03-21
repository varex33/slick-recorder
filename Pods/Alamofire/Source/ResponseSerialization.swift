// ResponseSerialization.swift
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

// MARK: ResponseSerializer

/**
    The type in which all response serializers must conform to in order to serialize a response.
*/
<<<<<<< HEAD
public protocol ResponseSerializerType {
    /// The type of serialized object to be created by this `ResponseSerializerType`.
    typealias SerializedObject

    /// The type of error to be created by this `ResponseSerializer` if serialization fails.
    typealias ErrorObject: ErrorType

    /**
        A closure used by response handlers that takes a request, response, data and error and returns a result.
    */
    var serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Result<SerializedObject, ErrorObject> { get }
=======
public protocol ResponseSerializer {
    /// The type of serialized object to be created by this `ResponseSerializer`.
    typealias SerializedObject

    /**
        A closure used by response handlers that takes a request, response, and data and returns a result.
    */
    var serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?) -> Result<SerializedObject> { get }
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
}

// MARK: -

/**
<<<<<<< HEAD
    A generic `ResponseSerializerType` used to serialize a request, response, and data into a serialized object.
*/
public struct ResponseSerializer<Value, Error: ErrorType>: ResponseSerializerType {
    /// The type of serialized object to be created by this `ResponseSerializer`.
    public typealias SerializedObject = Value

    /// The type of error to be created by this `ResponseSerializer` if serialization fails.
    public typealias ErrorObject = Error

    /**
        A closure used by response handlers that takes a request, response, data and error and returns a result.
    */
    public var serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Result<Value, Error>

    /**
        Initializes the `ResponseSerializer` instance with the given serialize response closure.
=======
    A generic `ResponseSerializer` used to serialize a request, response, and data into a serialized object.
*/
public struct GenericResponseSerializer<T>: ResponseSerializer {
    /// The type of serialized object to be created by this `ResponseSerializer`.
    public typealias SerializedObject = T

    /**
        A closure used by response handlers that takes a request, response, and data and returns a result.
    */
    public var serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?) -> Result<SerializedObject>

    /**
        Initializes the `GenericResponseSerializer` instance with the given serialize response closure.
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31

        - parameter serializeResponse: The closure used to serialize the response.

        - returns: The new generic response serializer instance.
    */
<<<<<<< HEAD
    public init(serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Result<Value, Error>) {
=======
    public init(serializeResponse: (NSURLRequest?, NSHTTPURLResponse?, NSData?) -> Result<SerializedObject>) {
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
        self.serializeResponse = serializeResponse
    }
}

// MARK: - Default

extension Request {

    /**
        Adds a handler to be called once the request has finished.

        - parameter queue:             The queue on which the completion handler is dispatched.
        - parameter completionHandler: The code to be executed once the request has finished.

        - returns: The request.
    */
    public func response(
        queue queue: dispatch_queue_t? = nil,
<<<<<<< HEAD
        completionHandler: (NSURLRequest?, NSHTTPURLResponse?, NSData?, NSError?) -> Void)
=======
        completionHandler: (NSURLRequest?, NSHTTPURLResponse?, NSData?, ErrorType?) -> Void)
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
        -> Self
    {
        delegate.queue.addOperationWithBlock {
            dispatch_async(queue ?? dispatch_get_main_queue()) {
                completionHandler(self.request, self.response, self.delegate.data, self.delegate.error)
            }
        }

        return self
    }

    /**
        Adds a handler to be called once the request has finished.

        - parameter queue:              The queue on which the completion handler is dispatched.
        - parameter responseSerializer: The response serializer responsible for serializing the request, response, 
                                        and data.
        - parameter completionHandler:  The code to be executed once the request has finished.

        - returns: The request.
    */
<<<<<<< HEAD
    public func response<T: ResponseSerializerType>(
        queue queue: dispatch_queue_t? = nil,
        responseSerializer: T,
        completionHandler: Response<T.SerializedObject, T.ErrorObject> -> Void)
        -> Self
    {
        delegate.queue.addOperationWithBlock {
            let result = responseSerializer.serializeResponse(
                self.request,
                self.response,
                self.delegate.data,
                self.delegate.error
            )

            let requestCompletedTime = self.endTime ?? CFAbsoluteTimeGetCurrent()
            let initialResponseTime = self.delegate.initialResponseTime ?? requestCompletedTime

            let timeline = Timeline(
                requestStartTime: self.startTime ?? CFAbsoluteTimeGetCurrent(),
                initialResponseTime: initialResponseTime,
                requestCompletedTime: requestCompletedTime,
                serializationCompletedTime: CFAbsoluteTimeGetCurrent()
            )

            let response = Response<T.SerializedObject, T.ErrorObject>(
                request: self.request,
                response: self.response,
                data: self.delegate.data,
                result: result,
                timeline: timeline
            )

            dispatch_async(queue ?? dispatch_get_main_queue()) { completionHandler(response) }
=======
    public func response<T: ResponseSerializer, V where T.SerializedObject == V>(
        queue queue: dispatch_queue_t? = nil,
        responseSerializer: T,
        completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Result<V>) -> Void)
        -> Self
    {
        delegate.queue.addOperationWithBlock {
            let result: Result<T.SerializedObject> = {
                if let error = self.delegate.error {
                    return .Failure(self.delegate.data, error)
                } else {
                    return responseSerializer.serializeResponse(self.request, self.response, self.delegate.data)
                }
            }()

            dispatch_async(queue ?? dispatch_get_main_queue()) {
                completionHandler(self.request, self.response, result)
            }
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
        }

        return self
    }
}

// MARK: - Data

extension Request {

    /**
        Creates a response serializer that returns the associated data as-is.

        - returns: A data response serializer.
    */
<<<<<<< HEAD
    public static func dataResponseSerializer() -> ResponseSerializer<NSData, NSError> {
        return ResponseSerializer { _, response, data, error in
            guard error == nil else { return .Failure(error!) }

            if let response = response where response.statusCode == 204 { return .Success(NSData()) }

            guard let validData = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(error)
=======
    public static func dataResponseSerializer() -> GenericResponseSerializer<NSData> {
        return GenericResponseSerializer { _, _, data in
            guard let validData = data else {
                let failureReason = "Data could not be serialized. Input data was nil."
                let error = Error.errorWithCode(.DataSerializationFailed, failureReason: failureReason)
                return .Failure(data, error)
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
            }

            return .Success(validData)
        }
    }

    /**
        Adds a handler to be called once the request has finished.

        - parameter completionHandler: The code to be executed once the request has finished.

        - returns: The request.
    */
<<<<<<< HEAD
    public func responseData(completionHandler: Response<NSData, NSError> -> Void) -> Self {
=======
    public func responseData(completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Result<NSData>) -> Void) -> Self {
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
        return response(responseSerializer: Request.dataResponseSerializer(), completionHandler: completionHandler)
    }
}

// MARK: - String

extension Request {

    /**
        Creates a response serializer that returns a string initialized from the response data with the specified 
        string encoding.

        - parameter encoding: The string encoding. If `nil`, the string encoding will be determined from the server 
                              response, falling back to the default HTTP default character set, ISO-8859-1.

        - returns: A string response serializer.
    */
    public static func stringResponseSerializer(
<<<<<<< HEAD
        encoding encoding: NSStringEncoding? = nil)
        -> ResponseSerializer<String, NSError>
    {
        return ResponseSerializer { _, response, data, error in
            guard error == nil else { return .Failure(error!) }

            if let response = response where response.statusCode == 204 { return .Success("") }

            guard let validData = data else {
                let failureReason = "String could not be serialized. Input data was nil."
                let error = Error.errorWithCode(.StringSerializationFailed, failureReason: failureReason)
                return .Failure(error)
            }
            
            var convertedEncoding = encoding
            
            if let encodingName = response?.textEncodingName where convertedEncoding == nil {
                convertedEncoding = CFStringConvertEncodingToNSStringEncoding(
=======
        var encoding encoding: NSStringEncoding? = nil)
        -> GenericResponseSerializer<String>
    {
        return GenericResponseSerializer { _, response, data in
            guard let validData = data else {
                let failureReason = "String could not be serialized because input data was nil."
                let error = Error.errorWithCode(.StringSerializationFailed, failureReason: failureReason)
                return .Failure(data, error)
            }

            if let encodingName = response?.textEncodingName where encoding == nil {
                encoding = CFStringConvertEncodingToNSStringEncoding(
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
                    CFStringConvertIANACharSetNameToEncoding(encodingName)
                )
            }

<<<<<<< HEAD
            let actualEncoding = convertedEncoding ?? NSISOLatin1StringEncoding

            if let string = String(data: validData, encoding: actualEncoding) {
=======
            let actualEncoding = encoding ?? NSISOLatin1StringEncoding

            if let string = NSString(data: validData, encoding: actualEncoding) as? String {
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
                return .Success(string)
            } else {
                let failureReason = "String could not be serialized with encoding: \(actualEncoding)"
                let error = Error.errorWithCode(.StringSerializationFailed, failureReason: failureReason)
<<<<<<< HEAD
                return .Failure(error)
=======
                return .Failure(data, error)
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
            }
        }
    }

    /**
        Adds a handler to be called once the request has finished.

        - parameter encoding:          The string encoding. If `nil`, the string encoding will be determined from the 
                                       server response, falling back to the default HTTP default character set, 
                                       ISO-8859-1.
<<<<<<< HEAD
        - parameter completionHandler: A closure to be executed once the request has finished.
=======
        - parameter completionHandler: A closure to be executed once the request has finished. The closure takes 3
                                       arguments: the URL request, the URL response and the result produced while
                                       creating the string.
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31

        - returns: The request.
    */
    public func responseString(
        encoding encoding: NSStringEncoding? = nil,
<<<<<<< HEAD
        completionHandler: Response<String, NSError> -> Void)
=======
        completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Result<String>) -> Void)
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
        -> Self
    {
        return response(
            responseSerializer: Request.stringResponseSerializer(encoding: encoding),
            completionHandler: completionHandler
        )
    }
}

// MARK: - JSON

extension Request {

    /**
        Creates a response serializer that returns a JSON object constructed from the response data using 
        `NSJSONSerialization` with the specified reading options.

        - parameter options: The JSON serialization reading options. `.AllowFragments` by default.

        - returns: A JSON object response serializer.
    */
    public static func JSONResponseSerializer(
        options options: NSJSONReadingOptions = .AllowFragments)
<<<<<<< HEAD
        -> ResponseSerializer<AnyObject, NSError>
    {
        return ResponseSerializer { _, response, data, error in
            guard error == nil else { return .Failure(error!) }

            if let response = response where response.statusCode == 204 { return .Success(NSNull()) }

            guard let validData = data where validData.length > 0 else {
                let failureReason = "JSON could not be serialized. Input data was nil or zero length."
                let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                return .Failure(error)
=======
        -> GenericResponseSerializer<AnyObject>
    {
        return GenericResponseSerializer { _, _, data in
            guard let validData = data else {
                let failureReason = "JSON could not be serialized because input data was nil."
                let error = Error.errorWithCode(.JSONSerializationFailed, failureReason: failureReason)
                return .Failure(data, error)
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
            }

            do {
                let JSON = try NSJSONSerialization.JSONObjectWithData(validData, options: options)
                return .Success(JSON)
            } catch {
<<<<<<< HEAD
                return .Failure(error as NSError)
=======
                return .Failure(data, error as NSError)
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
            }
        }
    }

    /**
        Adds a handler to be called once the request has finished.

        - parameter options:           The JSON serialization reading options. `.AllowFragments` by default.
<<<<<<< HEAD
        - parameter completionHandler: A closure to be executed once the request has finished.
=======
        - parameter completionHandler: A closure to be executed once the request has finished. The closure takes 3
                                       arguments: the URL request, the URL response and the result produced while
                                       creating the JSON object.
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31

        - returns: The request.
    */
    public func responseJSON(
        options options: NSJSONReadingOptions = .AllowFragments,
<<<<<<< HEAD
        completionHandler: Response<AnyObject, NSError> -> Void)
=======
        completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Result<AnyObject>) -> Void)
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
        -> Self
    {
        return response(
            responseSerializer: Request.JSONResponseSerializer(options: options),
            completionHandler: completionHandler
        )
    }
}

// MARK: - Property List

extension Request {

    /**
        Creates a response serializer that returns an object constructed from the response data using 
        `NSPropertyListSerialization` with the specified reading options.

        - parameter options: The property list reading options. `NSPropertyListReadOptions()` by default.

        - returns: A property list object response serializer.
    */
    public static func propertyListResponseSerializer(
        options options: NSPropertyListReadOptions = NSPropertyListReadOptions())
<<<<<<< HEAD
        -> ResponseSerializer<AnyObject, NSError>
    {
        return ResponseSerializer { _, response, data, error in
            guard error == nil else { return .Failure(error!) }

            if let response = response where response.statusCode == 204 { return .Success(NSNull()) }

            guard let validData = data where validData.length > 0 else {
                let failureReason = "Property list could not be serialized. Input data was nil or zero length."
                let error = Error.errorWithCode(.PropertyListSerializationFailed, failureReason: failureReason)
                return .Failure(error)
=======
        -> GenericResponseSerializer<AnyObject>
    {
        return GenericResponseSerializer { _, _, data in
            guard let validData = data else {
                let failureReason = "Property list could not be serialized because input data was nil."
                let error = Error.errorWithCode(.PropertyListSerializationFailed, failureReason: failureReason)
                return .Failure(data, error)
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
            }

            do {
                let plist = try NSPropertyListSerialization.propertyListWithData(validData, options: options, format: nil)
                return .Success(plist)
            } catch {
<<<<<<< HEAD
                return .Failure(error as NSError)
=======
                return .Failure(data, error as NSError)
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
            }
        }
    }

    /**
        Adds a handler to be called once the request has finished.

        - parameter options:           The property list reading options. `0` by default.
        - parameter completionHandler: A closure to be executed once the request has finished. The closure takes 3
<<<<<<< HEAD
                                       arguments: the URL request, the URL response, the server data and the result 
                                       produced while creating the property list.
=======
                                       arguments: the URL request, the URL response and the result produced while
                                       creating the property list.
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31

        - returns: The request.
    */
    public func responsePropertyList(
        options options: NSPropertyListReadOptions = NSPropertyListReadOptions(),
<<<<<<< HEAD
        completionHandler: Response<AnyObject, NSError> -> Void)
=======
        completionHandler: (NSURLRequest?, NSHTTPURLResponse?, Result<AnyObject>) -> Void)
>>>>>>> a455fe86e623f2f42c1b7a955c9afc70cd5c3f31
        -> Self
    {
        return response(
            responseSerializer: Request.propertyListResponseSerializer(options: options),
            completionHandler: completionHandler
        )
    }
}
