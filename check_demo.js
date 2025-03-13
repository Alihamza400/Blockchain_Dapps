// Interecting with Ganache  Blockchain  using web3.js
let {Web3} = require("web3");
let web3 = new Web3("HTTP://127.0.0.1:7545");
let Allaccounts = web3.eth.getAccounts().then((accounts)=>{
    console.log("Accounts:",accounts);
})
let getBalance = web3.eth.getBalance("0x4711e0914E508Fe3f793B8aCc2E11B987B76c0C4").then((balance)=>{
     console.log("Balance:",web3.utils.fromWei(balance,"ether"));
});
let sendTransaction = web3.eth.sendTransaction({from:"0x4711e0914E508Fe3f793B8aCc2E11B987B76c0C4",
    to:"0x58ba2A59F51Be4d26365b3dED0CAeF455Fa7F038",value:web3.utils.toWei("8","ether")}).then((receipt)=>{
        console.log("Transaction Receipt",receipt);
    })
// Interacting with smart contract on Ganache Blockchain using web3.js
let contract = new web3.eth.Contract([
	{
		"inputs": [],
		"name": "number",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [],
		"name": "show",
		"outputs": [
			{
				"internalType": "uint256",
				"name": "",
				"type": "uint256"
			}
		],
		"stateMutability": "view",
		"type": "function"
	},
	{
		"inputs": [
			{
				"internalType": "uint256",
				"name": "num",
				"type": "uint256"
			}
		],
		"name": "store",
		"outputs": [],
		"stateMutability": "nonpayable",
		"type": "function"
	}
],"0x58ba2A59F51Be4d26365b3dED0CAeF455Fa7F038");
contract.methods.number().call().then((result)=>{
    console.log("Number:",result);
});
contract.methods.store(50).send({from:"0x39B401124C3fa8100B9987C72c676526b59ec0B8",gas:5000000}).then((receipt)=>{
    console.log("Receipt:",receipt);
});
contract.methods.number().call().then((result)=>{
    console.log("Number:",result);
});

