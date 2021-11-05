package algo

#Wallet: {
    Name:   string
    Stake?:  int
    Online?: bool
    ParticipationOnly?: bool
}

#Node: {
    Name:    string
    Wallets: [...#Wallet]
    IsRelay?: bool
}

#Network: {
	// Network name
	name: string

	// Local directory to store the network to: ./networks/Example2
	directory: "bin/networks/\(name)"

	// The network template expected by: goal network create -t
	template: {
		Genesis: {
			NetworkName: string
			Wallets: [...#Wallet]
		}
		Nodes: [...#Node]
	}
}
