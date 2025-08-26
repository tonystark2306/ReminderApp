//
//  ReminderItems.swift
//  ReminderApp
//
//  Created by iKame Elite Fresher 2025 on 8/26/25.
//

import Foundation
import RealmSwift

class Reminder: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var title: String = ""
    @Persisted var note: String = ""
    @Persisted var dueEnabled: Bool = false
    @Persisted var dueDate: Date?
    @Persisted var createdAt: Date = Date()
    @Persisted var updatedAt: Date = Date()
    @Persisted var tags = List<String>()       
}

private let currentSchemaVersion: UInt64 = 1

func setupRealmMigration() {
    let config = Realm.Configuration(
        schemaVersion: currentSchemaVersion,
        migrationBlock: { migration, oldSchemaVersion in
            if oldSchemaVersion < 1 {
                
            }
        }
    )
    Realm.Configuration.defaultConfiguration = config
}
