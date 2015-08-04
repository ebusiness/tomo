//
//  AlamofireController.swift
//  Tomo
//
//  Created by starboychina on 2015/08/03.
//  Copyright (c) 2015年 &#24373;&#24535;&#33775;. All rights reserved.
//

extension Request {
    public func responseObject<T: AnyObject>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) -> Self {
        let serializer: Serializer = { (request, response, data) in
            let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
            let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
            if response != nil && JSON != nil {
//                return (T(response: response!, representation: JSON!), nil)
            } else {
                return (nil, serializationError)
            }
            return (nil, serializationError)
        }
        
        return response(serializer: serializer, completionHandler: { (request, response, object, error) in
            completionHandler(request, response, object as? T, error)
        })
    }
}


public class Reflector<T:NSObject> {
    
    lazy public var name: String              = self.loadName()
    lazy public var properties: Array<String> = self.loadProperties()
    lazy public var methods: Array<String>    = self.loadMethods()
    
    public init() { }
    
    deinit { }
    
    public func createInstance() -> T {
        return T()
    }
    
    public func execute(code: (`self`:T) -> (), instance:T) {
        code(`self`: instance)
    }
    
    public func execute<U>(code: (`self`:T) -> U, instance:T) -> U {
        return code(`self`: instance)
    }
    
    private func loadName() -> String {
        return String(NSString(UTF8String: class_getName(T.self))!)
    }
    
    private func loadProperties() -> Array<String> {
        
        var count: UInt32       = 0
        let rawProperties = class_copyPropertyList(T.self,&count)
        
        var propertyNames : [String]  = []
        let intCount                  = Int(count)
        
        for var i = 0; i < intCount; i++ {
            let property : objc_property_t  = rawProperties[i]
            let propertyName                = String(NSString(UTF8String: property_getName(property))!)
            
            propertyNames.append(propertyName)
        }
        
        return propertyNames
    }
    
    private func loadMethods() -> Array<String> {
        
        var count: UInt32       = 0
        let rawMethods = class_copyMethodList(T.self, &count)
        let intCount = Int(count)
        
        var methodNames : [String]  = []
        for var i = 0; i < intCount; i++ {
            let method = rawMethods[i]
            let selector: Selector  = method_getName(method)
            let methodName          = String(NSString(UTF8String: sel_getName(selector))!)
            
            methodNames.append(methodName)
        }
        return methodNames
    }
}