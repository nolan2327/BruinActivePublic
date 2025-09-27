var mongoose = require("mongoose")

function getDate() {
    const date = new Date();
    console.log(date); // Log the current date to the console
    return date;
}

const timeInPST = new Date().toLocaleString('en-US', {
    timeZone: 'America/Los_Angeles',
  });

  module.exports = { timeInPST }