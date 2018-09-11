//
//  CoreDataImporter.swift
//  JournalCoreData
//
//  Created by Andrew R Madsen on 9/10/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation
import CoreData

class CoreDataImporter {
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func sync(entries: [EntryRepresentation], completion: @escaping (Error?) -> Void = { _ in }) {
        
        self.context.perform {
			let allEntries = self.fetchAllEntries(self.context)
			NSLog("Started syncing \(entries.count) => \(allEntries.count)")
            for entryRep in entries {
                guard let identifier = entryRep.identifier else { continue }
                
				let entry = allEntries[identifier]
                if let entry = entry, entry != entryRep {
                    self.update(entry: entry, with: entryRep)
                } else if entry == nil {
                    _ = Entry(entryRepresentation: entryRep, context: self.context)
                }
            }
			NSLog("Synced \(entries.count) => \(allEntries.count)")
            completion(nil)
        }
    }
    
    private func update(entry: Entry, with entryRep: EntryRepresentation) {
        entry.title = entryRep.title
        entry.bodyText = entryRep.bodyText
        entry.mood = entryRep.mood
        entry.timestamp = entryRep.timestamp
        entry.identifier = entryRep.identifier
    }

	// /me makes a mike acton face
    private func fetchSingleEntryFromPersistentStore(with identifier: String?, in context: NSManagedObjectContext) -> Entry? {

        guard let identifier = identifier else { return nil }
        
        let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "identifier == %@", identifier)
        
        var result: Entry? = nil
        do {
            result = try context.fetch(fetchRequest).first
        } catch {
            NSLog("Error fetching single entry: \(error)")
        }
        return result
    }

	private func fetchAllEntries(_ context: NSManagedObjectContext) -> [String:Entry] {

		NSLog("Starting to fetch all entries...")
		let fetchRequest: NSFetchRequest<Entry> = Entry.fetchRequest()

		var result:[String:Entry] = [:]
		do {
			let results = try context.fetch(fetchRequest)
			for entry in results {
				guard let id = entry.identifier else { continue }
				result[id] = entry
			}
		} catch {
			NSLog("Error fetching all entries: \(error)")
		}
		return result
	}
    let context: NSManagedObjectContext
}
