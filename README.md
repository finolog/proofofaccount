# Smart contract to prove the existence of account

## How it works

This is a reliable part of KYC. A member of the network sends a request from his wallet to a certain Oracle to confirm his involvement in a particular address. Along with the request he pays the possible fee of the Oracle. Then asks Oracle to confirm that he is the owner of the abandoned account. Oracle has received a request to confirm it or not. In the case of confirmation, the Oracle receives a fee. Oracle can be a reliable data operator (bank, service, payment system, exchange, government agency, etc.). 

The same account can be confirmed by different oracles with different levels of trust. The Oracle indicates a trusted resource address on the network where you can check the confirmation. 

The Creator of the contract becomes the first Oracle and can invite other oracles. Oracle can change its details (except address) and fee.

## Contract address

`0xd9dade06a37bbfc765a194d0d1a081e3f1980812`

## User usage

- `request(string account, address oracle)` request a confirmation `account` => `address` via `oracle`
- `confirmed(string account, address address, address oracle)` check a confirmation
- `withdraw(string account, address oracle)` withdraw fee from unconfirmed request `account` via `oracle`

- `getOracleName(address oracle)` return `oracle` name
- `getOracleUrl(address oracle)` return `oracle` url
- `getOracleFee(address oracle)` return `oracle` fee


## Oracle usage

- `requested(string account, address address)` check request for a confirmation `account` => `address`
- `confirm(string account, address address)` confirm an `account`
- `invite(address oracle, string name, string url, uint fee)` invite a new oracle

- `setOracleName(string name)`
- `setOracleUrl(string url)`
- `setOracleFee(uint fee)`
