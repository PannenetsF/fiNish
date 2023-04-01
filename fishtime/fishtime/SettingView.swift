//
//  SettingView.swift
//  fishtime
//
//  Created by Yunqian Fan on 2023/4/1.
//

import SwiftUI

//struct SettingsView: View {
//    @AppStorage("closingTime") var closingTime: String = ""
//    var onClosingTimeChanged: (() -> Void)?
//
//    var body: some View {
//        VStack {
//            HStack {
//                Text("下班时间")
//                Spacer()
//                DatePicker(
//                    "",
//                    selection: Binding(get: {
//                        let formatter = DateFormatter()
//                        formatter.dateFormat = "HH:mm"
//                        return formatter.date(from: closingTime) ?? Date()
//                    }, set: { date in
//                        let formatter = DateFormatter()
//                        formatter.dateFormat = "HH:mm"
//                        closingTime = formatter.string(from: date)
//                        onClosingTimeChanged?()
//                    }),
//                    displayedComponents: .hourAndMinute
//                )
//                .labelsHidden()
//            }
//            Spacer()
//        }
//        .padding()
//    }
//}
struct SettingsView: View {
    @AppStorage("closingTime") var closingTime: String = ""
    var onClosingTimeChanged: (() -> Void)?
    @State private var editedClosingTime: String = ""

    var body: some View {
        VStack {
            HStack {
                Text("当前设定")
                Text(closingTime)
            }
            HStack {
                Text("下班时间")
                Spacer()
                TextField("HH:mm", text: $editedClosingTime)
                    .frame(width: 80)
                    .multilineTextAlignment(.center)
                Button("确认") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    if let date = formatter.date(from: editedClosingTime) {
                        closingTime = formatter.string(from: date)
                        onClosingTimeChanged?()
                    }
                }
                .disabled(editedClosingTime.isEmpty)
            }
            Spacer()
        }
        .padding()
        .onAppear {
            editedClosingTime = closingTime
        }
    }
}
