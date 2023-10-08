// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;

contract StorageSlot {

    // Storage variables are not directly accessible inside assembly block

    /// @notice to deal with storage in assembly, we have 2 opcodes
    // 1. sload(slot) - given a slot, it returns value at that slot
    // 2. sstore(slot, value) - it stores a value at given slot
    uint public a;
    uint public b;
    uint public c;
    // These both variables will have same slot
    uint128 public d;
    uint128 public e;

    function getslot() external pure returns(uint x) {
        assembly {
            x := b.slot
        }
    }

    function getVal(uint slot) external view returns(uint val) {
        assembly {
            // val := a            // ---> This will revert
            // val := sload(a)     // ---> This will revert
            // val := sload(a.slot)    // ---> This won't
            val := sload(slot)
        }
    }

    function storeValue(uint slot, uint val) external {
        assembly {
            sstore(slot, val)
        }
    }


}



// @note
// Right Shifting by x bits is equivalent to division by ( 2 ** x )
// Left Shifting by x bits is equivalent to multiply with ( 2 ** x )
contract BitShifting {
    uint128 public a = 9;
    uint96 public b = 3;
    uint16 public c = 24;
    uint8 public d = 7;

    // There are 2 ways of doing this. See the `getC` and `getD` methods
    function getC() external view returns(uint256) {
        bytes32 cVal;
        bytes32 temp;
        assembly {
            let value := sload(c.slot)
            // 1. Prepare the masking by leftshifting (uint16.max) to the c.offset
            let max := 0xffff
            temp := shl(mul(c.offset, 8), max)
            // 2. Mask `value` withe `temp`
            cVal := and(value, temp)
            // 3. Right shift the fetched value
            cVal := shr(mul(c.offset, 8), cVal)

            let pointer := mload(0x40)
            mstore(pointer, cVal)
            return(pointer, 0x20)
        }
    }

    function getD() external view returns(uint256) {
        assembly {

            let value := sload(d.slot)
            // 1. Right shift the value by the `d.offset * 8` bits. This will result in value being at last
            let dVal := shr(mul(d.offset, 8), value)
            // 2. Mask it and And it
            dVal := and(dVal, 0xff)

            let pointer := mload(0x40)
            mstore(pointer, dVal)
            return(pointer, 0x20)

        }
    }

    function writeB(uint val) external returns (bytes32){
        bytes32 bVal;
        assembly {
            // 1. Clear the B's sapce in slot --> For that we need to AND the slots value with o's starting at B's offset till B's last bit
            // 1.1. Take the max of type of B
            // 1.2. Left shift them to the B's space
            // 1.3. Negate it
            // 1.4. And with slot's value
            let value := sload(b.slot)
            let temp := not(shl(mul(b.offset, 8), 0xffffffffffffffffffffffff))

             bVal := and(value, temp)

            // 2. Left shift the val to B's offset
            val := shl(mul(b.offset, 8), val)

            // 3. OR val with Original value
            sstore(b.slot, or(bVal, val))
        }
         return bytes32(val);
    }
    function getOffset() external view returns(uint) {
        assembly {
            let offset := c.offset
            let pointer := mload(0x40)
            mstore(pointer, offset)
            return(pointer, 0x20)
        }
    }
}








// Code from the course
contract StoragePart1 {
    uint128 public C = 4;
    uint96 public D = 6;
    uint16 public E = 8;
    uint8 public F = 1;

    function readBySlot(uint256 slot) external view returns (bytes32 value) {
        assembly {
            value := sload(slot)
        }
    }

    // NEVER DO THIS IN PRODUCTION
    function writeBySlot(uint256 slot, uint256 value) external {
        assembly {
            sstore(slot, value)
        }
    }

    // masks can be hardcoded because variable storage slot and offsets are fixed
    // V and 00 = 00
    // V and FF = V
    // V or  00 = V
    // function arguments are always 32 bytes long under the hood
    function writeToE(uint16 newE) external {
        assembly {
            // newE = 0x000000000000000000000000000000000000000000000000000000000000000a
            let c := sload(E.slot) // slot 0
            // c = 0x0000010800000000000000000000000600000000000000000000000000000004
            let clearedE := and(
                c,
                0xffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            )
            // mask     = 0xffff0000ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
            // c        = 0x0001000800000000000000000000000600000000000000000000000000000004
            // clearedE = 0x0001000000000000000000000000000600000000000000000000000000000004
            let shiftedNewE := shl(mul(E.offset, 8), newE)
            // shiftedNewE = 0x0000000a00000000000000000000000000000000000000000000000000000000
            let newVal := or(shiftedNewE, clearedE)
            // shiftedNewE = 0x0000000a00000000000000000000000000000000000000000000000000000000
            // clearedE    = 0x0001000000000000000000000000000600000000000000000000000000000004
            // newVal      = 0x0001000a00000000000000000000000600000000000000000000000000000004
            sstore(C.slot, newVal)
        }
    }

    function getOffsetE() external pure returns (uint256 slot, uint256 offset) {
        assembly {
            slot := E.slot
            offset := E.offset
        }
    }

    function readE() external view returns (uint256 e) {
        assembly {
            let value := sload(E.slot) // must load in 32 byte increments
            //
            // E.offset = 28
            let shifted := shr(mul(E.offset, 8), value)
            // 0x0000000000000000000000000000000000000000000000000000000000010008
            // equivalent to
            // 0x000000000000000000000000000000000000000000000000000000000000ffff
            e := and(0xffff, shifted)
        }
    }

    function readEalt() external view returns (uint256 e) {
        assembly {
            let slot := sload(E.slot)
            let offset := sload(E.offset)
            let value := sload(E.slot) // must load in 32 byte increments

            // shift right by 224 = divide by (2 ** 224). below is 2 ** 224 in hex
            let shifted := div(
                value,
                0x100000000000000000000000000000000000000000000000000000000
            )
            e := and(0xffffffff, shifted)
        }
    }
}