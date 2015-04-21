// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to Line.swift instead.

import CoreData

enum LineAttributes: String {
    case id = "id"
    case name = "name"
}

enum LineRelationships: String {
    case stations = "stations"
}

@objc
class _Line: NSManagedObject {

    // MARK: - Class methods

    class func entityName () -> String {
        return "Line"
    }

    class func entity(managedObjectContext: NSManagedObjectContext!) -> NSEntityDescription! {
        return NSEntityDescription.entityForName(self.entityName(), inManagedObjectContext: managedObjectContext);
    }

    // MARK: - Life cycle methods

    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext!) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }

    convenience init(managedObjectContext: NSManagedObjectContext!) {
        let entity = _Line.entity(managedObjectContext)
        self.init(entity: entity, insertIntoManagedObjectContext: managedObjectContext)
    }

    // MARK: - Properties

    @NSManaged
    var id: String?

    // func validateId(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    @NSManaged
    var name: String?

    // func validateName(value: AutoreleasingUnsafePointer<AnyObject>, error: NSErrorPointer) {}

    // MARK: - Relationships

    @NSManaged
    var stations: NSOrderedSet

}

extension _Line {

    func addStations(objects: NSOrderedSet) {
        let mutable = self.stations.mutableCopy() as! NSMutableOrderedSet
        mutable.unionOrderedSet(objects)
        self.stations = mutable.copy() as! NSOrderedSet
    }

    func removeStations(objects: NSOrderedSet) {
        let mutable = self.stations.mutableCopy() as! NSMutableOrderedSet
        mutable.minusOrderedSet(objects)
        self.stations = mutable.copy() as! NSOrderedSet
    }

    func addStationsObject(value: Station!) {
        let mutable = self.stations.mutableCopy() as! NSMutableOrderedSet
        mutable.addObject(value)
        self.stations = mutable.copy() as! NSOrderedSet
    }

    func removeStationsObject(value: Station!) {
        let mutable = self.stations.mutableCopy() as! NSMutableOrderedSet
        mutable.removeObject(value)
        self.stations = mutable.copy() as! NSOrderedSet
    }

}
