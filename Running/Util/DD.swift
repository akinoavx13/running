//
//  DD.swift
//  Running
//
//  Created by Maxime Maheo on 08/03/2022.
//

#if DEBUG
func dd(_ parameters: Any...) {
    print("DD:", parameters.map { "\($0)" }.joined(separator: " • "))
}
#endif
