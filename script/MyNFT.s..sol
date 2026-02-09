// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {MyNFT} from "../src/MyNFT.sol";

contract CounterScript is Script {
    MyNFT public myNFT;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address DAI = address(0x6B175474E89094C44Da98b954EedeAC495271d0F);
        myNFT = new MyNFT("MyNFT", "MNFT", DAI, msg.sender);

        vm.stopBroadcast();
    }
}
