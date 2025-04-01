// SPDX-License-Identifier: CC-BY-NC-SA-4.0

/// ██████╗ ██╗  ██╗ █████╗ ██╗     ██╗     ███████╗███╗   ██╗ ██████╗ ███████╗
/// ██╔════╝██║  ██║██╔══██╗██║     ██║     ██╔════╝████╗  ██║██╔════╝ ██╔════╝
/// ██║     ███████║███████║██║     ██║     █████╗  ██╔██╗ ██║██║  ███╗█████╗
/// ██║     ██╔══██║██╔══██║██║     ██║     ██╔══╝  ██║╚██╗██║██║   ██║██╔══╝
/// ╚██████╗██║  ██║██║  ██║███████╗███████╗███████╗██║ ╚████║╚██████╔╝███████╗
/// ╚═════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═══╝ ╚═════╝ ╚══════╝

///  ██╗██████╗
/// ███║╚════██╗
/// ╚██║ █████╔╝
///  ██║██╔═══╝
///  ██║███████╗
///  ╚═╝╚══════╝

pragma solidity >=0.8.0;

/// @notice Modern and gas efficient ERC20
contract Challenge12 {
    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Challenge12: caller is not owner");
        _;
    }

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        owner = msg.sender;
    }

    function approve(
        address spender,
        uint256 amount
    ) public virtual returns (bool) {
        require(spender != address(0), "ERC20: approve to the zero address");
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount <= balanceOf[msg.sender], "ERC20: insufficient balance");

        unchecked {
            balanceOf[msg.sender] -= amount;
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(
            amount <= balanceOf[from],
            "ERC20: transfer amount exceeds balance"
        );

        uint256 allowed = allowance[from][msg.sender];

        if (allowed != type(uint256).max)
            require(allowed >= amount, "ERC20: insufficient allowance");

        unchecked {
            allowance[from][msg.sender] = allowed - amount;
        }

        unchecked {
            balanceOf[from] -= amount;
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    function gift(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function _mint(address to, uint256 amount) internal virtual {
        require(to != address(0), "ERC20: mint to the zero address");

        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        require(from != address(0), "ERC20: burn from the zero address");
        require(
            amount <= balanceOf[from],
            "ERC20: burn amount exceeds balance"
        );

        unchecked {
            totalSupply -= amount;
            balanceOf[from] -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}
