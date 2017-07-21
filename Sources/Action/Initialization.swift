import XCERequirement

//===

public
extension Feature
{
    static
    var initialization: Initialization<Self>.Type
    {
        return Initialization<Self>.self
    }
}

//===

public
enum Initialization<F: Feature>
{
    public
    enum Into<S: FeatureState> where S.ParentFeature == F { }
}

//===

public
extension Initialization.Into where S: SimpleState
{
    public
    static
    func automatic(
        action: String = #function
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, mutate, _ in
            
            try REQ.isNil("\(S.ParentFeature.name) is NOT initialized yet") {
                
                model ==> S.ParentFeature.self
            }
            
            //===
            
            mutate { $0 <== S.init() }
        }
    }
}

//===

public
extension Initialization.Into
{
    public
    static
    func via(
        action: String = #function,
        body: @escaping (Wrapped<StateGetter<S>>, @escaping Wrapped<ActionGetter>) throws -> Void
        ) -> Action
    {
        return Action(name: action, feature: F.self) { model, mutate, submit in
            
            try REQ.isNil("\(S.ParentFeature.name) is NOT initialized yet") {
                
                model ==> S.ParentFeature.self
            }
            
            //===
            
            var newState: S!
            
            //===
            
            // http://alisoftware.github.io/swift/closures/2016/07/25/closure-capture-1/
            // capture 'var' value by reference here!
            
            try body({ newState = $0() }, submit)
            
            //===
            
            mutate { $0 <== newState }
        }
    }
}
