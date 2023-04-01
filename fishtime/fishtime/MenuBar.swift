import Cocoa
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBarItem: NSStatusItem!
    var closingTime: String = "23:00"
    var triggered: Bool = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // 创建状态栏项目
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusBarItem.button?.title = "🕒"

        // 创建菜单
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "设置", action: #selector(showSettings), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "退出", action: #selector(quit), keyEquivalent: ""))
        statusBarItem.menu = menu

        // 读取下班时间
        let storedClosingTime = UserDefaults.standard.string(forKey: "closingTime")
        if let storedClosingTime = storedClosingTime {
            closingTime = storedClosingTime
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, error in
            if let error = error {
                print("Error: \(error)")
            }
        }
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                print("Notifications not authorized")
            }
        }

        // 监听时间变化
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.checkTime()
        }
    }

    @objc func showSettings() {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 200, height: 100)
        popover.behavior = .transient
        let settingsView = SettingsView(closingTime: closingTime, onClosingTimeChanged: { [weak self] in
            // 更新下班时间
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm"
            if let date = formatter.date(from: self?.closingTime ?? "") {
                self?.closingTime = formatter.string(from: date)
            }
        })
        popover.contentViewController = NSHostingController(rootView: settingsView)
        popover.show(relativeTo: statusBarItem.button!.bounds, of: statusBarItem.button!, preferredEdge: .minY)
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
//
//    func checkTime() {
//        let now = Date()
//        let calendar = Calendar.current
//        let components = calendar.dateComponents([.hour, .minute], from: now)
//        let currentTime = calendar.date(bySettingHour: components.hour!, minute: components.minute!, second: 0, of: Date())!
//
//        let storedClosingTime = UserDefaults.standard.string(forKey: "closingTime")
//        if let storedClosingTime = storedClosingTime {
//            closingTime = storedClosingTime
//        }
//
//        // 弹出 "准备下班" 通知
//        let content = UNMutableNotificationContent()
//        content.title = "准备下班"
//        content.sound = UNNotificationSound.default
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = "HH:mm"
//        let triggerTime = formatter.date(from: closingTime)?.addingTimeInterval(-10 * 60) ?? Date.distantFuture
//        if currentTime >= triggerTime && currentTime < formatter.date(from: closingTime) ?? Date.distantFuture {
//            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: triggerTime)
//            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
//            let request = UNNotificationRequest(identifier: "prepareForLeaving", content: content, trigger: trigger)
//            UNUserNotificationCenter.current().add(request)
//        }
//
//        // 锁定屏幕
//        if currentTime >= formatter.date(from: closingTime) ?? Date.distantFuture {
//            DispatchQueue.global(qos: .background).async {
//                let appleScript = NSAppleScript(source: "tell application \"System Events\" to keystroke \"q\" using {command down, control down, option down}")
//                appleScript?.executeAndReturnError(nil)
//            }
//        }
//    }
    func checkTime() {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: now)
        let currentTimeInMinutes = components.hour! * 60 + components.minute!

        // 读取下班时间
        let storedClosingTime = UserDefaults.standard.string(forKey: "closingTime")
        if let storedClosingTime = storedClosingTime {
            closingTime = storedClosingTime
        }

        // 弹出 "准备下班" 通知
        let content = UNMutableNotificationContent()
        content.title = "准备下班"
        content.sound = UNNotificationSound.default

        let closingTimeComponents = closingTime.split(separator: ":").map { Int($0)! }
        let closingTimeInMinutes = closingTimeComponents[0] * 60 + closingTimeComponents[1]
        let triggerTimeInMinutes = closingTimeInMinutes - 10

        if currentTimeInMinutes >= triggerTimeInMinutes && currentTimeInMinutes < closingTimeInMinutes && triggered == false {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
            let request = UNNotificationRequest(identifier: "prepareForLeaving", content: content, trigger: trigger)
            triggered = true
            // 锁定屏幕
            UNUserNotificationCenter.current().add(request)
            print("Noted Noted")
        }

        if currentTimeInMinutes >= closingTimeInMinutes && triggered {
            if triggered == true {
                triggered = false
            }
//            DispatchQueue.global(qos: .background).async {
//                let appleScript = NSAppleScript(source: "tell application \"System Events\" to keystroke \"q\" using {command down, control down}")
//                appleScript?.executeAndReturnError(nil)
//            }
            print("lock lock")
            let alert = NSAlert()
            alert.messageText = "确认锁屏？"
            alert.alertStyle = .warning
            alert.addButton(withTitle: "确认")
            alert.addButton(withTitle: "取消")
            let response = alert.runModal()
            if response == NSApplication.ModalResponse.alertFirstButtonReturn {
                // 锁定屏幕\
                print("ls ls")
                let task = Process()
                task.launchPath = "/usr/bin/pmset"
                task.arguments = ["displaysleepnow"]
                task.launch()
            }
        }

    }


}
