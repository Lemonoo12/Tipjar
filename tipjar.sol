// SPDX-License-Identifier: MIT
pragma solidity 0.8.31;

contract tips {
    address owner;

    constructor() {
        owner = msg.sender;
    }

    // 1. Put fund in smart contract
    function addtips() public payable {}

    // 2. View balance
    function viewtips() public view returns (uint) {
        return address(this).balance;
    }

    // 3.1 Structure for a Waitress
    struct Waitress {
        address payable walletAddress;
        string name;
        uint percent;
    }

    Waitress[] waitress; // List of all waitresses

    // 5. View waitress
    function viewWaitress() public view returns (Waitress[] memory) {
        return waitress;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    function addWaitress(
        address payable walletAddress,
        string memory name,
        uint percent
    ) public onlyOwner {
        // 🟢 1. ดักไม่ให้ใส่เปอร์เซ็นต์รายบุคคลเกิน 100
        require(percent <= 100, "Percent can't be greater than 100");

        // 🟢 2. ดักไม่ให้ผลรวมเปอร์เซ็นต์ของทุกคนในร้านเกิน 100
        uint totalPercent = 0;
        for (uint i = 0; i < waitress.length; i++) {
            totalPercent += waitress[i].percent;
        }
        require(totalPercent + percent <= 100, "Total percent exceeds 100");

        bool waitressExist = false;

        if (waitress.length >= 1) {
            for (uint i = 0; i < waitress.length; i++) {
                if (waitress[i].walletAddress == walletAddress) {
                    waitressExist = true;
                }
            }
        } // Check Logic

        if (waitressExist == false) {
            waitress.push(Waitress(walletAddress, name, percent));
        }
    }

    function removeWaitress(address walletAddress) public onlyOwner {
        // (เอา require ที่หลงมาตรงนี้ออกไป เพื่อไม่ให้โค้ด Error)
        if (waitress.length >= 1) {
            for (uint i = 0; i < waitress.length; i++) {
                if (waitress[i].walletAddress == walletAddress) {
                    // Shift elements left
                    for (uint j = i; j < waitress.length - 1; j++) {
                        waitress[j] = waitress[j + 1];
                    }
                    waitress.pop();
                    break;
                }
            }
        }
    }

    function distributeBalance() public {
        require(address(this).balance > 0, "No Money");
        if (waitress.length >= 1) {
            uint totalamount = address(this).balance;
            for (uint j = 0; j < waitress.length; j++) {
                // Calculate share
                uint distributeAmount = (totalamount * waitress[j].percent) /
                    100;
                // Send money
                _transferFunds(waitress[j].walletAddress, distributeAmount);
            }
        }
    }

    function _transferFunds(address payable recipient, uint amount) internal {
        (bool success, ) = payable(recipient).call{value: amount}("");
        require(success, "Transfer failed.");
    }
}