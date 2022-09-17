// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title MerkleVerifier
 */
library MerkleVerifier {
    function calculateRoot(
        bytes32[] calldata _path,
        uint256 _index,
        bytes32 _itemHash
    ) internal pure returns (bytes32) {
        uint256 pathLength = _path.length;
        require(pathLength > 0 && pathLength < 256);
        require(_index < 2**pathLength);

        bytes32 currentHash = _itemHash;
        for (uint256 i = 0; i < pathLength; ) {
            if (_index % 2 == 0) {
                currentHash = keccak256(
                    abi.encodePacked(currentHash, _path[i])
                );
            } else {
                currentHash = keccak256(
                    abi.encodePacked(_path[i], currentHash)
                );
            }
            _index /= 2;

            unchecked {
                ++i;
            }
        }

        return currentHash;
    }
}
