//
//  PillCheckWidgetLiveActivity.swift
//  PillCheckWidget
//
//  Created by 전우정 on 11/25/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PillCheckWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PillCheckWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PillCheckWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PillCheckWidgetAttributes {
    fileprivate static var preview: PillCheckWidgetAttributes {
        PillCheckWidgetAttributes(name: "World")
    }
}

extension PillCheckWidgetAttributes.ContentState {
    fileprivate static var smiley: PillCheckWidgetAttributes.ContentState {
        PillCheckWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PillCheckWidgetAttributes.ContentState {
         PillCheckWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PillCheckWidgetAttributes.preview) {
   PillCheckWidgetLiveActivity()
} contentStates: {
    PillCheckWidgetAttributes.ContentState.smiley
    PillCheckWidgetAttributes.ContentState.starEyes
}
