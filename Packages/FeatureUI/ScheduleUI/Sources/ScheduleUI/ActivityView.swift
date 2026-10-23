import Foundation
import ScheduleDomain
import ScheduleFeature
import SwiftUI
import UIAssets
import UIComponents

package struct ActivityView: View {
    private let activity: Activity

    package init(activity: Activity) {
        self.activity = activity
    }

    package var body: some View {
        ScrollView {
            content
        }
        .background(Color.background, ignoresSafeAreaEdges: .all)
        .edgesIgnoringSafeArea(.top)
    }

    private var content: some View {
        VStack(spacing: Padding.stackGap) {
            FancyHeaderView(
                title: activity.title,
                foregroundImageURLs: foregroundImageURLs,
            )

            if hasText {
                StackedTileView(
                    primaryText: activity.subtitle,
                    secondaryText: activity.description,
                    secondaryColor: Color.primary,
                )
                .padding(Padding.screen)
            }
        }
    }

    /// Whether the activity has a subtitle or a description to show.
    private var hasText: Bool {
        [activity.subtitle, activity.description]
            .compactMap { $0 }
            .contains { !$0.isEmpty }
    }

    private var foregroundImageURLs: [URL] {
        if let image = activity.image,
            !image.isEmpty,
            let encodedImage = image.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
            let url = URL(string: encodedImage)
        {
            return [url]
        }
        return []
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(activity: .lunch)
    }
}
