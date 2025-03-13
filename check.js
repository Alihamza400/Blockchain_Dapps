solc = require("solc");
fs = require("fs");
const {Web3} = require("web3");
const web3 = new Web3("http://127.0.0.1:7545");
let filecontent = fs.readFileSync("demo.sol").toString();
console.log(filecontent);
var input = {
    language : "Solidity",
    sources : {
        "demo.sol" : {
            content: filecontent,
        },
    },
    settings:{
        outputSelection :{
            "*":  {
                "*": ["*"],
            },
        },
    },
}
let output = JSON.parse(solc.compile(JSON.stringify(input)));
let contractnames = Object.keys(output.contracts["demo.sol"]);
let contractname = contractnames[0];

console.log(output);
let bytecode = output.contracts["demo.sol"][contractname].evm.bytecode.object;
let abi = output.contracts["demo.sol"][contractname].abi;
console.log("ABI:",abi);
console.log("bytecode:",bytecode);
contract = new web3.eth.Contract(abi);
let defaultAccount;
web3.eth.getAccounts().then((accounts)=>{
     console.log("Account:",accounts);
     defaultAccount = accounts[0];
     console.log("Default Account:",defaultAccount);
     contract.deploy({
            data: bytecode,
     }).send({from : defaultAccount,gas:5000000}).on('receipt',(receipt)=>{
            console.log("contractAddress:",receipt.contractAddress);
     }).then((demoContract)=>{
           demoContract.methods.number().call((err,data)=>{
                console.log("Number initial value:",data);
           });
     })
});