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

struct CoordinatorConfiguration {
    let window: UIWindow?
    let navigationController: UINavigationController?
    let parent: CoordinatorType?
    
    init(window: UIWindow? = nil, navigationController: UINavigationController? = nil, parent: CoordinatorType? = nil) {
        assert(window != nil || (navigationController != nil && parent != nil))
        self.window = window
        self.navigationController = navigationController
        self.parent = parent
    }
}

protocol CoordinatorType {
    init(configuration: CoordinatorConfiguration)
    func start()
}

class BaseCoordinator: CoordinatorType {
    let configuration: CoordinatorConfiguration
    
    required init(configuration: CoordinatorConfiguration) {
        self.configuration = configuration
    }
    
    func start() {
        fatalError("start() has not been implemented")
    }
    
    func makeChildConfiguration() -> CoordinatorConfiguration {
        return CoordinatorConfiguration(navigationController: configuration.navigationController, parent: self)
    }
    
    func makeChildCoordinator<T: CoordinatorType>() -> T {
        return T.init(configuration: makeChildConfiguration())
    }
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

//: Main Coordinator

class MainCoordinator: BaseCoordinator {
    private var onboarded: Bool = false
    private var child: CoordinatorType?
    
    override func start() {
        let navigationController = UINavigationController()
        configuration.window?.rootViewController = navigationController
        configuration.window?.makeKeyAndVisible()
        
        if !onboarded {
            let onboardingConfiguration = CoordinatorConfiguration(navigationController: navigationController, parent: self)
            child = OnboardingCoordinator(configuration: onboardingConfiguration)
            child?.start()
        } else {
            let tabbedConfiguration = CoordinatorConfiguration(navigationController: navigationController, parent: self)
            child = TabbedCoordinator(configuration: tabbedConfiguration)
            child?.start()
        }
    }
}

//: Tabbed Coordinator

class TabbedCoordinator: BaseCoordinator {
    private let tabBarController = UITabBarController()
    private var children: [CoordinatorType]?
    
    override func start() {
        let tabANavigationController = UINavigationController()
        let tabAConfiguration = CoordinatorConfiguration(navigationController: tabANavigationController, parent: self)
        tabBarController.setViewControllers([tabANavigationController], animated: false)
        
        children = [TabACoordinator(configuration: tabAConfiguration)]
        children?.forEach({ $0.start() })
    }
}

protocol TabACoordinatorType: CoordinatorType {
    func showDetail()
}

class TabACoordinator: BaseCoordinator, TabACoordinatorType {
    override func start() {
        let viewModel = TabAViewModel(coordinator: self)
        let viewController = TabAViewController(viewModel: viewModel)
        configuration.navigationController?.viewControllers = [viewController]
    }
    
    func showDetail() { }
}

class TabAViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let coordinator: TabACoordinatorType
    
    init(coordinator: TabACoordinatorType) {
        self.coordinator = coordinator
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class TabAViewController: BaseViewController<TabAViewModel> {
    override func layout() { }
    override func bind() { }
}

//: Onboarding Coordinator

class OnboardingViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let coordinator: OnboardingCoordinatorType
    
    init(coordinator: OnboardingCoordinatorType) {
        self.coordinator = coordinator
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class OnboardingViewController: BaseViewController<OnboardingViewModel> {
    override func layout() { }
    
    override func bind() { }
}

protocol OnboardingCoordinatorType: CoordinatorType {
    func openOptionPicker()
}

class OnboardingCoordinator: BaseCoordinator, OnboardingCoordinatorType {
    private var child: CoordinatorType?
    
    override func start() {
        let viewModel = OnboardingViewModel(coordinator: self)
        let viewController = OnboardingViewController(viewModel: viewModel)
        configuration.navigationController?.viewControllers = [viewController]
    }
    
    func openOptionPicker() {
        child = OptionPickerCoordinator(configuration: makeChildConfiguration())
        child?.start()
    }
}

//: Option Picker Coordinator

protocol OptionPickerCoordinatorType: CoordinatorType {
    func openOptionA()
    func openOptionB()
    func finish()
}

class OptionPickerViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let coordinator: OptionPickerCoordinatorType
    
    init(coordinator: OptionPickerCoordinatorType) {
        self.coordinator = coordinator
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class OptionPickerViewController: BaseViewController<OptionPickerViewModel> {
    override func layout() { }
    override func bind() { }
}

class OptionPickerCoordinator: BaseCoordinator, OptionPickerCoordinatorType {
    private let navigationController = UINavigationController()
    private var child: CoordinatorType?
    
    override func start() {
        let viewModel = OptionPickerViewModel(coordinator: self)
        let viewController = OptionPickerViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        configuration.navigationController?.present(navigationController, animated: true)
    }
    
    func openOptionA() {
        child = OptionBCoordinator(configuration: makeChildConfiguration())
        child?.start()
    }
    
    func openOptionB() {
        child = OptionACoordinator(configuration: makeChildConfiguration())
        child?.start()
    }
    
    func finish() {
        configuration.navigationController?.dismiss(animated: true, completion: nil)
    }
}


//: Option A Coordinator

protocol OptionACoordinatorType: CoordinatorType {
    func finish()
}

class OptionAViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let coordinator: OptionACoordinatorType
    
    init(coordinator: OptionACoordinatorType) {
        self.coordinator = coordinator
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class OptionAViewController: BaseViewController<OptionAViewModel> {
    override func layout() { }
    override func bind() { }
}

class OptionACoordinator: BaseCoordinator, OptionACoordinatorType {
    override func start() {
        let viewModel = OptionAViewModel(coordinator: self)
        let viewController = OptionAViewController(viewModel: viewModel)
        configuration.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        _ = configuration.navigationController?.popViewController(animated: true)
    }
}

//: Option B Coordinator

protocol OptionBCoordinatorType: CoordinatorType {
    func finish()
}

class OptionBViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let coordinator: OptionBCoordinatorType
    
    init(coordinator: OptionBCoordinatorType) {
        self.coordinator = coordinator
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class OptionBViewController: BaseViewController<OptionBViewModel> {
    override func layout() { }
    override func bind() { }
}

class OptionBCoordinator: BaseCoordinator, OptionBCoordinatorType {
    override func start() {
        let viewModel = OptionBViewModel(coordinator: self)
        let viewController = OptionBViewController(viewModel: viewModel)
        configuration.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        _ = configuration.navigationController?.popViewController(animated: true)
    }
}


