function generateRandomNumber() {
    return Math.floor(Math.random() * 250) + 1;
}

function computeFactorial(n) {
    if (n === 0 || n === 1) {
        return 1;
    }

    let result = 1;
    
    for (let i = 2; i <= n; i++) {
        result *= i;
    }

    return result;
}


function generatePlaceName() {
    return "Updated backend function with refactored code #2";
}

export { generatePlaceName, generateRandomNumber, computeFactorial };