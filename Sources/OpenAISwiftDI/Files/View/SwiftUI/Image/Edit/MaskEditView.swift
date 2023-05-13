//
//  SwiftUIView.swift
//  
//
//  Created by vedlai on 5/2/23.
//
#if canImport(UIKit)
import SwiftUI
@available(watchOS 8.0, *)
@available(iOS 15.0, *)
public struct MaskEditParentView: View {
    public static func sample (size: ImageSize) -> UIImage {
        ZStack {
            Color.red
            Text(verbatim: .sample)
        }
        .frame(width: size.size, height: size.size)
            .snapshot()

    }
    @State private var image: UIImage = Self.sample(size: .large)
    @State private var mask: UIImage?
    public var body: some View {
        MaskEditView(image: image, mask: $mask)
    }
}
@available(watchOS 8.0, *)
@available(iOS 15.0, *)
public struct MaskEditView: View {
    let image: UIImage
    @Binding var mask: UIImage?
    @State private var size: CGSize = .zero
    @State private var loc: CGPoint = .zero
    var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                let touchLocation = value.location
                let xPoint = image.size.width / size.width
                let yPoint = image.size.height / size.height

                let locationInImageView = CGPoint(x: touchLocation.x * xPoint, y: touchLocation.y * yPoint)

                mask = mask?.processPixels(location: locationInImageView)

                loc = touchLocation
            }
    }
    public init(image: UIImage, mask: Binding<UIImage?>) {
        self.image = image
        self._mask = mask
    }
    @State private var showOriginal: Bool = false

    public var body: some View {
        VStack {
            Text(loc.debugDescription).hidden() // Only here to trigger view updayes
            Text(verbatim: .tapImageToCreateTransparentArea)
            ZStack {
                Color.gray
                if let mask = mask {
                    imageView(mask)
                        .gesture(dragGesture,
                                 including: showOriginal ? .none : .gesture)
                } else {
                    ProgressView()
                        .task {
                            await setMask()
                        }
                }
            }
            .scaledToFit()

            CatchingButton(titleKey: .getString(.reset)) {
                await setMask()
            }
        }
    }

    func imageView(_ image: UIImage) -> some View {
        GeometryReader { geo in
            SwiftUI.Image(uiImage: image)
                .resizable()
                .task(id: geo.size) {
                    size = geo.size
                }
        }
    }
    func setMask() async {
        do {
            self.mask = try image.copy()
        } catch {
            print(error)
        }
    }
}
@available(watchOS 8.0, *)
@available(iOS 15.0, *)
struct MaskEditView_Previews: PreviewProvider {
    static var previews: some View {
        MaskEditParentView()
    }
}
#endif
