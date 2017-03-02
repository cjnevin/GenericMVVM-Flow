import UIKit

//: Protocols

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

protocol ViewType {
    associatedtype ViewModel
    
    var viewModel: ViewModel { get }
    
    init(viewModel: ViewModel)
    func bind()
    func layout()
}

enum FlowType {
    case main
    case navigation
}

struct FlowConfiguration {
    let window: UIWindow?
    let navigationController: UINavigationController?
    let parent: FlowControllerType?
    
    var type: FlowType {
        guard window == nil else {
            return .main
        }
        return .navigation
    }
}

protocol FlowControllerType {
    init(configuration: FlowConfiguration)
    func start()
}

//: BaseViewController Implementation of ViewType

class BaseFlowController: FlowControllerType {
    let configuration: FlowConfiguration
    var childFlow: FlowControllerType?
    
    required init(configuration: FlowConfiguration) {
        self.configuration = configuration
    }
    
    func start() {
        fatalError("start() has not been implemented")
    }
    
    func makeChildConfiguration() -> FlowConfiguration {
        return FlowConfiguration(window: nil, navigationController: configuration.navigationController, parent: self)
    }
}

class BaseViewController<T: ViewModelType>: UIViewController, ViewType {
    typealias ViewModel = T
    
    let viewModel: T
    
    required init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.layout()
        self.bind()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func layout() {
        fatalError("layout() has not been implemented")
    }
    
    func bind() {
        fatalError("bind() has not been implemented")
    }
}

//: Main Flow

class MainFlowController: BaseFlowController {
    private var onboarded: Bool = false
    
    override func start() {
        let navigationController = UINavigationController()
        configuration.window?.rootViewController = navigationController
        configuration.window?.makeKeyAndVisible()
        
        if !onboarded {
            let onboardingConfiguration = FlowConfiguration(window: nil, navigationController: navigationController, parent: self)
            childFlow = OnboardingFlowController(configuration: onboardingConfiguration)
            childFlow?.start()
        } else {
            let tabbedConfiguration = FlowConfiguration(window: nil, navigationController: navigationController, parent: self)
            childFlow = TabbedFlowController(configuration: tabbedConfiguration)
            childFlow?.start()
        }
    }
}

//: Tabbed Flow

class TabbedFlowController: BaseFlowController {
    private let tabBarController = UITabBarController()
    var childFlows: [FlowControllerType]?
    
    override func start() {
        let tabANavigationController = UINavigationController()
        let tabAConfiguration = FlowConfiguration(window: nil, navigationController: tabANavigationController, parent: self)
        tabBarController.setViewControllers([tabANavigationController], animated: false)
        
        childFlows = [TabAFlowController(configuration: tabAConfiguration)]
        childFlows?.forEach({ $0.start() })
    }
}

protocol TabAFlowControllerType: FlowControllerType {
    func showDetail()
}

class TabAFlowController: BaseFlowController, TabAFlowControllerType {
    override func start() {
        let viewModel = TabAViewModel(flowController: self)
        let viewController = TabAViewController(viewModel: viewModel)
        configuration.navigationController?.viewControllers = [viewController]
    }
    
    func showDetail() { }
}

class TabAViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let flowController: TabAFlowControllerType
    
    init(flowController: TabAFlowControllerType) {
        self.flowController = flowController
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class TabAViewController: BaseViewController<TabAViewModel> {
    override func layout() { }
    override func bind() { }
}

//: Onboarding Flow

class OnboardingViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let flowController: OnboardingFlowControllerType
    
    init(flowController: OnboardingFlowControllerType) {
        self.flowController = flowController
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class OnboardingViewController: BaseViewController<OnboardingViewModel> {
    override func layout() { }
    
    override func bind() { }
}

protocol OnboardingFlowControllerType: FlowControllerType {
    func openOptionPicker()
}

class OnboardingFlowController: BaseFlowController, OnboardingFlowControllerType {
    override func start() {
        let viewModel = OnboardingViewModel(flowController: self)
        let viewController = OnboardingViewController(viewModel: viewModel)
        configuration.navigationController?.viewControllers = [viewController]
    }
    
    func openOptionPicker() {
        childFlow = OptionPickerFlowController(configuration: makeChildConfiguration())
        childFlow?.start()
    }
}

//: Option Picker Flow

protocol OptionPickerFlowControllerType: FlowControllerType {
    func openOptionA()
    func openOptionB()
    func finish()
}

class OptionPickerViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let flowController: OptionPickerFlowControllerType
    
    init(flowController: OptionPickerFlowControllerType) {
        self.flowController = flowController
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class OptionPickerViewController: BaseViewController<OptionPickerViewModel> {
    override func layout() { }
    override func bind() { }
}

class OptionPickerFlowController: BaseFlowController, OptionPickerFlowControllerType {
    private let navigationController = UINavigationController()
    
    override func start() {
        let viewModel = OptionPickerViewModel(flowController: self)
        let viewController = OptionPickerViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        configuration.navigationController?.present(navigationController, animated: true)
    }
    
    func openOptionA() {
        childFlow = OptionBFlowController(configuration: makeChildConfiguration())
        childFlow?.start()
    }
    
    func openOptionB() {
        childFlow = OptionAFlowController(configuration: makeChildConfiguration())
        childFlow?.start()
    }
    
    func finish() {
        configuration.navigationController?.dismiss(animated: true, completion: nil)
    }
}


//: Option A Flow

protocol OptionAFlowControllerType: FlowControllerType {
    func finish()
}

class OptionAViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let flowController: OptionAFlowControllerType
    
    init(flowController: OptionAFlowControllerType) {
        self.flowController = flowController
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class OptionAViewController: BaseViewController<OptionAViewModel> {
    override func layout() { }
    override func bind() { }
}

class OptionAFlowController: BaseFlowController, OptionAFlowControllerType {
    override func start() {
        let viewModel = OptionAViewModel(flowController: self)
        let viewController = OptionAViewController(viewModel: viewModel)
        configuration.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        _ = configuration.navigationController?.popViewController(animated: true)
    }
}

//: Option B Flow

protocol OptionBFlowControllerType: FlowControllerType {
    func finish()
}

class OptionBViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let flowController: OptionBFlowControllerType
    
    init(flowController: OptionBFlowControllerType) {
        self.flowController = flowController
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class OptionBViewController: BaseViewController<OptionBViewModel> {
    override func layout() { }
    override func bind() { }
}

class OptionBFlowController: BaseFlowController, OptionBFlowControllerType {
    override func start() {
        let viewModel = OptionBViewModel(flowController: self)
        let viewController = OptionBViewController(viewModel: viewModel)
        configuration.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        _ = configuration.navigationController?.popViewController(animated: true)
    }
}


