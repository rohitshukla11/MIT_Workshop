// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CertificateRegistry {
    struct Certificate {
        string recipientName;
        string courseName;
        string issuer;
        uint issueDate;
        bool isValid;
    }

    mapping(bytes32 => Certificate) public certificates;
    mapping(address => bytes32[]) private certificatesByAddress;  // Store certIds by recipient address

    event CertificateIssued(bytes32 indexed certId, string recipientName, string courseName, string issuer);

    function issueCertificate(string memory _recipientName, string memory _courseName, string memory _issuer, address _recipient) public returns (bytes32) {
        bytes32 certId = keccak256(abi.encodePacked(_recipientName, _courseName, _issuer, block.timestamp));
        certificates[certId] = Certificate(_recipientName, _courseName, _issuer, block.timestamp, true);
        
        certificatesByAddress[_recipient].push(certId);  // Store certId for the recipient

        emit CertificateIssued(certId, _recipientName, _courseName, _issuer);
        return certId;
    }

    function verifyCertificate(bytes32 certId) public view returns (bool) {
        return certificates[certId].isValid;
    }

    function getCertificate(bytes32 certId) public view returns (string memory, string memory, string memory, uint, bool) {
        Certificate memory cert = certificates[certId];
        return (cert.recipientName, cert.courseName, cert.issuer, cert.issueDate, cert.isValid);
    }

    function getCertificatesByAddress(address recipient) public view returns (
        bytes32[] memory, 
        string[] memory, 
        string[] memory, 
        string[] memory, 
        uint[] memory, 
        bool[] memory
    ) {
        bytes32[] memory certIds = certificatesByAddress[recipient];
        uint count = certIds.length;

        // Create arrays to store details
        string[] memory recipientNames = new string[](count);
        string[] memory courseNames = new string[](count);
        string[] memory issuers = new string[](count);
        uint[] memory issueDates = new uint[](count);
        bool[] memory isValidList = new bool[](count);

        for (uint i = 0; i < count; i++) {
            Certificate memory cert = certificates[certIds[i]];
            recipientNames[i] = cert.recipientName;
            courseNames[i] = cert.courseName;
            issuers[i] = cert.issuer;
            issueDates[i] = cert.issueDate;
            isValidList[i] = cert.isValid;
        }

        return (certIds, recipientNames, courseNames, issuers, issueDates, isValidList);
    }
}
