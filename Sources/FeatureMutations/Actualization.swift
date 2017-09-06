/*
 
 MIT License
 
 Copyright (c) 2016 Maxim Khatskevich (maxim@khatskevi.ch)
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 
 */

import XCERequirement

//===

public
extension Feature
{
    static
    var actualize: Actualization<Self>.Type
    {
        return Actualization<Self>.self
    }
}

//===

public
struct Actualization<F: Feature>: GlobalMutationExt
{
    public
    struct In<S: FeatureState> where S.ParentFeature == F
    // swiftlint:disable:previous type_name
    {
        public
        let state: S
    }
    
    //===
    
    static
    var kind: FeatureMutationKind { return .update }
    
    let apply: (GlobalModel) -> GlobalModel
    
    //===
    
    public
    let state: FeatureRepresentation
    
    //===
    
    init<S: FeatureState>(in state: S) where S.ParentFeature == F
    {
        self.state = state
        self.apply = { $0.store(state) }
    }
}

public
typealias ActualizationIn<S: FeatureState> = Actualization<S.ParentFeature>.In<S>

//===

public
extension Actualization.In
{
    static
    func via(
        scope: String = #file,
        context: String = #function,
        body: @escaping (S, Mutate<S>, @escaping SubmitAction) throws -> Void
        ) -> Action
    {
        return Action(scope, context, self) { model, submit in
            
            var state =
                
            try Require("\(S.ParentFeature.name) is in \(S.self) state").isNotNil(
                
                model >> S.self
            )
            
            //---
            
            try body(state, { state = $0 }, submit)
            
            //---
            
            return Actualization(in: state)
        }
    }
}
