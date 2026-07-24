// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

contract AcademicCertificateRegistry {
    struct AcademicCertificate {
        bytes32 certificateId;
        bytes32 documentHash;
        string programName;
        string certificateType;
        uint256 issueDate;
        uint256 revocationDate;
        bool revoked;
        address issuedBy;
        bool exists;
    }

    address public immutable owner;
    mapping(bytes32 => AcademicCertificate) private certificates;

    event CertificateIssued(
        bytes32 indexed certificateId,
        bytes32 indexed documentHash,
        address indexed issuedBy,
        uint256 issueDate
    );

    event CertificateRevoked(
        bytes32 indexed certificateId,
        address indexed revokedBy,
        uint256 revocationDate
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Solo el propietario");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function issueCertificate(
        bytes32 certificateId,
        bytes32 documentHash,
        string calldata programName,
        string calldata certificateType
    ) external onlyOwner {
        require(certificateId != bytes32(0), "Identificador requerido");
        require(documentHash != bytes32(0), "Hash requerido");
        require(!certificates[certificateId].exists, "Certificado duplicado");

        certificates[certificateId] = AcademicCertificate({
            certificateId: certificateId,
            documentHash: documentHash,
            programName: programName,
            certificateType: certificateType,
            issueDate: block.timestamp,
            revocationDate: 0,
            revoked: false,
            issuedBy: msg.sender,
            exists: true
        });

        emit CertificateIssued(
            certificateId,
            documentHash,
            msg.sender,
            block.timestamp
        );
    }

    function getCertificate(
        bytes32 certificateId
    ) external view returns (AcademicCertificate memory) {
        require(certificates[certificateId].exists, "Certificado no encontrado");
        return certificates[certificateId];
    }

    function validateCertificate(
        bytes32 certificateId,
        bytes32 documentHash
    ) external view returns (bool valid, string memory message) {
        AcademicCertificate memory certificate = certificates[certificateId];

        if (!certificate.exists) {
            return (false, "Certificado no encontrado");
        }
        if (certificate.revoked) {
            return (false, "Certificado revocado");
        }
        if (certificate.documentHash != documentHash) {
            return (false, "Hash no coincide");
        }
        return (true, "Certificado valido");
    }

    function revokeCertificate(bytes32 certificateId) external onlyOwner {
        AcademicCertificate storage certificate = certificates[certificateId];
        require(certificate.exists, "Certificado no encontrado");
        require(!certificate.revoked, "Certificado ya revocado");

        certificate.revoked = true;
        certificate.revocationDate = block.timestamp;

        emit CertificateRevoked(
            certificateId,
            msg.sender,
            block.timestamp
        );
    }

    function certificateExists(
        bytes32 certificateId
    ) external view returns (bool) {
        return certificates[certificateId].exists;
    }

    function institution() external pure returns (string memory) {
        return "Instituto Universitario Japon";
    }

    function version() external pure returns (string memory) {
        return "2.0.0";
    }
}
