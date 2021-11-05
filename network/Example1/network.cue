package algo

let Wallet1 = "Wallet1"
let Wallet2 = "Wallet2"
let Wallet3 = "Wallet3"

Network: {

	#Network //Specification

	// Network name
	name: "Example1"

	// Local directory to store the network to
	directory: "bin/networks/\(Network.name)"

	// The network template expected by: goal network create -t
	template: {
		Genesis: {
			NetworkName: Network.name
			Wallets: [{
				Name:   Wallet1
				Stake:  50
				Online: true
			}, {
				Name:   Wallet2
				Stake:  40
				Online: true
			}, {
				Name:   Wallet3
				Stake:  10
				Online: false
			}]
		}
		Nodes: [{
			Name:    "Primary"
			IsRelay: true
			Wallets: [{
				Name:              Wallet1
				ParticipationOnly: false
			}]
		}, {
			Name: "Node"
			Wallets: [{
				Name:              Wallet2
				ParticipationOnly: false
			}, {
				Name:              Wallet3
				ParticipationOnly: false
			}]
		}]
	}
}
