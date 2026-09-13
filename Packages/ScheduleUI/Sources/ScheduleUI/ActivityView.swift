import DesignKit
import ScheduleFeature
import SharedAssets
import SwiftUI
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
                foregroundImageURLs: foregroundImageURLs
            )

            let hasSubtitle = activity.subtitle?.isEmpty == false
            let hasDescription = activity.description?.isEmpty == false

            if hasSubtitle || hasDescription {
                StackedTileView(
                    primaryText: activity.subtitle,
                    secondaryText: activity.description,
                    secondaryColor: Color.primary
                )
                .padding(Padding.screen)
            }
        }
    }

    private var foregroundImageURLs: [URL] {
        if let image = activity.image,
           !image.isEmpty,
           let encodedImage = image.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed),
           let url = URL(string: encodedImage) {
            return [url]
        } else {
            return []
        }
    }
}

struct ActivityView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityView(activity: .lunch)
    }
}
