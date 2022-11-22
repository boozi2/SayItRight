//
//  CategoryView.swift
//  SayItRight
//
//  Created by Boaz Saragossi on 24/04/2022.
//

import Foundation
import SwiftUI


struct CategoryView: View {
    
    let animales = ["Dog", "Cat", "Fish", "Butterfly", "Camel", "Mouse", "Seahorse", "Snail", "Bear", "Unicorn", "Bunny", "Bird", "Monkey", "Pig", "Frog"]
    let food = ["Icecreram", "Hotdog", "Cupcake"]

    
    init() {

    }
    
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: ContentView(words:animales)) {
                    Image("AnimalesCat")
                        .resizable()
                        .frame(width: 150.0, height: 150.0)
                }
                NavigationLink(destination: ContentView(words:food)) {
                    Image("FoodCat")
                        .resizable()
                        .frame(width: 150.0, height: 150.0)
                }//.navigationBarTitle("Food")
            }.navigationTitle("Categories")
        }
    }
}
