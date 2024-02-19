/**
 * This is a test for now, but it will be used to run post-deployment tasks
 */

// Import the process module from Node.js to access command line arguments
import process from 'process';

// Log the command line arguments
console.log('Command line arguments:', process.argv);
// Parse command line arguments
const args = process.argv.slice(2);

// Define a function to parse arguments into an object
function parseArgs(args) {
    const argObject = {};
    for (let i = 0; i < args.length; i += 2) {
        const key = args[i].replace('--', '');
        const value = args[i + 1];
        argObject[key] = value;
    }
    return argObject;
}

// Use the function to parse arguments
const parsedArgs = parseArgs(args);

// Extract variables from parsed arguments
const url = parsedArgs.url;
const repository = parsedArgs.repository;
const isProduction = parsedArgs['is-production'] === 'true';

console.log('URL:', url);
console.log('Repository:', repository);
console.log('Is Production:', isProduction);
