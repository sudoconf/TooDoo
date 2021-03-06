//
//  +Category.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/11/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import UIKit
import CoreData

extension Category {
    
    /// Find all categories.
    class func findAll(in managedObjectContext: NSManagedObjectContext, with sortDescriptors: [NSSortDescriptor]? = nil) -> [Category] {
        // Create Fetch Request
        let request: NSFetchRequest<Category> = fetchRequest()
        
        if let descriptors = sortDescriptors {
            request.sortDescriptors = descriptors
        }
        
        return (try? managedObjectContext.fetch(request)) ?? []
    }
    
    /// Get sort descriptor by order.
    class func sortByOrder(ascending: Bool = true) -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Category.order), ascending: ascending)
    }
    
    /// Get sort descriptor by createdAt.
    class func sortByCreatedAt(ascending: Bool = true) -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Category.createdAt), ascending: ascending)
    }

    /// Create default `personal` and `work` category.
    ///
    /// - Parameter context: Managed object context
    class func createDefault(context: NSManagedObjectContext) {
        let personalCategory = self.init(context: context)
        
        personalCategory.name = "setup.default-category".localized
        personalCategory.color = CategoryColor.defaultColorsString.first!
        personalCategory.icon = "progress"
        personalCategory.createdAt = Date()
        personalCategory.created()
        
        let getStartedTodo = ToDo(context: context)
        getStartedTodo.goal = "Get started".localized
        getStartedTodo.category = personalCategory
        getStartedTodo.createdAt = Date()
        getStartedTodo.created()
        
        let workCategory = self.init(context: context)
        workCategory.name = "setup.default-category-alt".localized
        workCategory.color = CategoryColor.defaultColorsString[1]
        workCategory.icon = "briefcase"
        workCategory.createdAt = Date()
        workCategory.created()
    }
    
    /// Get default category.
    ///
    /// - Returns: The default category
    class func `default`() -> Category? {
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
        
        fetchRequest.sortDescriptors = [Category.ordered()]
        fetchRequest.fetchLimit = 1
        
        if let categories = try? CoreDataManager.main.persistentContainer.viewContext.fetch(fetchRequest) {
            return categories.first
        }
        
        return nil
    }
    
    /// Newest first sort descriptor.
    ///
    /// - Returns: Sort descriptor for newest first
    class func ordered() -> NSSortDescriptor {
        return NSSortDescriptor(key: #keyPath(Category.order), ascending: true)
    }
    
    // MARK: - Configurations after creation.
    
    func created() {
        // Assign UUID
        uuid = UUID().uuidString
    }
    
    /// Get category color.
    ///
    /// - Returns: UIColor color
    func categoryColor() -> UIColor {
        guard let color = color else { return CategoryColor.default().first! }
        
        return UIColor(hexString: color)
    }
    
    /// Get category icon.
    ///
    /// - Returns: UIImage icon
    func categoryIcon() -> UIImage {
        guard let icon = icon else { return UIImage() }
        
        return UIImage(named: "category-icon-\(icon)")!
    }
    
    /// Set color property.
    ///
    /// - Parameter color: Color to be converted in string
    func color(_ color: UIColor) {
        self.color = color.hexValue().replacingOccurrences(of: "#", with: "")
    }
    
    /// Set order position.
    ///
    /// - Parameter indexPath: The index path for new order
    func order(indexPath: IndexPath) {
        order = Int16(indexPath.item)
    }
    
    /// Get valid todos. (The ones that are either completed or moved to trash)
    func validTodos() -> [ToDo] {
        var validTodos: [ToDo] = []
        
        guard let todos = todos else { return validTodos }
        
        for todo in todos {
            if !(todo as! ToDo).isMovedToTrash() && !(todo as! ToDo).completed {
                validTodos.append(todo as! ToDo)
            }
        }
        
        return validTodos
    }
    
    /// Get object identifier.
    ///
    /// - Returns: Identifier
    
    func identifier() -> String {
        return objectID.uriRepresentation().relativePath
    }
}
