// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.9;

import {DSTestPlus} from "./utils/DSTestPlus.sol";
import {MockERC20} from "./utils/mocks/MockERC20.sol";
import {MockAuthChild} from "./utils/mocks/MockAuthChild.sol";
import {MockTrustChild} from "./utils/mocks/MockTrustChild.sol";

import {CREATE3} from "../utils/CREATE3.sol";

contract CREATE3Test is DSTestPlus {
    function testDeployERC20() public {
        bytes32 salt = keccak256(bytes("A salt!"));

        MockERC20 deployed = MockERC20(
            CREATE3.deploy(salt, abi.encodePacked(type(MockERC20).creationCode, abi.encode("Mock Token", "MOCK", 18)))
        );

        assertEq(address(deployed), CREATE3.getDeployed(salt));

        assertEq(deployed.name(), "Mock Token");
        assertEq(deployed.symbol(), "MOCK");
        assertEq(deployed.decimals(), 18);
    }

    function testFailDoubleDeploySameBytecode() public {
        bytes32 salt = keccak256(bytes("Salty..."));

        CREATE3.deploy(salt, type(MockAuthChild).creationCode);
        CREATE3.deploy(salt, type(MockAuthChild).creationCode);
    }

    function testFailDoubleDeployDifferentBytecode() public {
        bytes32 salt = keccak256(bytes("and sweet!"));

        CREATE3.deploy(salt, type(MockAuthChild).creationCode);
        CREATE3.deploy(salt, type(MockTrustChild).creationCode);
    }

    function testDeployERC20(
        bytes32 salt,
        string calldata name,
        string calldata symbol,
        uint8 decimals
    ) public {
        MockERC20 deployed = MockERC20(
            CREATE3.deploy(salt, abi.encodePacked(type(MockERC20).creationCode, abi.encode(name, symbol, decimals)))
        );

        assertEq(address(deployed), CREATE3.getDeployed(salt));

        assertEq(deployed.name(), name);
        assertEq(deployed.symbol(), symbol);
        assertEq(deployed.decimals(), decimals);
    }

    function testFailDoubleDeploySameBytecode(bytes32 salt, bytes calldata bytecode) public {
        CREATE3.deploy(salt, bytecode);
        CREATE3.deploy(salt, bytecode);
    }

    function testFailDoubleDeployDifferentBytecode(
        bytes32 salt,
        bytes calldata bytecode1,
        bytes calldata bytecode2
    ) public {
        CREATE3.deploy(salt, bytecode1);
        CREATE3.deploy(salt, bytecode2);
    }
}
