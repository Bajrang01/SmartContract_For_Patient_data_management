// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HealthRecords {
    address public owner;
    address[] public allDoctors; // Maintain a list of all doctors.

    struct Doctor {
        bool isDoctor;
        address[] patients;
    }

    struct Patient {
        bool isPatient;
        address[] doctors;
        string name;
        string medicalRecord;
    }

    mapping(address => Doctor) public doctors;
    mapping(address => Patient) public patients;
    mapping(address => mapping(address => bool)) public doctorToPatients;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only the contract owner can perform this operation"
        );
        _;
    }

    modifier onlyPatient() {
        require(
            patients[msg.sender].isPatient,
            "Only patients can perform this operation"
        );
        _;
    }

    modifier onlyDoctor() {
        require(
            doctors[msg.sender].isDoctor,
            "Only doctors can perform this operation"
        );
        _;
    }

    function addPatient(
        address _patientAddress,
        string memory _name,
        string memory _medicalRecord
    ) external {
        require(!patients[_patientAddress].isPatient, "Patient already exists");
        patients[_patientAddress] = Patient(
            true,
            new address[](0),
            _name,
            _medicalRecord
        );
    }

    function addDoctor(address _doctorAddress) external onlyOwner {
        require(!doctors[_doctorAddress].isDoctor, "Doctor already exists");
        doctors[_doctorAddress] = Doctor(true, new address[](0));
        allDoctors.push(_doctorAddress); // Add the doctor to the list of all doctors.
    }

    function getAllDoctors() external view returns (address[] memory) {
        return allDoctors;
    }

    function giveAccessToDoctor(address _doctorAddress) external onlyPatient {
        require(doctors[_doctorAddress].isDoctor, "Doctor does not exist");
        require(
            !doctorToPatients[_doctorAddress][msg.sender],
            "Access already granted"
        );

        doctors[_doctorAddress].patients.push(msg.sender);
        doctorToPatients[_doctorAddress][msg.sender] = true;
    }

    function accessPatientData(
        address _patientAddress
    ) external view onlyDoctor returns (bool, string memory, string memory) {
        require(
            doctorToPatients[msg.sender][_patientAddress],
            "No access to patient data"
        );
        Patient storage patient = patients[_patientAddress];
        return (patient.isPatient, patient.name, patient.medicalRecord);
    }
}
