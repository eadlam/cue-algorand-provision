package algo

Scenario: "Scenario1"
let Node1 = "Node1"

Users: #Users & {
    
    Silvio: wallets: SilviosWallet: {
        node: Node1
        accounts: {
            primary: stake: 49
            secondary: stake: 10
        }
    }
    
    Maria: wallets: MariasWallet: {
        node: Node1
        accounts: {
            primary: stake: 5
            secondary: stake: 10
        }
    }
    
}