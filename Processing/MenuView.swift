//
//  MenuView.swift
//  Processing
//
//  Created by Matthew Johnson on 6/21/19.
//  Copyright © 2019 Anandabits LLC. All rights reserved.
//

import SwiftUI

struct MenuView: View {
    enum Item: String, CaseIterable {
        case circleOfDots = "Circle of Dots"
        case lines = "Lines"
        case spinner = "Spinner"
        case spread = "Spread"
        case triangles = "Trianges"
        case twister = "Twister"

        var view: AnyView {
            switch self {
            case .circleOfDots: return AnyView(CircleOfDots())
            case .lines:        return AnyView(LinesView())
            case .spinner:      return AnyView(SpinnerView())
            case .spread:       return AnyView(SpreadView())
            case .triangles:    return AnyView(TrianglesView())
            case .twister:      return AnyView(TwisterView())
            }
        }
    }

    var body: some View {
        NavigationView {
            List(Item.allCases.identified(by: \.rawValue)) { item in
                NavigationButton(destination: item.view) { Text(verbatim: item.rawValue) }
            }
            .navigationBarTitle(Text("SwiftUI Animations"))
        }
    }
}

#if DEBUG
struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
#endif
