# GenericMVVM-Flow

An example MVVM + Flow implementation. 

Model refers to the raw data being used by the ViewModel, this can also include UseCases etc
View renders state of ViewModel with bindings
ViewModel uses inputs and outputs to support View presentation, calls Wireframe at appropriate times
Wireframe manages navigation between screens (aka: flow, router)
