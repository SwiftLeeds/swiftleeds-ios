import DesignKit
import SharedAssets
import SwiftUI

struct LocalCell: View {
    let label: String
    let imageName: String
    let foregroundColor: Color
    let labelFontStyle: Font
    let onTap: () -> ()
    
    internal init(label : String,
                  imageName: String,
                  foregroundColor: Color = .cellForeground,
                  labelFontStyle: Font = .headline.weight(.medium),
                  onTap: @escaping () -> () = {}
    ){
        self.label = label
        self.imageName = imageName
        self.foregroundColor = foregroundColor
        self.labelFontStyle = labelFontStyle
        self.onTap = onTap
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(label)
                    .font(labelFontStyle)
                Spacer()
                
                Image(uiImage: UIImage(systemName: imageName) ?? UIImage(imageLiteralResourceName: imageName))
                    .renderingMode(.template)
                    .frame(width: 30)
            }
            .padding(Padding.cell)
            .frame(minHeight: Constants.cellMinimumHeight)
            .foregroundColor(foregroundColor)
            .background {
                RoundedRectangle(cornerRadius: Constants.cellRadius).fill(Color.cellBackground)
            }
        }
    }
}

struct LocalCell_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            LocalCell(label: "Food", imageName: "takeoutbag.and.cup.and.straw.fill")
            LocalCell(label: "Coffee", imageName: "cup.and.saucer.fill")
            LocalCell(label: "Drink", imageName: "wineglass.fill")
            LocalCell(label: "Best of Leeds", imageName: "mappin")
        }
    }
    
}
