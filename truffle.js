module.exports = {
  networks: {
    development: {
      host: "127.0.0.1",
      port: 8545,
      network_id: "*" // Match any network id
    },
    lokkit: {
      host: "master.lokkit.io",
      port: 8545,
      network_id: "*" // Match any network id
    }
  }
};
