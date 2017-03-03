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

struct WireframeConfiguration {
    let window: UIWindow?
    let navigationController: UINavigationController?
    let parent: WireframeType?
    
    init(window: UIWindow? = nil, navigationController: UINavigationController? = nil, parent: WireframeType? = nil) {
        assert(window != nil || (navigationController != nil && parent != nil))
        self.window = window
        self.navigationController = navigationController
        self.parent = parent
    }
}

protocol WireframeType {
    init(configuration: WireframeConfiguration)
    func start()
}

class BaseWireframe: WireframeType {
    let configuration: WireframeConfiguration
    
    required init(configuration: WireframeConfiguration) {
        self.configuration = configuration
    }
    
    func start() {
        fatalError("start() has not been implemented")
    }
    
    func makeChildConfiguration() -> WireframeConfiguration {
        return WireframeConfiguration(navigationController: configuration.navigationController, parent: self)
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

//: Main Wireframe

class MainWireframe: BaseWireframe {
    private var onboarded: Bool = false
    private var childWireframe: WireframeType?
    
    override func start() {
        let navigationController = UINavigationController()
        configuration.window?.rootViewController = navigationController
        configuration.window?.makeKeyAndVisible()
        
        if !onboarded {
            let onboardingConfiguration = WireframeConfiguration(navigationController: navigationController, parent: self)
            childWireframe = OnboardingWireframe(configuration: onboardingConfiguration)
            childWireframe?.start()
        } else {
            let tabbedConfiguration = WireframeConfiguration(navigationController: navigationController, parent: self)
            childWireframe = TabbedWireframe(configuration: tabbedConfiguration)
            childWireframe?.start()
        }
    }
}

//: Tabbed Wireframe

class TabbedWireframe: BaseWireframe {
    private let tabBarController = UITabBarController()
    private var childWireframes: [WireframeType]?
    
    override func start() {
        let tabANavigationController = UINavigationController()
        let tabAConfiguration = WireframeConfiguration(navigationController: tabANavigationController, parent: self)
        tabBarController.setViewControllers([tabANavigationController], animated: false)
        
        childWireframes = [TabAWireframe(configuration: tabAConfiguration)]
        childWireframes?.forEach({ $0.start() })
    }
}

protocol TabAWireframeType: WireframeType {
    func showDetail()
}

class TabAWireframe: BaseWireframe, TabAWireframeType {
    override func start() {
        let viewModel = TabAViewModel(wireframe: self)
        let viewController = TabAViewController(viewModel: viewModel)
        configuration.navigationController?.viewControllers = [viewController]
    }
    
    func showDetail() { }
}

class TabAViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let wireframe: TabAWireframeType
    
    init(wireframe: TabAWireframeType) {
        self.wireframe = wireframe
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class TabAViewController: BaseViewController<TabAViewModel> {
    override func layout() { }
    override func bind() { }
}

//: Onboarding Wireframe

class OnboardingViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let wireframe: OnboardingWireframeType
    
    init(wireframe: OnboardingWireframeType) {
        self.wireframe = wireframe
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class OnboardingViewController: BaseViewController<OnboardingViewModel> {
    override func layout() { }
    
    override func bind() { }
}

protocol OnboardingWireframeType: WireframeType {
    func openOptionPicker()
}

class OnboardingWireframe: BaseWireframe, OnboardingWireframeType {
    private var childWireframe: WireframeType?
    
    override func start() {
        let viewModel = OnboardingViewModel(wireframe: self)
        let viewController = OnboardingViewController(viewModel: viewModel)
        configuration.navigationController?.viewControllers = [viewController]
    }
    
    func openOptionPicker() {
        childWireframe = OptionPickerWireframe(configuration: makeChildConfiguration())
        childWireframe?.start()
    }
}

//: Option Picker Wireframe

protocol OptionPickerWireframeType: WireframeType {
    func openOptionA()
    func openOptionB()
    func finish()
}

class OptionPickerViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let wireframe: OptionPickerWireframeType
    
    init(wireframe: OptionPickerWireframeType) {
        self.wireframe = wireframe
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class OptionPickerViewController: BaseViewController<OptionPickerViewModel> {
    override func layout() { }
    override func bind() { }
}

class OptionPickerWireframe: BaseWireframe, OptionPickerWireframeType {
    private let navigationController = UINavigationController()
    private var childWireframe: WireframeType?
    
    override func start() {
        let viewModel = OptionPickerViewModel(wireframe: self)
        let viewController = OptionPickerViewController(viewModel: viewModel)
        navigationController.viewControllers = [viewController]
        configuration.navigationController?.present(navigationController, animated: true)
    }
    
    func openOptionA() {
        childWireframe = OptionBWireframe(configuration: makeChildConfiguration())
        childWireframe?.start()
    }
    
    func openOptionB() {
        childWireframe = OptionAWireframe(configuration: makeChildConfiguration())
        childWireframe?.start()
    }
    
    func finish() {
        configuration.navigationController?.dismiss(animated: true, completion: nil)
    }
}


//: Option A Wireframe

protocol OptionAWireframeType: WireframeType {
    func finish()
}

class OptionAViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let wireframe: OptionAWireframeType
    
    init(wireframe: OptionAWireframeType) {
        self.wireframe = wireframe
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class OptionAViewController: BaseViewController<OptionAViewModel> {
    override func layout() { }
    override func bind() { }
}

class OptionAWireframe: BaseWireframe, OptionAWireframeType {
    override func start() {
        let viewModel = OptionAViewModel(wireframe: self)
        let viewController = OptionAViewController(viewModel: viewModel)
        configuration.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        _ = configuration.navigationController?.popViewController(animated: true)
    }
}

//: Option B Wireframe

protocol OptionBWireframeType: WireframeType {
    func finish()
}

class OptionBViewModel: ViewModelType {
    typealias Input = Int
    typealias Output = Int
    
    private let wireframe: OptionBWireframeType
    
    init(wireframe: OptionBWireframeType) {
        self.wireframe = wireframe
    }
    
    func transform(input: Int) -> Int {
        return 0
    }
}

class OptionBViewController: BaseViewController<OptionBViewModel> {
    override func layout() { }
    override func bind() { }
}

class OptionBWireframe: BaseWireframe, OptionBWireframeType {
    override func start() {
        let viewModel = OptionBViewModel(wireframe: self)
        let viewController = OptionBViewController(viewModel: viewModel)
        configuration.navigationController?.pushViewController(viewController, animated: true)
    }
    
    func finish() {
        _ = configuration.navigationController?.popViewController(animated: true)
    }
}


