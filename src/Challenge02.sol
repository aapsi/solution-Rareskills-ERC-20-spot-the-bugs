// SPDX-License-Identifier: CC-BY-NC-SA-4.0
pragma solidity >=0.8.0;

/// ██████╗ ██╗  ██╗ █████╗ ██╗     ██╗     ███████╗███╗   ██╗ ██████╗ ███████╗
/// ██╔════╝██║  ██║██╔══██╗██║     ██║     ██╔════╝████╗  ██║██╔════╝ ██╔════╝
/// ██║     ███████║███████║██║     ██║     █████╗  ██╔██╗ ██║██║  ███╗█████╗
/// ██║     ██╔══██║██╔══██║██║     ██║     ██╔══╝  ██║╚██╗██║██║   ██║██╔══╝
/// ╚██████╗██║  ██║██║  ██║███████╗███████╗███████╗██║ ╚████║╚██████╔╝███████╗
/// ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝
///
///  ██████╗ ██████╗
/// ██╔═████╗╚════██╗
/// ██║██╔██║ █████╔╝
/// ████╔╝██║██╔═══╝
/// ╚██████╔╝███████╗
/// ╚═════╝ ╚══════╝

/// @notice Modern and gas efficient ERC20
contract Challenge02 {
    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    error InvalidReceiver(address receiver);
    error InvalidSender(address sender);
    error InvalidSpender(address spender);
    error InsufficientBalance(address sender, uint256 balance, uint256 amount);
    error InsufficientAllowance(
        address spender,
        uint256 allowance,
        uint256 amount
    );
    error InvalidApprover(address approver);

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    // function approve(address owner, address spender, uint256 amount) public {
    //     allowance[owner][spender] = amount;
    //     emit Approval(owner, spender, amount);
    // }

    function approve(
        address spender,
        uint256 amount
    ) public virtual returns (bool) {
        address owner = msg.sender;
        if (owner == address(0)) revert InvalidApprover(address(0));
        if (spender == address(0)) revert InvalidSpender(address(0));
        allowance[owner][spender] = amount;
        emit Approval(owner, spender, amount);
        return true;
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address from = msg.sender;
        if (to == address(0)) revert InvalidReceiver(address(0));
        uint256 senderBal = balanceOf[from];
        if (senderBal < amount)
            revert InsufficientBalance(from, senderBal, amount);
        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        if (from == address(0)) revert InvalidSender(address(0));
        if (to == address(0)) revert InvalidReceiver(address(0));
        uint256 allowed = allowance[from][msg.sender];

        if (allowed != type(uint256).max) {
            if (allowed < amount)
                revert InsufficientAllowance(
                    address(msg.sender),
                    allowance[from][msg.sender],
                    amount
                );
            allowance[from][msg.sender] = allowed - amount;
        }

        uint256 fromBal = balanceOf[from];
        if (fromBal < amount) revert InsufficientBalance(from, fromBal, amount);
        balanceOf[from] -= amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    function _mint(address to, uint256 amount) internal virtual {
        if (to == address(0)) revert InvalidReceiver(address(0));
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        if (balanceOf[from] < amount)
            revert InsufficientBalance(from, balanceOf[from], amount);
        balanceOf[from] -= amount;

        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }

    function mint(address to, uint256 amount) public virtual returns (bool) {
        _mint(to, amount);
        return true;
    }

    function burn(uint256 amount) public virtual returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }
}
