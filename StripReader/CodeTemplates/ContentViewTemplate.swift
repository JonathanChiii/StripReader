//
//  ContentView.swift
//  StripReader
//
//  Created by jOnAtHaN Chi on 11/9/25.
//

import SwiftUI

struct Reader{
    let target: Int = 0
}

struct ContentViewTemplate: View {
    @State private var alertIsVisible:Bool = false
    @State private var sliderValue:Float = 50.0
    @State private var reader: Reader = Reader()
    @State private var path: [String] = []

    var body: some View {
        
        NavigationStack(path: $path) {
            VStack {
                Button("Go to A") { path.append("A") }
                Button("Go to B") { path.append("B") }
            }
            .navigationDestination(for: String.self) { value in
                Text("Destination: \(value)")
            }
            .navigationTitle("Home")
        }
        
        
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Welcome Testers")
                .font(.largeTitle)
                .fontWeight(.black)
            Text("This is the target: \(String(reader.target))")
            Slider(value: self.$sliderValue, in: 1.0...100.0)
            Text("Slider Value: \(Int(self.sliderValue.rounded()))")
            Button("Open Camera") {
                print("Hello")
                print("\(self.alertIsVisible)")
                self.alertIsVisible = true
                print("\(self.alertIsVisible)")
            }.alert(isPresented: $alertIsVisible, content: {
                return Alert(title: Text("Hello~"), message: Text("First Popup"), dismissButton: .default(Text("cancel")))
            })
        }
        .padding()
    }
}

//#Preview {
//    ContentViewTemplate()
//}
