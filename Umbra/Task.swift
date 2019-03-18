//
//  Task.swift
//  iQuiz
//
//  Created by Kelden Lin on 2/11/19.
//  Copyright © 2019 Kelden Lin. All rights reserved.
//

import Foundation
import UIKit
import CoreData

public class Task : NSObject, NSCoding {
    init(name: String, dueDate: Date, done: Bool = false) {
        self.name = name
        self.dueDate = dueDate
        self.done = done
    }
    
    var name : String! = ""
    var dueDate : Date! = Date()
    var done : Bool! = false
    
    private enum Key: String {
        case name = "name"
        case dueDate = "dueDate"
        case done = "done"
    }
    
    public func encode(with aCoder: NSCoder) {
        if let name = self.name, let dueDate = self.dueDate, let done = self.done {
            aCoder.encode(name, forKey: Key.name.rawValue)
            aCoder.encode(dueDate, forKey: Key.dueDate.rawValue)
            aCoder.encode(done, forKey: Key.done.rawValue)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: Key.name.rawValue) as? String
        dueDate = aDecoder.decodeObject(forKey: Key.dueDate.rawValue) as? Date
        done = aDecoder.decodeBool(forKey: Key.done.rawValue)
        
        super.init()
    }
}

protocol TaskRepository {
    func getTasks() -> [[Task]] // size: 4
    func saveTasks(_ task : [[Task]])
}

class CoreDataRepository : TaskRepository {
    var user : User? = nil
    var taskData : [[Task]] = [[],[],[],[]]
    private static var _repo : TaskRepository? = nil
    static var theInstance : TaskRepository {
        get {
            if _repo == nil { _repo = CoreDataRepository() }
            return _repo!
        }
    }
    
    func getTasks() -> [[Task]] {
        let fetchRequest : NSFetchRequest<User> = User.fetchRequest()
        do {
            var result = try PersistenceService.context.fetch(fetchRequest)
            print("There are \(result.count) user(s)")
            
            // No user profile is found
            if result.count == 0 {
                print("Creating initial user")
                let newUser = User(context: PersistenceService.context)
                newUser.overdue = []
                newUser.today = []
                newUser.tomorrow = []
                newUser.upcoming = []
                
                PersistenceService.saveContext() // Save newly created user
                result = try PersistenceService.context.fetch(fetchRequest) // Fetch the CoreData again with the new user
            }
            
            print(result[0])
            user = result[0]
            return [user!.overdue!, user!.today!, user!.tomorrow!, user!.upcoming!]
        } catch {
            print("FATAL: Couldn't fetch Coredata")
            return [[], [], [] ,[]]
        }
    }
    
    func saveTasks(_ task : [[Task]]) {
        user?.overdue = task[0]
        user?.today = task[1]
        user?.tomorrow = task[2]
        user?.upcoming = task[3]
        PersistenceService.saveContext()
    }
    
}
//
//class SimpleTaskRepository : TaskRepository {
//    var taskData = [Task]()
////    var doneTaskData = [Task]()
//    private static var _repo : TaskRepository? = nil
//    static var theInstance : TaskRepository {
//        get {
//            if _repo == nil { _repo = SimpleTaskRepository() }
//            return _repo!
//        }
//    }
//
//    let localTestingData : [[Task]] = [[
//        Task(name: "Finish Math HW", dueDate: Calendar.current.date(from: DateComponents(timeZone: TimeZone(abbreviation: "PST"), year: 2019, month: 2, day: 11, hour: 19, minute: 0, second: 0))!, done: false),
//        Task(name: "Finish Science HW", dueDate: Calendar.current.date(from: DateComponents(timeZone: TimeZone(abbreviation: "PST"), year: 2019, month: 2, day: 11, hour: 23, minute: 0, second: 0))!, done: false),
//        Task(name: "Finish English HW", dueDate: Calendar.current.date(from: DateComponents(timeZone: TimeZone(abbreviation: "PST"), year: 2019, month: 2, day: 11, hour: 20, minute: 0, second: 0))!, done: false)
//    ], [Task](), [Task](), [Task]()]
//
//    func getTasks() -> [[Task]] {
////        taskData = taskData.count == 0 ? localTestingData : taskData
//        return localTestingData
//    }
//

//    func newTask(_ task: Task) -> Bool {
//        print("Added \(task.name)")
//        taskData.append(task)
//        return true
//    }
//    func savePersons(data: [Task]) -> Bool {
//        return true
//    }
//    func findPersonByLastName(_ lastName: String) -> [Task] {
//        return []
//    }
//}
