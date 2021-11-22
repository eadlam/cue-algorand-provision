package algo


#Account: {
    key: string | *""
    name: string
    node: string
    stake: int
    wallet: string | *""
}

#Wallet:  {
    name: string | *null
    node: string
    password?: string | *"\(name)_pw"
    mnemonic?: string
    accounts: {
        [AccountName=string] : #Account & {
            name: AccountName
        }
    }

}

#User: {
    name: string
    wallets:  {
        [WalletName=string]: #Wallet & {
            name: WalletName
            accounts: {
                [AccountName=string] : #Account & {
                    wallet: WalletName
                    node: wallets[WalletName].node
                    name: AccountName
                }
            }
        }
    }
}

#Users: [UserName=string]: #User & {
    name: UserName
}

#Apps: [AppName=string]: [...#Account]

#GenesisWallet: {
    Name:   string
    Stake?:  int
    Online?: bool
    ParticipationOnly?: bool
}

#Node: {
    Name:    string
    Wallets: [...#GenesisWallet]
    IsRelay?: bool
    config?: {...}
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
			Wallets: [...#GenesisWallet]
		}
		Nodes: [...#Node]
	}
}
