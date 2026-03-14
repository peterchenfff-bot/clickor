import SwiftUI

struct OverlayContentView: View {
    @ObservedObject var manager: ClickManager
    @State private var clicks: [ClickData] = []

    var body: some View {
        ZStack {
            Color.clear.edgesIgnoringSafeArea(.all)
            ForEach(clicks, id: \.id) { click in
                RippleEffect(location: click.point) {
                    clicks.removeAll(where: { $0.id == click.id })
                }
            }
        }
        .onChange(of: manager.lastClick?.id) { _ in
            if let newClick = manager.lastClick {
                clicks.append(newClick)
            }
        }
    }
}

struct RippleEffect: View {
    let location: CGPoint
    var onFinished: () -> Void
    
    // We use RawRepresentable Color to make AppStorage happy
    @AppStorage("rippleColor") private var rippleColor: Color = .yellow
    @AppStorage("rippleSize") private var rippleSize = 40.0
    @AppStorage("rippleDuration") private var rippleDuration = 0.4

    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 1.0

    var body: some View {
        Circle()
            .stroke(rippleColor, lineWidth: 3)
            .frame(width: rippleSize, height: rippleSize)
            .scaleEffect(scale)
            .opacity(opacity)
            .position(location)
            .onAppear {
                withAnimation(.easeOut(duration: rippleDuration)) {
                    scale = 2.0
                    opacity = 0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + rippleDuration) {
                    onFinished()
                }
            }
    }
}


