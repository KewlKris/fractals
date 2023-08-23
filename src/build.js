const fs = require('fs');

const mainDir = './';
const distDir = './src/site/dist';
const ignoredTypes = ['code-workspace', 'json', 'md'];

if (process.argv.indexOf('--clean-main') != -1) {
    console.log('Cleaning main...');
    let files = fs.readdirSync(mainDir, {withFileTypes: true});
    for (let file of files) {
        if (file.isFile()) {
            let extension = file.name.substring(file.name.lastIndexOf('.') + 1).toLowerCase();
            if (ignoredTypes.indexOf(extension) == -1) {
                // Remove this file!
                fs.rmSync(file.path + '/' + file.name);
            }
        }
    }
}

if (process.argv.indexOf('--clean-dist') != -1) {
    console.log('Cleaning dist...');
    let files = fs.readdirSync(distDir, {withFileTypes: true});
    for (let file of files) {
        if (file.isFile()) {
            // Remove all files
            fs.rmSync(file.path + '/' + file.name);
        }
    }
}

if (process.argv.indexOf('--build') != -1) {
    console.log('Copying files from dist...');
    let files = fs.readdirSync(distDir, {withFileTypes: true});
    for (let file of files) {
        if (file.isFile()) {
            // Copy all files to main
            fs.copyFileSync(file.path + '/' + file.name, mainDir + '/' + file.name);
        }
    }
}