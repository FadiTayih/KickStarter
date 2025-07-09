const path = require('path');
const solc = require('solc');
const fs = require('fs-extra');

const buildPath = path.resolve(__dirname,'Build');
fs.removeSync(buildPath);

const campaignPath = path.resolve(__dirname,'Contracts','Campaign.sol');
const source = fs.readFileSync(campaignPath,'utf8');

console.log('Solidity source loaded');
console.log('First few lines of source:');
console.log(source.substring(0, 200));

const output = solc.compile(source,1);

console.log('Compilation output:');
console.log('Messages:', output.errors);
console.log('Contracts found:', Object.keys(output.contracts || {}));

// Only stop if there are actual ERRORS (not warnings)
if (output.errors && output.errors.length > 0) {
    console.log('Compilation messages:');
    output.errors.forEach(error => console.log(error));
    
    // Check if there are actual errors (not just warnings)
    const hasErrors = output.errors.some(error => error.includes('Error:'));
    if (hasErrors) {
        console.log('Fatal errors found, stopping compilation');
        return;
    } else {
        console.log('Only warnings found, continuing...');
    }
}

if (!output.contracts || Object.keys(output.contracts).length === 0) {
    console.log('No contracts compiled successfully');
    return;
}

fs.ensureDirSync(buildPath);
console.log('Build directory created');

for (let contract in output.contracts){
    console.log(`Processing contract: ${contract}`);
    fs.outputJSONSync(
        path.resolve(buildPath, contract.replace(':','') + '.json'),
        output.contracts[contract]
    );
    console.log(`Created: ${contract.replace(':','') + '.json'}`);
}

console.log('Compilation complete!');