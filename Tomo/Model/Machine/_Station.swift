// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Station.swift instead.

import CoreData

enum StationAttributes: String {
    case address = "address"
    case id = "id"
    case lat = "lat"
    case lon = "lon"
    case name = "name"
    case pref = "pref"
    case pref_name = "pref_name"
    case zipcode = "zipcode"
}

enum StationRelationships: String {
    case line = "line"
}

@objc
class _Station: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Station"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Station.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var address: String?

    // func validateAddress(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var id: String?

    // func validateId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var lat: String?

    // func validateLat(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var lon: String?

    // func validateLon(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var name: String?

    // func validateName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var pref: String?

    // func validatePref(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var pref_name: String?

    // func validatePref_name(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var zipcode: String?

    // func validateZipcode(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var line: Line?

    // func validateLine(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

}

