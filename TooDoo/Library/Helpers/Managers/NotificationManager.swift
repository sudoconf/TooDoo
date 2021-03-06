//
//  NotificationManager.swift
//  TooDoo
//
//  Created by Cali Castle  on 11/10/17.
//  Copyright © 2017 Cali Castle . All rights reserved.
//

import Foundation
import UserNotifications
import NotificationBannerSwift

protocol NotificationName {
    var name: Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self: NotificationName {
    var name: Notification.Name {
        get {
            return Notification.Name(self.rawValue)
        }
    }
}

/// Manager for Notifications.

final class NotificationManager {
    
    static let center = NotificationCenter.default
    
    /// Defined Notifications for KVO.
    ///
    /// - UserHasSetup: When the user finished the setup
    /// - UserNameChanged: When the user changed the name
    /// - UserAvatarChanged: When the user changed avatar
    /// - UserAuthenticated: When the user passes authentication with biometric Touch ID, Face ID or Passcode
    /// - UserAuthenticationRedirect: When the user uses 3D Touch or other shortcuts trying to perform an action,
    ///                               but need to be authenticated first through lock page
    /// - ShowAddCategory: Show add category
    /// - ShowAddToDo: Show add todo
    /// - ShowSettings: Show settings
    /// - DraggedWhileAddingTodo: When the user swiped/dragged while adding a new todo
    /// - UpdateStatusBar: Update the status bar
    /// - SettingMotionEffectsChanged: When the motion effect setting is changed
    /// - SettingThemeChanged: When the user changed color theme
    /// - SettingLocaleChanged: When the user changed language.
    
    public enum Notifications: String, NotificationName {
        /*
         Events
         */
        case UserHasSetup = "user-has-setup"
        case UserNameChanged = "user-name-changed"
        case UserAvatarChanged = "user-avatar-changed"
        case UserAuthenticated = "user-authenticated"
        case UserAuthenticationRedirect = "user-authentication-redirect"
        
        /*
         Show page
         */
        case ShowAddCategory = "show-add-category"
        case ShowAddToDo = "show-add-todo"
        case ShowSettings = "show-settings"
        
        /*
         Status change
         */
        case DraggedWhileAddingTodo = "dragged-while-adding-todo"
        case UpdateStatusBar = "update-status-bar"
        
        /*
         Settings
         */
        case SettingMotionEffectsChanged = "setting-motion-effects-changed"
        case SettingThemeChanged = "setting-theme-changed"
        case SettingLocaleChanged = "setting-locale-changed"
        case SettingAppIconChanged = "setting-app-icon-changed"
        case SettingPasscodeSetup = "setting-passcode-setup"
    }
    
    /// Local Notifications.
    ///
    /// - TodoDue: Todo is due
    
    public enum LocalNotifications: String {
        case TodoDue = "TODO_DUE"
    }
    
    // MARK: - Functions.
    
    /// Observe for a notification.
    
    public class func listen(_ observer: Any, do selector: Selector, notification: Notifications, object: Any?) {
        center.addObserver(observer, selector: selector, name: notification.name, object: object)
    }
    
    /// Send a notification.
    
    public class func send(notification: Notifications, object: Any? = nil) {
        center.post(name: notification.name, object: object)
    }
    
    /// Remove from a notification.
    
    public class func remove(_ observer: Any, notification: Notifications, object: Any?) {
        center.removeObserver(observer, name: notification.name, object: object)
    }
    
    /// Remove from all notifications.
    
    public class func remove(_ observer: Any) {
        center.removeObserver(observer)
    }
    
    /// Display a banner message.
    ///
    /// - Parameters:
    ///   - title: The message title
    ///   - type: Display type
    
    public class func showBanner(title: String, type: BannerStyle = .info) {
        let banner = NotificationBanner(attributedTitle: NSAttributedString(string: title, attributes: AppearanceManager.bannerTitleAttributes()), style: type)
        
        banner.show()
    }
    
    
    /// Register and schedule todo notification.
    ///
    /// - Parameter todo: The todo item
    
    public class func registerTodoReminderNotification(for todo: ToDo) {
        guard let remindAt = todo.remindAt else { return }
        
        let components = Calendar.current.dateComponents([.minute, .hour, .day, .month, .year], from: remindAt)
        // Configure content
        let content = UNMutableNotificationContent()
        
        // Set title
        if let title = UserDefaultManager.string(forKey: .NotificationMessage) {
            content.title = title
        } else {
            content.title = "notifications.todo.due.title".localized
        }
        
        content.title = content.title.replacingOccurrences(of: "@", with: todo.category!.name!)
        content.categoryIdentifier = LocalNotifications.TodoDue.rawValue
        content.body = todo.goal!
        content.sound = UNNotificationSound(named: SoundManager.SoundEffect.DueNotification.fileName())
  
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        // Generate request
        let request = UNNotificationRequest(identifier: todo.identifier(), content: content, trigger: trigger)
        
        // Add request for scheduling
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    /// Remove a scheduled todo notification.
    ///
    /// - Parameter todo: The todo item
    
    public class func removeTodoReminderNotification(for todo: ToDo) {
        guard todo.completed || todo.isMovedToTrash() else { return }
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [todo.identifier()])
    }
}
