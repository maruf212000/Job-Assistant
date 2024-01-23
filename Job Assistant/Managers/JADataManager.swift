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
    
    var userData: [String: Any]
    
    static let shared: JADataManager = {
        let instance = JADataManager()
        // setup code
        return instance
    }()
    
    private init() {
        userData = [:]
    }
    
    
    func setup() {
        self.userData = fetchUserProfile()
    }
    
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
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    // MARK: - Job Entity
    
    func createJob(job_id: String, job_description: String, company_name: String, apply_link: String, job_role: String) {
        let context = persistentContainer.viewContext
        let job = JAJobEntity(context: context)
        job.job_id = job_id
        job.job_description = job_description
        job.company_name = company_name
        job.apply_link = apply_link
        job.job_role = job_role
        
        saveContext()
    }
    
    func fetchAllJobs() -> [JAJobEntity] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<JAJobEntity> = JAJobEntity.fetchRequest()
        
        do {
            let jobs = try context.fetch(fetchRequest)
            return jobs
        } catch {
            print("Error fetching jobs: \(error)")
            return []
        }
    }
    
    func updateJob(job: JAJobEntity, jobRole: String) {
        job.job_role = jobRole
        
        saveContext()
    }
    
    func deleteJob(job: JAJobEntity) {
        let context = persistentContainer.viewContext
        context.delete(job)
        
        saveContext()
    }
    
    // MARK: - User Profile Entity
    
    func fetchUserProfile() -> [String: Any] {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<JAUserProfileEntity> = JAUserProfileEntity.fetchRequest()
        
        do {
            let userProfiles = try context.fetch(fetchRequest)
            if let userProfile = userProfiles.first {
                return getJSONFromCoreDataEntity(managedObject: userProfile)
            }
            return [:]
        } catch {
            print("Error fetching jobs: \(error)")
            return [:]
        }
    }
    
    func getJSONFromCoreDataEntity(managedObject: NSManagedObject) -> Dictionary<String, Any> {
        // Convert managed object attributes to a dictionary
        let attributes = managedObject.entity.attributesByName
        var dictionary: [String: Any] = [:]
        
        for (key, _) in attributes {
            if let value = managedObject.value(forKey: key) {
                if value is Data {
                    let newValue = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(value as! Data)
                    dictionary[key] = newValue
                } else if value is Date {
                    let newValue = stringFromDate(date: value as! Date)
                    dictionary[key] = newValue
                } else {
                    dictionary[key] = value
                }
            }
        }
        if managedObject is JAUserProfileEntity {
            for (key, _) in managedObject.entity.relationshipsByName {
                var values:[Dictionary<String, Any>] = []
                if let value = managedObject.value(forKey: key) {
                    if let toManyRelationship = value as? NSSet {
                        for relatedObject in toManyRelationship {
                            if let relatedManagedObject = relatedObject as? NSManagedObject {
                                let dict = getJSONFromCoreDataEntity(managedObject: relatedManagedObject)
                                values.append(dict)
                            }
                        }
                    }
                }
                dictionary[key] = values
            }
        }
        return dictionary
    }
    func getJSONString(from managedObject: NSManagedObject) -> String {
        let dict = getJSONFromCoreDataEntity(managedObject: managedObject)
        return getJSONString(fromDict: dict)
    }
    
    func getJSONString(fromDict dict: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                return jsonString
            }
        } catch {
            return ""
        }
        return ""
    }
    
    func userProfileJson() -> String {
        return getJSONString(fromDict: self.userData)
    }
    
    func createExperience(job_title: String, details: String, company_name: String, start_date: Date, end_date: Date?, isPresent: Bool) -> JAExperienceEntity {
        let context = persistentContainer.viewContext
        let experience = JAExperienceEntity(context: context)
        experience.job_title = job_title
        experience.details = details
        experience.company_name = company_name
        experience.start_date = start_date
        experience.end_date = end_date
        experience.isPresent = isPresent
        
        saveContext()
        return experience
    }
    
    func createEducation(degree_name: String, college_name: String, start_date: Date, end_date: Date) -> JAEducationEntity {
        let context = persistentContainer.viewContext
        let education = JAEducationEntity(context: context)
        education.degree_name = degree_name
        education.college_name = college_name
        education.start_date = start_date
        education.end_date = end_date
        
        saveContext()
        return education
    }
    
    func createProject(project_title: String, project_details: String) -> JAProjectEntity {
        let context = persistentContainer.viewContext
        let project = JAProjectEntity(context: context)
        project.project_title = project_title
        project.project_details = project_details
        
        saveContext()
        return project
    }
    
    func getDate(from str: String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.current
        return dateFormatter.date(from: str) ?? .now
    }
    
    func stringFromDate(date: Date, format: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: date)
    }
}
