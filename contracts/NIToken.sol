// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NI {
    string public constant name = "NI";
    string public constant symbol = "NI";
    string public constant version = "1";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    uint256 constant MAX_UINT256 = 2 ** 256 - 1;

    bytes32 public DOMAIN_SEPARATOR;
    bytes32 public PERMIT_TYPEHASH;

    mapping(address => uint256) authorized;
    mapping(address => uint256) balances;
    mapping(address => uint256) nonces;
    mapping(address => mapping(address => uint256)) allowances;

    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed from, address indexed to, uint256 amount);

    constructor(uint256 chainID) {
        authorized[msg.sender] = 1;
        PERMIT_TYPEHASH = keccak256(
            "Permit(address holder,address spender,uint256 nonce,uint256 expiry,bool allowed)"
        );
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes(version)),
                chainID,
                address(this)
            )
        );
    }

    modifier auth() {
        require(authorized[msg.sender] == 1, "UnAuthorized");
        _;
    }

    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) <= x);
    }

    function mint(address user, uint256 amount) public auth returns (bool) {
        if (amount >= 0) {
            balances[user] = amount;
            totalSupply = add(totalSupply, amount);
            emit Transfer(address(0), user, amount);
            return true;
        }
        return false;
    }

    function burn(address user, uint256 amount) external {
        require(balances[user] >= amount, "InsufficientBalance");
        if (user == address(0)) return;
        if (amount <= 0) return;
        if (user != msg.sender && allowances[user][msg.sender] != MAX_UINT256) {
            require(
                allowances[user][msg.sender] >= amount,
                "Insufficient Allowance"
            );
            allowances[user][msg.sender] = sub(
                allowances[user][msg.sender],
                amount
            );
        }
        balances[user] = sub(balances[user], amount);
        totalSupply = sub(totalSupply, amount);
        emit Transfer(user, address(0), amount);
    }

    function transfer(address to, uint256 amount) public auth returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public returns (bool) {
        require(balances[from] >= amount, "Insufficient Balance");
        if (from != msg.sender && allowances[from][msg.sender] != MAX_UINT256) {
            require(
                allowances[from][msg.sender] >= amount,
                "Insufficient Allowance"
            );
            allowances[from][msg.sender] = sub(
                allowances[from][msg.sender],
                amount
            );
        }
        balances[from] = sub(balances[from], amount);
        balances[to] = add(balances[to], amount);
        emit Transfer(from, to, amount);
        return true;
    }

    function approve(address user, uint256 amount) external returns (bool) {
        allowances[msg.sender][user] = amount;
        emit Approval(msg.sender, user, amount);
        return true;
    }

    //Wrappers
    function push(address to, uint256 amount) external {
        transferFrom(msg.sender, to, amount);
    }

    function pull(address from, uint256 amount) external {
        transferFrom(from, msg.sender, amount);
    }

    function move(address src, address dst, uint256 amount) external {
        transferFrom(src, dst, amount);
    }

    function permit(
        address holder,
        address spender,
        uint256 nonce,
        uint256 expiry,
        bool allowed,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        holder,
                        spender,
                        nonce,
                        expiry,
                        allowed
                    )
                )
            )
        );
        require(holder != address(0), "Invalid holder address");
        require(holder == ecrecover(digest, v, r, s), "Invalid Permit");
        require(expiry == 0 || block.timestamp <= expiry, "Permit Expired");
        require(nonce == nonces[holder]++, "Invalid nonce");
        uint256 amount = allowed ? MAX_UINT256 : 0;
        allowances[holder][spender] = amount;
        emit Approval(holder, spender, amount);
    }
}
