// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract YulTypes {

    function getNum1() external pure returns(uint256) {
        uint256 x;

        assembly {
            /// @notice no semicolon in assembly
            /// @notice `:=` is used for assigning instaed of `=`
            /// @notice assembly can refernce the local variables in assembly blocks
            x := 24         
        }

        return x;
    }
    function getNum2() external pure returns (uint256) {
        assembly {
            let pointer := mload(0x40)
            mstore(pointer, 0x20)
            return(pointer, 0x20)
        }
    }

    function getNum3() external pure returns(bytes memory) {
        bytes memory x;

        assembly {
            /// @notice no semicolon in assembly
            /// @notice `:=` is used for assigning instaed of `=`
            /// @notice assembly can refernce the local variables in assembly blocks
            x := 0x998877  
        }

        return x;
    }
}