package algo

Scenario: "Scenario2"

let Node1 = "Node1"

Users: #Users & {
    
    Silvio: wallets: SilviosWallet: {
        node: Node1
        accounts: {
            primary: stake: 49
            secondary: stake: 10
        }
    }

    Leonardo: wallets: LeonardosWallet: {
        node: Node1
        accounts: {
            primary: stake: 5
            secondary: stake: 5
        }
    }
    
    Elena: wallets: ElenasWallet: {
        node: Node1
        accounts: {
            primary: stake: 10
            secondary: stake: 5
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