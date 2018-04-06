const timeTravel = function (time) {
    let funcName;
    if (time >=0) {
      funcName="evm_increaseTime";
    }
    else{
      console.log("decrease time");
      funcName="evm_decreaseTime";
      time=-time;
    }

    return new Promise((resolve, reject) => {
      web3.currentProvider.sendAsync({
        jsonrpc: "2.0",
        method: funcName,
        params: [time], // 86400 is num seconds in day
        id: new Date().getTime()
      }, (err, result) => {
        if(err){ return reject(err) }
        return resolve(result)
      });
    })
}
//timeTravel(3600 * 2 * 24);
timeTravel(-3600 * 2 * 24);
