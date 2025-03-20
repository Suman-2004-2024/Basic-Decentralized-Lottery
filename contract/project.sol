// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DecentralizedLottery {

    address public owner;
    address[] public players;
    uint256 public ticketPrice;
    bool public isLotteryActive;

    event TicketPurchased(address indexed player);
    event WinnerSelected(address indexed winner, uint256 prize);

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    modifier lotteryActive() {
        require(isLotteryActive, "Lottery is not active");
        _;
    }

    modifier lotteryNotActive() {
        require(!isLotteryActive, "Lottery is already active");
        _;
    }

    constructor(uint256 _ticketPrice) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        isLotteryActive = false;
    }

    // Start a new lottery
    function startLottery() external onlyOwner lotteryNotActive {
        isLotteryActive = true;
        delete players; // Clear the list of players
    }

    // End the current lottery and pick a winner
    function endLottery() external onlyOwner lotteryActive {
        require(players.length > 0, "No players in the lottery");

        uint256 winnerIndex = random() % players.length;
        address winner = players[winnerIndex];
        uint256 prize = address(this).balance;

        // Transfer the prize to the winner
        payable(winner).transfer(prize);

        emit WinnerSelected(winner, prize);

        // Deactivate the lottery
        isLotteryActive = false;
    }

    // Buy a ticket to participate in the lottery
    function buyTicket() external payable lotteryActive {
        require(msg.value == ticketPrice, "Incorrect ticket price");

        players.push(msg.sender);
        emit TicketPurchased(msg.sender);
    }

    // Get the number of players in the lottery
    function getPlayersCount() external view returns (uint256) {
        return players.length;
    }

    // Generate a random number (pseudo-random)
    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players)));
    }

    // Withdraw funds from the contract (only for the owner)
    function withdraw(uint256 amount) external onlyOwner {
        payable(owner).transfer(amount);
    }

    // Fallback function to accept Ether into the contract
    receive() external payable {}
}

