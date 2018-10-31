/** 
 * 
 * MIT License
 * 
 * Copyright (c) 2018 Finolog
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 * 
 */


pragma solidity ^0.4.25;

contract ProofOfAccount {

    struct Oracle {
        address inviter;

        string name;
        string url;
        uint fee;
        uint confirmed;
    }
    
    struct Request {
        uint requestedAt;
        uint confirmedAt;
        uint pendingFee;
    }
    

    modifier onlyOracle {
        require(oracles[msg.sender].inviter > 0);
        _;
    }
    
    
    // https://www.ethereum.org/donate
    address EthereumFoundation = 0xfB6916095ca1df60bB79Ce92cE3Ea74c37c5d359;
    uint ethereumFoundationContribution = 0;
    uint currentEthereumFoundationContribution = 0;
    
    mapping(address => Oracle) oracles;
    mapping(address => mapping(address => mapping(string => Request))) requests;
    address[] availableOracleAddresses;


    constructor(string _name, string _url, uint _fee) public {
        oracles[msg.sender].inviter = msg.sender;
        oracles[msg.sender].name = _name;
        oracles[msg.sender].url = _url;
        oracles[msg.sender].fee = _fee;
        
        availableOracleAddresses.push(msg.sender);
    }
    
    
    function invite(address _oracle, string _name, string _url, uint _fee) public onlyOracle {
        bytes memory __name = bytes(_name);
        bytes memory __url = bytes(_url);
        
        require(__name.length > 0);
        require(__url.length > 0);
        require(_fee >= 0);

        oracles[_oracle].inviter = msg.sender;
        oracles[_oracle].name = _name;
        oracles[_oracle].url = _url;
        oracles[_oracle].fee = _fee;

        availableOracleAddresses.push(_oracle);
    }
    

    function getAvailableOracleAddressesCount() public constant returns (uint256) {
        return availableOracleAddresses.length;
    }


    function getAvailableOracleAddress(uint _index) public constant returns (address) {
        require(_index >= 0);
        require(availableOracleAddresses.length < _index);
        
        return availableOracleAddresses[_index];    
    }
    
    
    function getOracleName(address _oracle) public constant returns (string) {
        require(oracles[_oracle].inviter > 0);
        
        return oracles[_oracle].name;
    }
    
    
    function getOracleUrl(address _oracle) public constant returns (string) {
        require(oracles[_oracle].inviter > 0);
        
        return oracles[_oracle].url;
    }
    
    
    function getOracleFee(address _oracle) public constant returns (uint256) {
        require(oracles[_oracle].inviter > 0);
        
        return oracles[_oracle].fee;
    }
    
    
    function setOracleName(string _name) public onlyOracle {
        bytes memory __name = bytes(_name);

        require(__name.length > 0);

        oracles[msg.sender].name = _name;
    }
    
    
    function setOracleUrl(string _url) public onlyOracle {
        bytes memory __url = bytes(_url);

        require(__url.length > 0);

        oracles[msg.sender].url = _url;
    }
    
    
    function setOracleFee(uint _fee) public onlyOracle {
        require(_fee >= 0);
        
        oracles[msg.sender].fee = _fee;
    }
    
    
    function getEthereumFoundationContribution() public constant returns (uint) {
        return ethereumFoundationContribution;
    }
    
    
    function getCurrentEthereumFoundationContribution() public constant returns (uint) {
        return currentEthereumFoundationContribution;
    }


    function request(string _account, address _oracle) public payable {
        require(oracles[_oracle].inviter > 0);
        require(msg.value >= oracles[_oracle].fee);
        
        requests[_oracle][msg.sender][_account] = Request(now, 0, msg.value);
    }
    
    
    function requested(string _account, address _oracle) public constant returns (bool) {
        require(oracles[_oracle].inviter > 0);
        
        return requests[_oracle][msg.sender][_account].requestedAt > 0;
    }


    function confirm(string _account, address _address) public onlyOracle {
        require(requests[msg.sender][_address][_account].requestedAt > 0);
        require(requests[msg.sender][_address][_account].confirmedAt == 0);

        uint totalAmount = requests[msg.sender][_address][_account].pendingFee;

        requests[msg.sender][_address][_account].pendingFee = 0;
        requests[msg.sender][_address][_account].confirmedAt = now;

        uint ethereumFoundationAmount = totalAmount / 10;
        uint oracleAmount = totalAmount - ethereumFoundationAmount;
        
        msg.sender.transfer(oracleAmount);

        ethereumFoundationContribution = ethereumFoundationContribution + ethereumFoundationAmount;
        currentEthereumFoundationContribution = currentEthereumFoundationContribution + ethereumFoundationAmount;

        oracles[msg.sender].confirmed++;
    }
    
    
    function confirmed(string _account, address _address, address _oracle) public constant returns (bool) {
        if (requests[_oracle][_address][_account].requestedAt > 0 && requests[_oracle][_address][_account].confirmedAt > 0) {
            return true;
        } else {
            return false;
        }
    }


    function withdraw(string _account, address _oracle) public {
        require(oracles[_oracle].inviter > 0);
        require(requests[_oracle][msg.sender][_account].pendingFee > 0);
        
        uint amount = requests[_oracle][msg.sender][_account].pendingFee;

        requests[_oracle][msg.sender][_account].pendingFee = 0;
        requests[_oracle][msg.sender][_account].requestedAt = 0;
        requests[_oracle][msg.sender][_account].confirmedAt = 0;
        
        msg.sender.transfer(amount);
    }
    
    
    function donate() public onlyOracle {
        uint value = currentEthereumFoundationContribution;
        currentEthereumFoundationContribution = 0;
        EthereumFoundation.transfer(value);
    }

}
