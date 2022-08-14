//
//  ContentView.swift
//  Edutainment
//
//  Created by Kashish Jain on 24/07/22.
//

import SwiftUI

struct OptionsView: View {
    @State private var table = 2
    @State private var numQuestions = 5
    @State private var slider = 50.0
    @State private var difficulty = 50.0
    
    var startFunc: (Int, Int, Double) -> Void
    var body: some View {
        VStack{
            VStack(spacing: 30){
                VStack(alignment: .leading){
                    Text("Table of")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Stepper("\(table)", value: $table, in: 2...12)
                        .padding()
                        .background(.thickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                VStack(alignment: .leading){
                    Text("Number of questions")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Picker("Number of Questions", selection: $numQuestions){
                        ForEach([5,10,20], id: \.self){ Text("\($0)") }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
                VStack(alignment: .leading){
                    Text("Difficulty")
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Slider(value: $slider, in: 1...100, onEditingChanged: sliderChanged, minimumValueLabel: Text("Easiest"), maximumValueLabel: Text("Hardest")){
                        EmptyView()
                    }
                    .padding()
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding(.bottom, 20)
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
            Spacer()
            Spacer()
            Text("Start")
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(.thickMaterial)
                .foregroundColor(.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .onTapGesture(perform: {startFunc(table, numQuestions, difficulty)})
            Spacer()
        }
        .padding()
    }
    func sliderChanged(_ isChanging: Bool){
        if(!isChanging){
            // roundoff difficluty to multiples of 25
            difficulty = 25*ceil(slider/25)
        }
    }
}

struct GameView: View {
    var backFunc: () -> Void
    var table: Int = 2
    var numQuestions: Int = 5
    var difficulty: Double = 50.0
    
    var maxMult : Int {
        switch difficulty {
        case 25.0:
            return 10
        case 50.0:
            return 15
        case 75.0:
            return 20
        case 100.0:
            return 25
        default:
            return 15
        }
    }
    
    
    @State private var multiplier = 5
    @State private var asked = 0
    @State private var options = [1,1,1,1]
    @State private var degrees = 0.0
    @State private var score = 0
    @State private var showAlert = false
    
    var body: some View{
        VStack{
            Spacer()
            Text("Tap on the answer of")
                .font(.title3)
            HStack{
                Text("\(table)")
                    .font(.system(size: 96, weight: .bold, design: .default))
                Text("X")
                    .font(.system(size: 52, weight: .bold, design: .default))
                Text("\(multiplier)")
                    .font(.system(size: 96, weight: .bold, design: .default))
                    .rotation3DEffect(Angle(degrees: degrees), axis: (x: 1, y: 0, z: 0))
            }
            Spacer()
            Spacer()
            withAnimation{
                ForEach(options, id: \.self){ num in
                    Text("\(num)")
                        .bold()
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .background(.ultraThinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .onTapGesture(perform: {answer(num)})
                }
            }
            Spacer()
            Text("Score: \(score)/\(asked)")
                .font(.title2.bold())
            Spacer()
            Spacer()
        }
        .alert("Game Over", isPresented: $showAlert){
            Button("Restart"){backFunc()}
        } message: {
            Text("Your total score is \(score)/\(asked)")
        }
        .padding()
        .onAppear(perform: askQuestion)
        .toolbar{
            ToolbarItem{
                Button("Options"){backFunc()}
            }
        }
    }
    func answer(_ num: Int){
        asked += 1
        if(num == table*multiplier){
            score += 1
        }
        degrees = 0
        if(asked==numQuestions) {showAlert = true}
        else {askQuestion()}
    }
    func askQuestion(){
        multiplier = Int.random(in: 2...maxMult)
        let op = [table*multiplier, table*Int.random(in: 2...maxMult), table*Int.random(in: 2...maxMult), table*Int.random(in: 2...maxMult)].shuffled()
        options = op
        withAnimation(.easeInOut(duration: 0.5)){
            degrees += 360
        }
    }
}

struct ContentView: View {
    @State private var table = 2
    @State private var numQuestions = 5
    @State private var difficulty = 50.0
    @State private var showOptions = true
    var body: some View {
        NavigationView{
            ZStack{
                LinearGradient(stops: [
                    .init(color: Color(red: 0.76, green: 0.15, blue: 0.26), location: 0.25),
                    .init(color: Color(red: 0.1, green: 0.2, blue: 0.45), location: 0.85),
                ], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
                if showOptions {OptionsView(startFunc: start)}
                else{
                    GameView(backFunc: goBack, table: table, numQuestions: numQuestions, difficulty: difficulty)
                }
            }
            .navigationTitle("Edutainment")
        }
    }
    func goBack(){
        showOptions = true
    }
    func start(table: Int, numQuestions: Int, difficulty: Double){
        self.table = table
        self.numQuestions = numQuestions
        self.difficulty = difficulty
        showOptions = false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
