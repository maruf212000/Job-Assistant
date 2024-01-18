//
//  JADataManager.swift
//  Job Assistant
//
//  Created by Maruf Memon on 18/01/24.
//

import Foundation
import CoreData
import EncryptedCoreData

let kData = JADataManager.shared

class JADataManager {
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        
        let momdName = "JobAssistantModel"
        let passphraseKey: String = kKeychain.coreDataDBKey() ?? "db_password"

        guard let modelURL = Bundle(for: Self.self).url(forResource: momdName, withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }

        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let configuration = EncryptedStoreFileManagerConfiguration()
        configuration.bundle = Bundle(for: Self.self)
        
        let fileManager = EncryptedStoreFileManager(configuration: configuration)
        
        let options: [String: Any] = [
            EncryptedStorePassphraseKey: passphraseKey,
            EncryptedStore.optionFileManager(): fileManager as Any,
            NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true
        ]
        
        let description = try! EncryptedStore.makeDescription(options: options, configuration: nil)
        
        let container = NSPersistentContainer(name: momdName, managedObjectModel: mom)
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (_, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static let shared: JADataManager = {
        let instance = JADataManager()
        // setup code
        return instance
    }()
    
    private init() {
        
    }
    
    func setup() {
        
    }
}
