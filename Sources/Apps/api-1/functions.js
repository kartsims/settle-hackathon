
function getDateUTC() {
    var date = new Date(); 
    var now_utc =  Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate(),date.getUTCHours(), date.getUTCMinutes(), date.getUTCSeconds());
    return new Date(now_utc);
}

module.exports = { getDateUTC };