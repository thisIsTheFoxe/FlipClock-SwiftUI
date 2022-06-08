import SwiftUI

struct SingleFlipView: View {

    init(text: String, type: FlipType) {
        self.text = text
        self.type = type
    }
    var isBig: Bool { UIScreen.main.bounds.width > 500 }

    var body: some View {
        Text(text)
            .font(.system(size: isBig ? 64 : 40))
            .fontWeight(.heavy)
            .foregroundColor(.textColor)
            .fixedSize()
            .padding(type.padding, -20)
            .frame(width: isBig ? 65 : 20, height: isBig ? 80: 20, alignment: type.alignment)
            .padding(type.paddingEdges, 10)
            .clipped()
            .background(Color.flipBackground)
            .cornerRadius(4)
            .padding(type.padding, isBig ? -18 : -4.5)
            .clipped()
    }

    enum FlipType {
        case top
        case bottom

        var padding: Edge.Set {
            switch self {
            case .top:
                return .bottom
            case .bottom:
                return .top
            }
        }

        var paddingEdges: Edge.Set {
            switch self {
            case .top:
                return [.top, .leading, .trailing]
            case .bottom:
                return [.bottom, .leading, .trailing]
            }
        }

        var alignment: Alignment {
            switch self {
            case .top:
                return .bottom
            case .bottom:
                return .top
            }
        }

    }

    // MARK: - Private
    private let text: String
    private let type: FlipType
}

struct SingleFlipView_Previews: PreviewProvider {
    static var previews: some View {
        SingleFlipView(text: "A", type: .bottom)
            .rotation3DEffect(
                .init(degrees: -0),
                axis: (1, 0, 0),
                anchor: .top,
                perspective: 0.5)
    }
}
