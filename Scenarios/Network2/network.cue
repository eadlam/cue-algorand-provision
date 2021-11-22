package algo


let Faucet = "Faucet"

Network: #Network & {

	// Network name
	name: "Network2"

	// The network template expected by: goal network create -t
	template: {
		Genesis: {
			NetworkName: Network.name
			Wallets: [{
				Name:   Faucet
				Stake:  100
				Online: true
			}]
		}
		Nodes: [{
			Name:    "Primary"
			IsRelay: true
			Wallets: []
		}, {
			Name: "Node1"
			Wallets: [{
				Name:              Faucet
				ParticipationOnly: false
			}]
			config: {
				Version: 16,
				GossipFanout: 1,
				IncomingConnectionsLimit: 0,
				DNSBootstrapID: "",
				EnableProfiler: true
				EnableDeveloperAPI: true
			}
		}]
	}
}




