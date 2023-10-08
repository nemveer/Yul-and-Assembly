// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract BasicOperations {
    /// @notice only adds even numbers
    function forLoopForEven(uint upto) external returns (uint256){
        uint256 sum;

        assembly {

            for {let i := 1} lt(i, upto) { i := add(i, 1)}
            {
                if iszero(mod(i, 2)) {
                    sum := add(sum, i)
                } 
            }

            /// @notice These both are equivalent, but `{}` are necessary otherwise it won't compile
            // let i := 1
            // for {} lt(i, upto) {} 
            // {
            //     //...
            //     i := add(i, 1)
            // }

            let pointer := mload(0x40)
            mstore(pointer, sum)
            return(pointer, 0x20)
        }
    }

    function forLoopForOdd(uint upto) external pure returns(uint256) {
        assembly {
            let sum
            let i := 0

            for {} lt(i, upto) {} {
                if mod(i, 2) {
                    sum := add(sum, i)
                }
                i := add(i, 1)
            } 
            let pointer:=mload(0x40)
            mstore(pointer, sum)
            return(pointer, 0x20)
        }
    }


    /// @notice should not use `not` for negation
    /// @notice best way to negation is by uing iszero on true condition
}