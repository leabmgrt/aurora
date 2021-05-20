//
// Aurora
// File created by Adrian Baumgart on 05.04.21.
//
// Licensed under the MIT License
// Copyright © 2020 Adrian Baumgart. All rights reserved.
//
// https://git.abmgrt.dev/exc_bad_access/aurora
//

import SwiftUI

struct ProjectLoadBalancerDetailGraphsView: View {
    @ObservedObject var controller: ProjectLoadBalancerDetailGraphsController

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
            controller.loadData()
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

    func getGraphData(_ metrics: CloudLoadBalancerMetricsTimeSeries) -> [ServerGraphDataPoint] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy HH:mm"
        return metrics.values.map { ServerGraphDataPoint(date: $0.date, formattedDate: dateFormatter.string(from: $0.date), value: CGFloat($0.value)) }
    }
}

class ProjectLoadBalancerDetailGraphsController: ObservableObject {
    @Published var project: CloudProject!
    @Published var loadBalancer: CloudLoadBalancer!
    @Published var metrics: CloudLoadBalancerMetrics? = nil
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

    init(project: CloudProject, loadBalancer: CloudLoadBalancer) {
        self.project = project
        self.loadBalancer = loadBalancer
    }

    func loadData() {
        metrics = nil
        project.api!.loadLoadBalancerMetrics(loadBalancer.id, minutes: selectedDuration, step: selectedAmountOfSteps) { result in
            switch result {
            case let .failure(err):
                cloudAppSplitViewController.showError(err)
            case let .success(newmetrics):
                self.metrics = newmetrics
            }
        }
    }
}

struct ProjectLoadBalancerDetailGraphsView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectLoadBalancerDetailGraphsView(controller: .init(project: .example, loadBalancer: .example))
    }
}
