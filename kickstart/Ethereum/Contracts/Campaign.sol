pragma solidity 0.4.26;


// Contract that deploys the and manages the Campaigns
contract CampaignFactory {
    address[] public deployedCampaigns; // addresses of all deployed campaigns 

// create a new instance of a Campaign and store the resulting address
    function createCampaign(uint minimum) public {
        address newCampaign = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

// return list of all deployed campaigns 
    function getDeployedCampaigns() public view returns(address[]){
        return deployedCampaigns;
    }


}

// Campaign contract
contract Campaign {

// list of request that the manager has created
    struct Request{
        string description; // describe why the request has been created
        uint value; // Amount of money that the manager wants to send to the vendor
        address recipient; // Address of the vendor 
        bool complete; // True if request has already been processed(money sent)
        uint approvalCount; // track the number of approvals
        mapping(address => bool) approvals; // track who has voted
    }

    Request[] public requests;

    address public manager; // address of the peron who is managing the campaign 
    uint public minimumContribtion; // minimum contribution required to be considered an contributor or approval
    mapping(address => bool) public approvers; // list of addresses for every peron who has donated money
    uint public approverCount;

    modifier restricted(){
        require(msg.sender == manager);
        _;
    }

// constructor function that sets the minimum contribution and owner 
    function Campaign(uint minimum, address creator) public{
        manager = creator;
        minimumContribtion = minimum;
    }

// called when someone wants to donate money to the campaign and become an approver
    function contribute() public payable {
        require(msg.value > minimumContribtion);

        approvers[msg.sender] = true;
        approverCount++;
    }

// called by the manager to create a new spending request
    function createRequest(string description,uint value, address recipient) public  restricted{
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });

        requests.push(newRequest);

    }

// called by each contributor to approve a spending request
    function approveRequest(uint index) public{

        Request storage request = requests[index];

        require(approvers[msg.sender]);
        require(!request.approvals[msg.sender]);

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

// After a request has gotten enough approvals, the manager can call this function 
// to send money to the vendors.
    function finalizeRequest(uint index) public restricted {

        Request storage request = requests[index];
        require(request.approvalCount > (approverCount / 2));

        require(!request.complete);

        request.recipient.transfer(request.value);

        request.complete = true; 

    }
}