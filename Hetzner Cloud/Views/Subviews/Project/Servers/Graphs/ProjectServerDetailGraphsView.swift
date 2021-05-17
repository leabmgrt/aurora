//
// Hetzner Cloud App (Hetzner Cloud)
// File created by Adrian Baumgart on 01.04.21.
//
// Licensed under the MIT License
// Copyright © 2021 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/hetznercloudapp-ios
//

import SwiftUI
//import SwiftUICharts

struct ProjectServerDetailGraphsView: View {
    @ObservedObject var controller: ProjectServerDetailGraphsController

    var body: some View {
        Group {
            if controller.metrics != nil {
                VStack {
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing) {
                            Picker(selection: $controller.selectedDuration, label: Text("Time span: \(getTimeSpanName(controller.selectedDuration))")) {
                                if controller.selectedAmountOfSteps <= 900 {
                                    Text("15 minutes").tag(15)
                                }
                                if controller.selectedAmountOfSteps <= 1800 {
                                    Text("30 minutes").tag(30)
                                }
                                Text("60 minutes").tag(60)
                                Text("6 hours").tag(360)
                                Text("12 hours").tag(720)
                                Text("24 hours").tag(1440)
                                Text("1 week").tag(10080)
                                Text("30 days").tag(43200)
                            }.pickerStyle(MenuPickerStyle()).padding([.leading, .trailing])
                            Picker(selection: $controller.selectedAmountOfSteps, label: Text("Resolution of results: \(getStepName(Int(controller.metrics?.step ?? Double(controller.selectedAmountOfSteps))))")) {
                                Text("1 second").tag(1)
                                Text("5 seconds").tag(5)
                                Text("30 seconds").tag(30)
                                Text("1 minute").tag(60)
                                Text("5 minutes").tag(300)
                                Text("10 minutes").tag(600)
                                Text("15 minutes").tag(900)
                                if controller.selectedDuration >= 30 {
                                    Text("30 minutes").tag(1800)
                                }
                                if controller.selectedDuration >= 60 {
                                    Text("60 minutes").tag(3600)
                                }
                            }.pickerStyle(MenuPickerStyle()).padding([.leading, .trailing])
                        }
                    }
                    ScrollView {
                        Group {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 300), alignment: .top)], alignment: .center, spacing: nil, pinnedViews: [], content: {
                                ForEach(controller.metrics!.time_series.sorted(by: { $0.name < $1.name }), id: \.name) { series in
                                    ServerGraph(title: series.name, dataPoints: getGraphData(series)).padding()
                                }
                            })
                        }.padding()
                    }
                }
            } else {
                VStack {
                    ProgressView().progressViewStyle(CircularProgressViewStyle())
                    Text("Loading...").padding()
                }
            }
        }.navigationBarTitle(Text("Graphs")).onAppear {
            if controller.metrics == nil {
                // prevent loading multiple times on first appear (apparently this function is called when the other view renders... :/)
                controller.loadData()
            }
        }
    }

    func getTimeSpanName(_ span: Int) -> String {
        switch span {
        case 15: return "15 minutes"
        case 30: return "30 minutes"
        case 60:
            return "60 minutes"
        case 360: return "6 hours"
        case 720: return "12 hours"
        case 1440: return "24 hours"
        case 10080: return "1 week"
        case 43200: return "30 days"
        default: return "\(span) minute\(span != 1 ? "s" : "")"
        }
    }

    func getStepName(_ steps: Int) -> String {
        if steps < 60 {
            return "\(steps) second\(steps != 1 ? "s" : "")"
        } else {
            let minutes = steps / 60
            return "\(minutes) minute\(minutes != 1 ? "s" : "")"
        }
    }

    func getBarChartData(_ metrics: CloudServerMetricsTimeSeries) -> [(String, Double)] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        return metrics.values.map { ("\(dateFormatter.string(from: $0.date))", $0.value) }
    }

    func getGraphData(_ metrics: CloudServerMetricsTimeSeries) -> [ServerGraphDataPoint] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        return metrics.values.map { ServerGraphDataPoint(date: $0.date, formattedDate: dateFormatter.string(from: $0.date), value: CGFloat($0.value)) }
    }
}

struct ProjectServerDetailGraphsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ProjectServerDetailGraphsView(controller: .init(project: .example, server: .example))
        }
    }
}

class ProjectServerDetailGraphsController: ObservableObject {
    @Published var project: CloudProject
    @Published var server: CloudServer
    @Published var metrics: CloudServerMetrics? = nil
    @Published var selectedDuration: Int = 60 { // Minutes
        didSet {
            loadData()
        }
    }

    @Published var selectedAmountOfSteps: Int = 60 { // Seconds
        didSet {
            loadData()
        }
    }

    init(project: CloudProject, server: CloudServer) {
        self.project = project
        self.server = server
    }

    func loadData() {
        metrics = nil
        project.api!.loadServerMetrics(server.id, minutes: selectedDuration, step: selectedAmountOfSteps) { result in
            switch result {
            case let .failure(err):
                cloudAppSplitViewController.showError(err)
            case let .success(newmetrics):
                self.metrics = newmetrics
            }
        }
    }
}

struct ServerGraph: View {
    var title: String
    var dataPoints: [ServerGraphDataPoint]

    @Environment(\.colorScheme) var colorScheme
    @State var startAnimation = false

    var body: some View {
        Group {
            VStack(alignment: .leading) {
                Text("\(title)").bold().font(.title3)
                HStack {
                    Image(systemName: "arrow.down").foregroundColor(.secondary)
                    Text("\(String(format: "%.2f", dataPoints.sorted(by: { $0.value < $1.value }).first!.value))").foregroundColor(.secondary).font(.caption)
                    Image(systemName: "arrow.up").foregroundColor(.secondary)
                    Text("\(String(format: "%.2f", dataPoints.sorted(by: { $0.value < $1.value }).last!.value))").foregroundColor(.secondary).font(.caption)
                }
                Text("\(getDateFormatter().string(from: dataPoints.sorted(by: { $0.date < $1.date }).first!.date)) - \(getDateFormatter().string(from: dataPoints.sorted(by: { $0.date < $1.date }).last!.date))").foregroundColor(.secondary).font(.caption)
                ZStack {
                    HStack {
                        Spacer()
                        ZStack {
                            ServerGraphGrid(dataPoints: dataPoints)
                                .trim(to: 1)
                                .stroke(colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color(UIColor.secondarySystemBackground))
                                .opacity(colorScheme == .dark ? 0.5 : 0.7)
                                .aspectRatio(16 / 9, contentMode: .fit)
                            ServerGraphShape(dataPoints: dataPoints)
                                .trim(to: startAnimation ? 1 : 0)
                                .stroke(LinearGradient(gradient: Gradient(colors: [.red, .orange, .yellow]), startPoint: .leading, endPoint: .trailing))
                                .aspectRatio(16 / 9, contentMode: .fit)
                        }

                        Spacer()
                    }
                }
            }
        }.padding().background(Rectangle().fill(colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white)).cornerRadius(10).shadow(color: colorScheme == .dark ? Color(UIColor.tertiarySystemBackground) : Color.gray, radius: 3, x: 2, y: 2).frame(minWidth: 300, maxWidth: 300, minHeight: 240, maxHeight: 240).onAppear(perform: {
            withAnimation(.easeInOut(duration: 2)) {
                startAnimation = true
            }
        }) /* .gesture(DragGesture()
         .onChanged({ value in
             print(value.location)
         })
             .onEnded({ value in
                 print(value.location)
             })) */
    }

    func getDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        return dateFormatter
    }
}

struct ServerGraphShape: Shape {
    var dataPoints: [ServerGraphDataPoint]

    func path(in rect: CGRect) -> Path {
        // This was way too complicated and idk what I did so please don't ask me how it works. Example values really helped me so uncomment the print statements below if you need them.

        let lowestXValue = CGFloat(dataPoints.sorted(by: { $0.date < $1.date }).first!.date.timeIntervalSince1970)
        let highestXValue = CGFloat(dataPoints.sorted(by: { $0.date > $1.date }).first!.date.timeIntervalSince1970)
        var highestYValue = dataPoints.sorted(by: { $0.value > $1.value }).first!.value + (dataPoints.sorted(by: { $0.value > $1.value }).first!.value * 0.1)
        highestYValue = highestYValue == 0 ? 1 : highestYValue // Avoid division by 0
        let sortedDataPoints = dataPoints.sorted(by: { $0.date < $1.date })

        /* print("LX: \(lowestXValue)")
         print("HX: \(highestXValue)")
         print("HY: \(highestYValue)")
         let randomElement = sortedDataPoints.randomElement()!
         print("RDX: \(randomElement.date.timeIntervalSince1970)")
         print("RDY: \(randomElement.value)")
         print("REW: \(rect.width)")
         print("REH: \(rect.height)")
         print("-------------------") */

        func calcPoint(at ix: Int) -> CGPoint {
            let point = sortedDataPoints[ix]
            let x = ((CGFloat(point.date.timeIntervalSince1970) - lowestXValue) / (highestXValue - lowestXValue)) * rect.width
            let y = rect.height - ((point.value / highestYValue) * rect.height)
            return .init(x: x, y: y)
        }

        return Path { p in
            // guard dataPoints.count > 1 else { return }
            p.move(to: CGPoint(x: CGFloat(sortedDataPoints[0].date.timeIntervalSince1970) - lowestXValue, y: rect.height - ((sortedDataPoints[0].value / highestYValue) * rect.height)))
            for idx in sortedDataPoints.indices {
                p.addLine(to: calcPoint(at: idx))
            }
        }
    }
}

struct ServerGraphGrid: Shape {
    var dataPoints: [ServerGraphDataPoint]

    func path(in rect: CGRect) -> Path {
        return Path { p in
            guard dataPoints.count > 1 else { return }
            for i in 0 ... 10 {
                p.move(to: .init(x: 0, y: (rect.height / 10) * CGFloat(i)))
                p.addLine(to: .init(x: rect.width, y: (rect.height / 10) * CGFloat(i)))
            }
        }
    }
}

struct ServerGraphDataPoint {
    var date: Date
    var formattedDate: String
    var value: CGFloat
}
