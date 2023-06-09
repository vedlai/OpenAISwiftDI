//
//  CatchingButton.swift
//  
//
//  Created by vedlai on 5/1/23.
//

import SwiftUI

@available(macOS 12.0, *)
@available(iOS 15.0, *)
struct CatchingButton<Label>: View where Label: View {
    let label: Label
    let action: () async throws -> Void
    @State private var isProcessing: Bool = false
    @State private var showingAlert: (isPresented: Bool, error: LocalError?) = (false, nil)

    init(@ViewBuilder label: () -> Label, action: @escaping () async throws -> Void) {
        self.label = label()
        self.action = action
    }

    init(titleKey: LocalizedStringKey, action: @escaping () async throws -> Void) where Label == Text {
        self.label = Text(titleKey)
        self.action = action
    }
    var body: some View {
        SwiftUI.Button {
            isProcessing.toggle()
        } label: {
            label
                .overlay {
                    if isProcessing {
                        ZStack {
                            Color.white.opacity(0.7)
                                .blur(radius: 5)
                            ProgressView()
                        }.task {
                                do {
                                    try await action()
                                } catch {
                                    showingAlert = (true, .system(error))
                                    print("🛑 :: \(type(of: self)) :: Alert :: ERROR: \(error)")
                                }
                                isProcessing = false
                            }
                    }
                }
        }.alert(isPresented: $showingAlert.isPresented, error: showingAlert.error) {
            SwiftUI.Button(.getString(.okay)) {
                showingAlert = (false, nil)
            }
        }
    }
    enum LocalError: LocalizedError {
        case system(Error)
        var errorDescription: String? {
            switch self {
            case .system(let error):
                return error.localizedDescription
            }
        }
    }
}
@available(macOS 12.0, *)
@available(iOS 15.0, *)
struct CatchingButtonView_Previews: PreviewProvider {
    static var previews: some View {
        CatchingButton(titleKey: "Test", action: {
            try await Task.sleep(nanoseconds: 1_000_000_000)
            print("test")
        })
    }
}
