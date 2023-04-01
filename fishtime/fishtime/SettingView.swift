//
//  SettingView.swift
//  fishtime
//
//  Created by Yunqian Fan on 2023/4/1.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("closingTime") var closingTime: String = ""
    var onClosingTimeChanged: (() -> Void)?
    @State private var editedClosingHour: String = ""
    @State private var editedClosingMinute: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("当前设定")
                Text(closingTime)
            }
            HStack {
                Text("下班时间")
                    .frame(width: 70)
                Spacer()
                Picker("小时", selection: $editedClosingHour) {
                    ForEach(0..<24) { hour in
                        Text(String(format: "%02d", hour))
                            .tag(String(format: "%02d", hour))
                    }
                }
                .frame(width: 50)
                .labelsHidden()
                Picker("分钟", selection: $editedClosingMinute) {
                    ForEach(0..<60) { minute in
                        Text(String(format: "%02d", minute))
                            .tag(String(format: "%02d", minute))
                    }
                }
                .frame(width: 50)
                .labelsHidden()
                Button("确认") {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    if let date = formatter.date(from: "\(editedClosingHour):\(editedClosingMinute)") {
                        closingTime = formatter.string(from: date)
                        onClosingTimeChanged?()
                    }
                }
                .frame(width: 50)
                .disabled(editedClosingHour.isEmpty || editedClosingMinute.isEmpty)
            }
            Spacer()
        }
        .padding()
        .onAppear {
            let components = closingTime.components(separatedBy: ":")
            editedClosingHour = components[0]
            editedClosingMinute = components[1]
        }
    }
}
