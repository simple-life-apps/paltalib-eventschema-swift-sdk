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
    private let errorsLogger: ErrorsCollector
    private let client: SQLiteClient
    
    init(errorsLogger: ErrorsCollector, folderURL: URL) throws {
        self.errorsLogger = errorsLogger
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
        try client.executeStatement(
            "CREATE TABLE IF NOT EXISTS error_codes (batch_id BLOB, code INTEGER, id INTEGER PRIMARY KEY AUTOINCREMENT);"
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
            errorsLogger.logError("Store event: \(error.localizedDescription)")
        }
    }
    
    func removeEvent(with id: UUID) {
        do {
            try doRemoveEvent(with: id)
        } catch {
            print("PaltaLib: Analytics: Error removing event: \(error)")
            errorsLogger.logError("Remove event: \(error.localizedDescription)")
        }
    }
    
    func loadEvents(_ completion: @escaping ([StorableEvent]) -> Void) {
        let results: [StorableEvent]
        
        do {
            results = try client.executeStatement("SELECT event_id, event_data FROM events") { executor in
                var results: [StorableEvent] = []
                
                while executor.runQuery(), let row = executor.getDataRow() {
                    do {
                        let event = try StorableEvent(data: row.column2)
                        results.append(event)
                    } catch {
                        print("PaltaLib: Analytics: Error loading single event: \(error)")
                        errorsLogger.logError("Get event: \(error.localizedDescription)")
                    }
                }
                
                return results as [StorableEvent]
            }
        } catch {
            results = []
            print("PaltaLib: Analytics: Error loading events: \(error)")
            errorsLogger.logError("Get events: \(error.localizedDescription)")
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
    func loadBatches() throws -> [PaltaAnalyticsPrivateModel.Batch] {
        do {
            return try client.executeStatement("SELECT batch_id, batch_data FROM batches") { executor in
                var results: [Batch] = []
                
                while executor.runQuery(), let row = executor.getDataRow() {
                    do {
                        let batch = try Batch(data: row.column2)
                        results.append(batch)
                    } catch {
                        print("PaltaLib: Analytics: Error loading single batch: \(error)")
                        errorsLogger.logError("Load single batch: \(error.localizedDescription)")
                    }
                }
                
                return results
            }
        } catch {
            errorsLogger.logError("Load batches: \(error.localizedDescription)")
            throw error
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
            errorsLogger.logError("Save batch: \(error.localizedDescription)")
            try client.executeStatement("ROLLBACK TRANSACTION")
            throw error
        }
    }
    
    func removeBatch(_ batch: Batch) throws {
        do {
            try client.executeStatement("DELETE FROM batches WHERE batch_id = ?") { executor in
                executor.setValue(batch.batchId.data)
                try executor.runStep()
            }
            
            try client.executeStatement("DELETE FROM error_codes WHERE batch_id = ?") { executor in
                executor.setValue(batch.batchId.data)
                try executor.runStep()
            }
        } catch {
            errorsLogger.logError("Remove batch: \(error.localizedDescription)")
            throw error
        }
    }
    
    func addErrorCode(_ errorCode: Int, for batch: Batch) throws {
        do {
            let row = RowDataInteger(column1: batch.batchId.data, column2: errorCode)
            try client.executeStatement("INSERT INTO error_codes (batch_id, code) VALUES (?, ?)") { executor in
                executor.setRow(row)
                try executor.runStep()
            }
        } catch {
            errorsLogger.logError("Add error code: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getErrorCodes(for batch: Batch) throws -> [Int] {
        do {
            return try client.executeStatement(
                "SELECT batch_id, code FROM error_codes WHERE batch_id = ? ORDER BY id ASC"
            ) { executor in
                executor.setValue(batch.batchId.data)
                
                var results: [Int] = []
                
                while executor.runQuery(), let row = executor.getIntRow() {
                    results.append(row.column2)
                }
                
                return results
            }
        } catch {
            errorsLogger.logError("Get error codes: \(error.localizedDescription)")
            throw error
        }
        
    }
    
    private func doSaveBatch(_ batch: Batch) throws {
        let row = RowData(column1: batch.batchId.data, column2: try batch.serialize())
        try client.executeStatement("INSERT INTO batches (batch_id, batch_data) VALUES (?, ?)") { executor in
            executor.setRow(row)
            try executor.runStep()
        }
    }
}
