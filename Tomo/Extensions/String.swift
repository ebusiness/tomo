//
//  String.swift
//  Tomo
//
//  Created by starboychina on 2017/02/16.
//  Copyright © 2017 e-business. All rights reserved.
//


public extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }

    func substring(with range: Range<Int>) -> String {
        let startIndex = index(from: range.lowerBound)
        let endIndex = index(from: range.upperBound)
        return substring(with: startIndex..<endIndex)
    }

    /**
     Strips the specified characters from the beginning of self.

     - returns: Stripped string
     */
    func trimmedLeft (characterSet set: CharacterSet = CharacterSet.whitespacesAndNewlines) -> String {
        if let range = rangeOfCharacter(from: set.inverted) {
            return self[range.lowerBound..<endIndex]
        }

        return ""
    }

    /**
     Strips the specified characters from the end of self.

     - returns: Stripped string
     */
    func trimmedRight (characterSet set: CharacterSet = CharacterSet.whitespacesAndNewlines) -> String {
        if let range = rangeOfCharacter(from: set.inverted, options: String.CompareOptions.backwards) {
            return self[startIndex..<range.upperBound]
        }

        return ""
    }

    /**
     Strips whitespaces from both the beginning and the end of self.

     - returns: Stripped string
     */
    func trimmed () -> String {
        return trimmedLeft().trimmedRight()
    }
    /**
     Parses a string containing a date into an optional NSDate if the string is a well formed.
     The default format is yyyy-MM-dd, but can be overriden.

     - returns: A NSDate parsed from the string or nil if it cannot be parsed as a date.
     */
    func toDate(format: String? = "yyyy-MM-dd") -> Date? {
        let text = self.trimmed().lowercased()
        let dateFmt = DateFormatter()
        dateFmt.timeZone = NSTimeZone.default
        if let fmt = format {
            dateFmt.dateFormat = fmt
        }
        return dateFmt.date(from: text)
    }

    public var isEmail: Bool {
        // http://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }

    func isValidPassword() -> Bool {
        let regex = "(?=^.{8,}$)(?=.*\\d)(?![.\\n])(?=.*[A-Z])(?=.*[a-z]).*$"
        let test = NSPredicate(format:"SELF MATCHES %@", regex)
        return test.evaluate(with: self)
    }
}
