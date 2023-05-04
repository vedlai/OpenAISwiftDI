//
//  SwiftUIView.swift
//  
//
//  Created by vedlai on 5/4/23.
//

import SwiftUI
@available(macOS 12.0, *)
@available(iOS 15.0, *)
public struct EditsSampleView: View {
    @State private var request: EditRequest = .init(instruction: "")
    @State private var response: EditResponse?
    public init(){}
    public var body: some View {
        Form{
            Section("Request") {
                HStack{
                    Text("Input: ")
                    TextField("Add input here", text: .init($request.input, ""))
                        .lineLimit(1)
                }
                HStack{
                    Text("Instruction: ")
                    TextField("Add instruction here", text: $request.instruction)
                        .lineLimit(1)
                        
                }
                
                EditsButtonView(request: request, response: $response)
                    .disabled(request.instruction.isEmpty)
                    .buttonStyle(.borderedProminent)

            }
            Section("Response") {
                if let first = response?.choices.first{
                    Text(first.text)
                }else{
                    Text("Enter input and response, then submit.")
                }
            }
        }
    }
}
@available(macOS 12.0, *)
@available(iOS 15.0, *)
struct EditsSampleView_Previews: PreviewProvider {
    static var previews: some View {
        EditsSampleView()
    }
}
