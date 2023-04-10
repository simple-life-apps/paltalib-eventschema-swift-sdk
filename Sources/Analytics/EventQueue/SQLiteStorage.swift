//
//  SQLiteStorage.swift
//  PaltaAnalytics
//
//  Created by Vyacheslav Beltyukov on 16/12/2022.
//

import Foundation
import SQLite3
import PaltaCore
import PaltaAnalyticsPrivateModel

final class SQLiteStorage {
    private let client: SQLiteClient
    
    init(folderURL: URL) throws {
        self.client = try SQLiteClient(databaseURL: folderURL.appendingPathComponent("dbv3.sqlite"))
        
        try populateTables()
    }
    
    private func populateTables() throws {
        try client.executeStatement(
            "CREATE TABLE IF NOT EXISTS events (event_id BLOB PRIMARY KEY, event_data BLOB);"
        )
        try client.executeStatement(
            "CREATE TABLE IF NOT EXISTS batches (batch_id BLOB PRIMARY KEY, batch_data BLOB);"
        )
    }
}

extension SQLiteStorage: EventStorage {
    func storeEvent(_ event: StorableEvent) {
        guard let data = try? event.serialize() else {
            return
        }
        
        let row = RowData(column1: event.event.id.data, column2: data)
        
        do {
            try client.executeStatement("INSERT INTO events (event_id, event_data) VALUES (?, ?)") { executor in
                executor.setRow(row)
                try executor.runStep()
            }
        } catch {
            print("PaltaLib: Analytics: Error saving event: \(error)")
        }
    }
    
    func removeEvent(with id: UUID) {
        do {
            try doRemoveEvent(with: id)
        } catch {
            print("PaltaLib: Analytics: Error removing event: \(error)")
        }
    }
    
    func loadEvents(_ completion: @escaping ([StorableEvent]) -> Void) {
        let results: [StorableEvent]
        
        do {
            results = try client.executeStatement("SELECT event_id, event_data FROM events") { executor in
                var results: [StorableEvent] = []
                
                while executor.runQuery(), let row = executor.getRow() {
                    do {
                        let event = try StorableEvent(data: row.column2)
                        results.append(event)
                    } catch {
                        print("PaltaLib: Analytics: Error loading single event: \(error)")
                    }
                }
                
                return results as [StorableEvent]
            }
        } catch {
            results = []
            print("PaltaLib: Analytics: Error loading events: \(error)")
        }
                
        completion(results)
    }
    
    private func doRemoveEvent(with id: UUID) throws {
        try client.executeStatement("DELETE FROM events WHERE event_id = ?") { executor in
            executor.setValue(id.data)
            try executor.runStep()
        }
    }
}

extension SQLiteStorage: BatchStorage {
    func loadBatch() throws -> Batch? {
        try client.executeStatement("SELECT batch_id, batch_data FROM batches") { executor in
            executor.runQuery()
            return try executor.getRow().map { try Batch(data: $0.column2) }
        }
    }
    
    func saveBatch<IDS: Collection>(_ batch: Batch, with eventIds: IDS) throws where IDS.Element == UUID {
        do {
            try client.executeStatement("BEGIN TRANSACTION")
            
            try doSaveBatch(batch)
            
            try eventIds.forEach {
                try doRemoveEvent(with: $0)
            }
            
            try client.executeStatement("COMMIT TRANSACTION")
        } catch {
            try client.executeStatement("ROLLBACK TRANSACTION")
            throw error
        }
    }
    
    func removeBatch() throws {
        try client.executeStatement("DELETE FROM batches WHERE TRUE")
    }
    
    private func doSaveBatch(_ batch: Batch) throws {
        let row = RowData(column1: batch.batchId.data, column2: try batch.serialize())
        try client.executeStatement("INSERT INTO batches (batch_id, batch_data) VALUES (?, ?)") { executor in
            executor.setRow(row)
            try executor.runStep()
        }
    }
}
