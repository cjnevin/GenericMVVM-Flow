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
    let parent: FlowController?
    
    var type: FlowType {
        guard window == nil else {
            return .main
        }
        return .navigation
    }
}

protocol FlowController {
    init(configuration: FlowConfiguration)
    func start()
}

//: BaseViewController Implementation of ViewType

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

class MainFlowController: FlowController {
    private let configuration: FlowConfiguration
    var childFlow : FlowController?
    
    private var onboarded: Bool = false
    
    
    required init(configuration: FlowConfiguration) {
        assert(configuration.type == .main)
        self.configuration = configuration
    }
    
    func start() {
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

class TabbedFlowController: FlowController {
    private let configuration: FlowConfiguration
    var childFlows: [FlowController]?
    
    required init(configuration: FlowConfiguration) {
        assert(configuration.type == .main)
        self.configuration = configuration
    }
    
    func start() { }
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

protocol OnboardingFlowControllerType: FlowController {
    func openOptionPicker()
}

class OnboardingFlowController: OnboardingFlowControllerType {
    private let configuration: FlowConfiguration
    var childFlow : FlowController?
    
    required init(configuration: FlowConfiguration) {
        self.configuration = configuration
    }

    func start() {
        let viewModel = OnboardingViewModel(flowController: self)
        let viewController = OnboardingViewController(viewModel: viewModel)
        configuration.navigationController?.viewControllers = [viewController]
    }
    
    func openOptionPicker() {
        let optionPickerConfiguration = FlowConfiguration(window: nil, navigationController: configuration.navigationController, parent: self)
        childFlow = OptionPickerFlowController(configuration: optionPickerConfiguration)
        childFlow?.start()
    }
}

//: Option Picker Flow

protocol OptionPickerFlowControllerType: FlowController {
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

class OptionPickerFlowController: OptionPickerFlowControllerType {
    private let configuration: FlowConfiguration
    private let navigationController = UINavigationController()
    var childFlow: FlowController?
    
    required init(configuration: FlowConfiguration) {
        self.configuration = configuration
    }
    
    func start() {
        let viewModel = OptionPickerViewModel(flowController: self)
        let viewController = OptionPickerViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        configuration.navigationController?.present(navigationController, animated: true)
    }
    
    func openOptionA() {
        let optionAConfiguration = FlowConfiguration(window: nil, navigationController: configuration.navigationController, parent: self)
        childFlow = OptionBFlowController(configuration: optionAConfiguration)
        childFlow?.start()
    }
    
    func openOptionB() {
        let optionBConfiguration = FlowConfiguration(window: nil, navigationController: configuration.navigationController, parent: self)
        childFlow = OptionAFlowController(configuration: optionBConfiguration)
        childFlow?.start()
    }
    
    func finish() {
        configuration.navigationController?.dismiss(animated: true, completion: nil)
    }
}


//: Option A Flow

protocol OptionAFlowControllerType: FlowController {
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

class OptionAFlowController: OptionAFlowControllerType {
    private let configuration: FlowConfiguration
    
    required init(configuration: FlowConfiguration) {
        self.configuration = configuration
    }
    
    func start() {
        let viewModel = OptionAViewModel(flowController: self)
        let viewController = OptionAViewController(viewModel: viewModel)
        configuration.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        _ = configuration.navigationController?.popViewController(animated: true)
    }
}

//: Option B Flow

protocol OptionBFlowControllerType: FlowController {
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

class OptionBFlowController: OptionBFlowControllerType {
    private let configuration: FlowConfiguration
    
    required init(configuration: FlowConfiguration) {
        self.configuration = configuration
    }
    
    func start() {
        let viewModel = OptionBViewModel(flowController: self)
        let viewController = OptionBViewController(viewModel: viewModel)
        configuration.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        _ = configuration.navigationController?.popViewController(animated: true)
    }
}


