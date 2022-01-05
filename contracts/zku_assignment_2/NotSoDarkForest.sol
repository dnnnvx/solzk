// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0 <0.9.0;

interface IVerifier {
    function verifyProof(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[1] memory input) external view returns (bool r);
}

contract NotSoDarkForest {

    // a struct of the player, for now it contains only the hash of the coordinates
    // could be also have something like username and other informations
    struct Player {
        uint256 coordinates;
    }

    // a spot (x,y) can be available if there's no one, and it also
    // stores if no one has been there in the latest 5 mins
    struct Spot {
        bool available;
        uint256 latestVisit;
    }

    // owner
    address public god;
    
    // address of the verifier contract (created by circom/snarkjs)
    address public verifier;

    // our list of players
    mapping(address => Player) players;
    
    // our list of spots/coordinates as hash=>spot
    mapping(uint256 => Spot) spots;

    event Log(uint amount);

    constructor(address _verifier) {
        // set onwe
        god = payable(msg.sender);
        // set the address contract of the verifier
        verifier = _verifier;
    }

    // buy me a coffee
    receive() external payable {
        emit Log(msg.value);
    }

    // god is a coffee addict
    function withdraw(uint _amount) external {
        require(msg.sender == god, "caller is not god");
        payable(msg.sender).transfer(_amount);
    }

    // see how rich is god
    function getBalance() external view returns (uint) {
        return address(this).balance;
    }

    // ----------------------------------------------------------------------------------- //
    // ---------------------- serious part of the smart contract ------------------------- //
    // ----------------------------------------------------------------------------------- //

    function getPlayer(address _address) public view returns (Player memory) {
        return players[_address];
    }

    // check if the player has already "signed up" to our awesome game
    function playerExists(address _address) public view returns(bool) {
        return abi.encodePacked(players[_address].coordinates).length > 0;
    }

    // given the has of the coordinates, we can find a spot or discover (create) a new one
    function findSpot(uint256 _coordinates) public returns(Spot memory) {
        // check if it exists
        bool isDiscovered = abi.encodePacked(spots[_coordinates].available).length > 0;
        // if not, create a new (available, for now) spot
        if (isDiscovered == false) {
            Spot memory newSpot = Spot({
                available: true,
                latestVisit: 0
            });
            spots[_coordinates] = newSpot;
            return newSpot;
        } else {
            return spots[_coordinates];
        }
    }

    // finally the main part of the assignment
    // if the verifier can't verify our proof or the spot is occupied or it has been occupied since max 5 mins ago,
    // the function call is reverted thanks to the "require" functionality in Solidity
    function spawn(uint[2] memory a, uint[2][2] memory b, uint[2] memory c, uint[1] memory input) public {
        // call our verifier function and check if we can verify our coordinates with ZKP
        bool verified = IVerifier(verifier).verifyProof(a, b, c, input);
        require(verified == true, "Coordinates do not match the spawn rules");
        // as a timestamp we use the block timestamp, even if it's not that precise ...
        // but still better than an input from the client/frontend
        uint256 timestamp = block.timestamp;
        // check if the player exists, if not, create a new one with the msg.sender address
        // in this case it will be its first spawn into the game!
        bool exists = playerExists(msg.sender);
        if (exists == false) {
            players[msg.sender] = Player({
                coordinates: input[0]
            });
        }
        // find/discover the spot
        Spot memory spot = findSpot(input[0]);
        // and check if we can spawn in there by checking the availability stats and the timestamp diff
        bool canOccupy = spot.available && spot.latestVisit < (timestamp - 300);
        require(canOccupy == true, "Spot already occupied or it has been occupied in the prev < 5mins");
        // spawn!!
        spots[input[0]] = Spot({
            available: false,
            latestVisit: timestamp
        });
    }

    // this function is incomplete, we need to provide and proof
    // the new coordinates, but it's here just for some testing
    function leaveSpot() public {
        Player memory player = players[msg.sender];
        Spot storage spot = spots[player.coordinates];
        spot.available = true;
        spot.latestVisit = block.timestamp;
    }
}
