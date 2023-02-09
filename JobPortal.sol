// SPDX-License-Identifier: MIT

pragma solidity ^0.8.3;

contract JobPortal {
    
    struct Details {
        string name;
        string contact;
        uint64 age;
        uint64 expectation;
        uint64 upvotes;
        uint64 downvotes;
        string history;
        string skills;
        string jobType;
        bool availability;
    }

    struct Job{
        string jobType;
        uint8 offer;
        string description;
        string skills;
        uint128[] applicants;
        mapping(address => bool) applied; 
    }

    mapping(uint => Details) applicants;
    mapping(uint => Job) jobs;
    mapping(address => uint128) applicantID;
    mapping(address => uint128[]) jobID;
    uint128 applicantIDCounter;
    uint128 jobIDCounter;


    function register(string calldata name_,string calldata contact_, uint64 age_, uint64 expectation_, string calldata history_, string calldata skills_, string calldata jobType_) external {
        require(applicantID[msg.sender] == 0, 'already registered');
        Details memory details = Details(name_,contact_,age_,expectation_,0,0,history_,skills_,jobType_,true);
        applicants[applicantIDCounter] = details;
        applicantID[msg.sender] = applicantIDCounter;
        applicantIDCounter++;
    }

    function addJob(string calldata jobType_, uint8 offer_, string calldata description_, string calldata skills_) external {
        Job storage job = jobs[jobIDCounter];
        job.jobType = jobType_;
        job.offer = offer_;
        job.description = description_;
        job.skills = skills_;

        jobID[msg.sender].push(jobIDCounter);
        jobIDCounter++;
    }

    function applyForJob(uint128 jobID_) external {
        require(applicantID[msg.sender] != 0, 'not registered');
        require(!jobs[jobID_].applied[msg.sender], 'already applied');
        jobs[jobID_].applicants.push(applicantID[msg.sender]);
        jobs[jobID_].applied[msg.sender] = true;
    }

    function giveRating(uint128 applicantID_, bool rating_) external {
        require(jobID[msg.sender].length != 0, 'need to be a job poster');
        require(bytes(applicants[applicantID_].name).length != 0, 'invalid applicant ID');
        rating_? applicants[applicantID_].upvotes++ : applicants[applicantID_].downvotes++;
    }

    function deleteApplicant() external {
        delete applicants[applicantID[msg.sender]];
    }

    function updateAvailability(bool status_) external{
        applicants[applicantID[msg.sender]].availability = status_;
    }

    function delistJob(uint128 jobID_) external {
        uint length = jobID[msg.sender].length;
        for(uint i;i<length;++i){
            if(jobID[msg.sender][i] == jobID_){
                jobID[msg.sender][i] = jobID[msg.sender][length-1];
                jobID[msg.sender].pop();
                break;
            }
        }
        delete jobs[jobID_];
    }

    function applicantDetails(uint128 applicantID_) external view returns(Details memory){
        return applicants[applicantID_];
    }

    function applicantType(uint128 applicantID_) external view returns(string memory){
        return applicants[applicantID_].jobType;
    }

    function jobDetails(uint128 jobID_) external view returns(string memory,uint8,string memory,string memory,uint128[] memory){
        return(jobs[jobID_].jobType,jobs[jobID_].offer,jobs[jobID_].description,jobs[jobID_].skills,jobs[jobID_].applicants);
    }

    function applicantRatings(uint128 applicantID_) external view returns (uint64,uint64){
        return(applicants[applicantID_].upvotes,applicants[applicantID_].downvotes);
    }

}
