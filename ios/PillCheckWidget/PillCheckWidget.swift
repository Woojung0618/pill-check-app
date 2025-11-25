//
//  PillCheckWidget.swift
//  PillCheckWidget
//
//  Created by 전우정 on 11/25/25.
//

import WidgetKit
import SwiftUI

// App Group을 통해 데이터 공유
let appGroupIdentifier = "group.pill.check.app"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), pills: [], checkedPills: [], intakeRate: 0.0, pillCount: "0", checkedCount: "0", totalRequired: "0")
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = loadWidgetData()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = loadWidgetData()
        
        // 위젯을 1시간마다 업데이트
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    // App Group의 UserDefaults에서 데이터 로드
    private func loadWidgetData() -> SimpleEntry {
        guard let userDefaults = UserDefaults(suiteName: appGroupIdentifier) else {
            return SimpleEntry(date: Date(), pills: [], checkedPills: [], intakeRate: 0.0, pillCount: "0", checkedCount: "0", totalRequired: "0")
        }
        
        let pillCount = userDefaults.string(forKey: "pill_count") ?? "0"
        let checkedCount = userDefaults.string(forKey: "checked_count") ?? "0"
        let totalRequired = userDefaults.string(forKey: "total_required") ?? "0"
        let intakeRate = Double(userDefaults.string(forKey: "intake_rate") ?? "0.0") ?? 0.0
        
        // 영양제 목록 (JSON 문자열)
        var pills: [PillData] = []
        if let pillsJson = userDefaults.string(forKey: "pills"),
           let data = pillsJson.data(using: .utf8),
           let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            pills = jsonArray.compactMap { dict in
                guard let id = dict["id"] as? String,
                      let name = dict["name"] as? String,
                      let color = dict["color"] as? String else {
                    return nil
                }
                return PillData(
                    id: id,
                    name: name,
                    color: color,
                    brand: dict["brand"] as? String ?? ""
                )
            }
        }
        
        // 체크된 영양제 목록 (JSON 문자열)
        var checkedPills: Set<String> = []
        if let checkedPillsJson = userDefaults.string(forKey: "checked_pills"),
           let data = checkedPillsJson.data(using: .utf8),
           let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [String] {
            checkedPills = Set(jsonArray)
        }
        
        return SimpleEntry(
            date: Date(),
            pills: pills,
            checkedPills: checkedPills,
            intakeRate: intakeRate,
            pillCount: pillCount,
            checkedCount: checkedCount,
            totalRequired: totalRequired
        )
    }
}

struct PillData {
    let id: String
    let name: String
    let color: String
    let brand: String
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let pills: [PillData]
    let checkedPills: Set<String>
    let intakeRate: Double
    let pillCount: String
    let checkedCount: String
    let totalRequired: String
}

struct PillCheckWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// Small 위젯 뷰
struct SmallWidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("오늘의 영양제")
                .font(.headline)
                .fontWeight(.bold)
            
            if entry.pills.isEmpty {
                Text("등록된 영양제 없음")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                let firstPill = entry.pills[0]
                let isChecked = entry.checkedPills.contains(firstPill.id)
                HStack {
                    Text(isChecked ? "✓" : "○")
                        .font(.title2)
                    Text(firstPill.name)
                        .font(.caption)
                        .lineLimit(1)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// Medium 위젯 뷰
struct MediumWidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("오늘의 영양제")
                .font(.headline)
                .fontWeight(.bold)
            
            if entry.pills.isEmpty {
                Text("등록된 영양제 없음")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(entry.pills.prefix(5), id: \.id) { pill in
                        let isChecked = entry.checkedPills.contains(pill.id)
                        HStack {
                            Text(isChecked ? "✓" : "○")
                                .font(.body)
                            Text(pill.name)
                                .font(.caption)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

// Large 위젯 뷰
struct LargeWidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("오늘의 영양제")
                .font(.title2)
                .fontWeight(.bold)
            
            if entry.pills.isEmpty {
                Text("등록된 영양제 없음")
                    .font(.body)
                    .foregroundColor(.secondary)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(entry.pills, id: \.id) { pill in
                        let isChecked = entry.checkedPills.contains(pill.id)
                        HStack {
                            Text(isChecked ? "✓" : "○")
                                .font(.title3)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(pill.name)
                                    .font(.body)
                                if !pill.brand.isEmpty {
                                    Text(pill.brand)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            // 복용률 표시
            let ratePercent = Int(entry.intakeRate * 100)
            Text("복용률: \(ratePercent)% (\(entry.checkedCount)/\(entry.totalRequired))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct PillCheckWidget: Widget {
    let kind: String = "PillCheckWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PillCheckWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PillCheckWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("영양제 체크")
        .description("오늘의 영양제 복용 상태를 확인하세요.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    PillCheckWidget()
} timeline: {
    SimpleEntry(date: .now, pills: [
        PillData(id: "1", name: "Omega 3", color: "#E91E63", brand: ""),
        PillData(id: "2", name: "Vitamin C", color: "#FFEB3B", brand: "")
    ], checkedPills: ["1"], intakeRate: 0.5, pillCount: "2", checkedCount: "1", totalRequired: "2")
}
