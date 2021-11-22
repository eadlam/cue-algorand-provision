package algo

let Account1 = "Account1"
let Account2 = "Account2"
let Account3 = "Account3"

Network: {

	// This struct conforms to schema #Network
	#Network

	// Network name
	name: "Network1"

	// The network template expected by: goal network create -t
	template: {
		Genesis: {
			NetworkName: Network.name
			Wallets: [{
				Name:   Account1
				Stake:  50
				Online: true
			}, {
				Name:   Account2
				Stake:  40
				Online: true
			}, {
				Name:   Account3
				Stake:  10
				Online: false
			}]
		}
		Nodes: [{
			Name:    "Primary"
			IsRelay: true
			Wallets: [{
				Name:              Account1
				ParticipationOnly: false
			}]
		}, {
			Name: "Node1"
			Wallets: [{
				Name:              Account2
				ParticipationOnly: false
			}, {
				Name:              Account3
				ParticipationOnly: false
			}]
		}]
	}
}
