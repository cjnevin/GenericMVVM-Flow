# GenericMVVM-Flow

An example MVVM + Flow implementation. 

Model refers to the raw data being used by the ViewModel, this can also include UseCases, ModelControllers, Datasources, etc

View renders state of ViewModel with bindings and passes interaction to ViewModel

ViewModel uses inputs and outputs to support View presentation, calls Wireframe at appropriate times

Wireframe manages navigation between screens (aka: flow, router)
