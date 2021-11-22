# Provisioning Algorand Systems and Scenarios with Cuelang

## Overview

This is a framework for defining and running scenarios on Algorand. Before you can run a scenario, you need to set up the components of the system, including a local private Algorand network, a set of wallets and accounts, initial balances, and applications.  When done manually, this setup requires numerous steps and tools. This framework allows you to define and run that setup in an automatic and reproducible way.

Moreover, suppose you want to define many scenarios. You will need a way to stay organized, minimize duplication, and focus only on the details that vary from one scenario to the next. We'll use [Cuelang](https://cuelang.org/) as the primary tool for achieving these goals. We'll also use python, the [click](https://click.palletsprojects.com/en/8.0.x/) cli library, and `py-algorand-sdk` to create a simple `algo` cli tool. This will provide commands similar to what `goal` provides, but without the interactive authentication prompts.

## Table of Contents

- [Provisioning Algorand Systems and Scenarios with Cuelang](#provisioning-algorand-systems-and-scenarios-with-cuelang)
  - [Overview](#overview)
  - [Table of Contents](#table-of-contents)
  - [1. Introduction](#1-introduction)
  - [2. Code Tour](#2-code-tour)
    - [2.1 Cue Configuration](#21-cue-configuration)
    - [2.2 Pyteal Applications](#22-pyteal-applications)
    - [2.3 `algo` CLI Tool](#23-algo-cli-tool)
  - [3. Setup Your Development Environment](#3-setup-your-development-environment)
  - [4. Demo: Provision a Network with Unencrypted Default Wallets and Accounts](#4-demo-provision-a-network-with-unencrypted-default-wallets-and-accounts)
    - [4.1 Standard Method: `goal network create`](#41-standard-method-goal-network-create)
    - [4.2 Using Cue Configs](#42-using-cue-configs)
    - [4.3 `cue up`](#43-cue-up)
    - [4.4 Saving Instance Data](#44-saving-instance-data)
    - [4.5 cue status](#45-cue-status)
    - [4.6 `cue wallets`](#46-cue-wallets)
    - [4.6 `cue balances`](#46-cue-balances)
    - [4.6 `cue down`](#46-cue-down)
  - [5. Demo: Provision a Network, Encrypted Wallets, Accounts, and Applications](#5-demo-provision-a-network-encrypted-wallets-accounts-and-applications)
    - [5.1 Scenarios/Network2](#51-scenariosnetwork2)
    - [5.2 Scenarios/Network2/Scenario1: Users & Apps](#52-scenariosnetwork2scenario1-users--apps)
    - [5.3 `cue up`](#53-cue-up)
    - [5.4 `cue run`](#54-cue-run)
  - [6. Additional Scenarios](#6-additional-scenarios)
    - [6.1 Defining Scenarios/Network2/Scenario2](#61-defining-scenariosnetwork2scenario2)
    - [6.2 Running Scenarios/Network2/Scenario2](#62-running-scenariosnetwork2scenario2)
  - [6. Resources](#6-resources)

## 1. Introduction
This repo contains three main things: an `apps` directory where smart contracts are defined, a `cli` directory where we define a few commands similar to what `goal` provides, and a `Scenarios` directory which contains network and scenario specifications. 

`Scenarios/Network1/Scenario1` is a minimal example where we only provision a local private network. `Scenarios/Network2` contains two complex scenarios where we provision a local private network, users, initial balances, and applications. These complex scenarios demonstrate that we can:

* Provision a local private network, an unencrypted Faucet wallet, a set of users (regular encrypted wallets with accounts), and compile pyteal apps with:
```
$ cue up ./Scenarios/[network]/[scenario]
```
* Fund user accounts and deploy applications with:
```
$ cue run ./Scenarios/[network]/[scenario]/instance
```
* Print details about the network status, wallets, account infos, and balances with:
```
$ cue status ./Scenarios/[network]/[scenario]/instance
$ cue wallets ./Scenarios/[network]/[scenario]/instance
$ cue balances ./Scenarios/[network]/[scenario]/instance
$ cue accounts ./Scenarios/[network]/[scenario]/instance
```

* Inspect our network/scenario configs, instance data, and custom cue cli command tasks with:
```
$ cue eval ./Scenarios/[network]/[scenario]/instance -e [expression]
```

* Teardown our network and scenario instance data with:
```
$ cue down ./Scenarios/[network]/[scenario]
```

## 2. Code Tour


### 2.1 Cue Configuration

This is the heart of the solution, where we define the network, wallet/account, and app topologies for a variety of scenarios. 

Additionally, the `cmd_*.cue` and `cue_tool.cue` files define custom cue cli commands executed with `cue [cmd] [scenario]`.
```
└── Scenarios
    ├── cmd_accounts.cue
    ├── cmd_balances.cue
    ├── cmd_down.cue
    ├── cmd_run.cue
    ├── cmd_status.cue
    ├── cmd_up.cue
    ├── cmd_wallets.cue
    ├── cue_tool.cue
    ├── Network1
    │   ├── network.cue
    │   └── Scenario1
    │       └── scenario.cue
    ├── Network2
    │   ├── network.cue
    │   ├── Scenario1
    │   │   ├── apps.cue
    │   │   └── users.cue
    │   └── Scenario2
    │       ├── apps.cue
    │       └── users.cue
    └── specifications.cue
```

### 2.2 Pyteal Applications
 Applications will go under `apps/[appName]` and will always have at least two files named `approval.py` and `clear_state.py`:
```
└── apps
    ├── AppA
    │   ├── approval.py
    │   ├── clear_state.py
    │   └── __init__.py
    ├── AppB
    │   ├── approval.py
    │   ├── clear_state.py
    │   └── __init__.py
    ├── AppC
    │   ├── approval.py
    │   ├── clear_state.py
    │   └── __init__.py
    └── __init__.py
```
This will allow us to iterate over the directory and compile applications with `python3 -m apps.[appName].approval` and `python3 -m apps.[appName].clear_state`. 

Compiled teal files will be saved under `bin/apps`:
```
└── bin
    └── apps
        ├── AppA
        │   ├── approval.teal
        │   └── clear_state.teal
        ├── AppB
        │   ├── approval.teal
        │   └── clear_state.teal
        └── AppC
            ├── approval.teal
            └── clear_state.teal
```

### 2.3 `algo` CLI Tool

These files comprise a simple `algo` python cli tool, which provides a few commands similar to what `goal` provides, but without interactive password prompts. Some commands also return service-like json responses which allows us to capture scenario instance data.
```
├── algo
└── cli
    ├── account.py
    ├── app.py
    ├── __init__.py
    └── wallet.py
```

## 3. Setup Your Development Environment

This solution was developed and tested on Ubuntu and ought to work for any linux distribution. The requirements consist of the algorand node software, cuelang, python3, py-algorand-sdk, pyteal, and click (python cli framework).

1. [Install the Algorand Node software](https://developer.algorand.org/docs/run-a-node/setup/install/). 
    - You don't need the main node running for this solution. You can stop it by running `sudo systemctl stop algorand`
2. [Install cuelang](https://cuelang.org/docs/install/)
3. Install python dependecies
    - `pip3 install -r requirements.txt` will install these libraries:
        - [py-algorand-sdk](https://github.com/algorand/py-algorand-sdk)
        - [pyteal](https://pyteal.readthedocs.io/en/stable/installation.html) 
        - [click](https://click.palletsprojects.com/en/8.0.x/#)

## 4. Demo: Provision a Network with Unencrypted Default Wallets and Accounts

### 4.1 Standard Method: `goal network create`
Let's start with a simple scenario which only includes features supported by the `goal network create` command. This command takes a template file in which you specify nodes, accounts, and initial stakes. For example: 
```json
Genesis: {
    NetworkName: "Network1"
    Wallets: [{
        Name:   "Account1"
        Stake:  50
        Online: true
    }, {
        Name:   "Account2"
        Stake:  40
        Online: true
    }, {
        Name:   "Account3"
        Stake:  10
        Online: false
    }]
}
Nodes: [{
    Name:    "Primary"
    IsRelay: true
    Wallets: [{
        Name:              "Account1"
        ParticipationOnly: false
    }]
}, {
    Name: "Node1"
    Wallets: [{
        Name:              "Account2"
        ParticipationOnly: false
    }, {
        Name:              "Account3"
        ParticipationOnly: false
    }]
}]
``` 
> Note: `Wallets:[]` is actually a list of accounts. `goal network create` will create a single wallet on each node called `unencrypted-default-wallet` and the accounts will be added under that wallet on the specified node.

If you were to manually create a network with this file, there are a few things you'd need to keep track of. Consider this command:
```
$ goal network create -n Network1 -t ./template.json -r ./networks/Network1
```
We have three arguments we have to choose:

1. network name
2. template filepath
3. network data directory 

After creation, we have to keep track of the network directory and node data sub-directories for other goal commands. For example:
```
$ goal network start -r ./networks/Network1
$ goal account list -d ./networks/Network1/Primary
```

### 4.2 Using Cue Configs
Those arguments can be tedious to keep track of, and are a good candidate for configuration. Let's look at the the cue file that defines this template:

`./Scenarios/Network1/network.cue`
```go
package algo

// Constants
let Account1 = "Account1"
let Account2 = "Account2"
let Account3 = "Account3"

Network: {

	// Network conforms to schema #Network
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

```
There are a few additions that differentiate this from the pure json template:

1. We've created constants for the account names to avoid mispellings across occurances.
2. The template is inside a parent `Network` struct. This will be convenient later, as we'll have three top-level structs (`Network`, `Users`, `Apps`). We have the network name easily accessible under `Network.name` and the template under `Network.template`.
3. `Network` conforms to specification `#Network`, which ensures we don't have any errors in the configuration.

The `#Network` specification is defined in:

`./Scenarios/specifications.cue`:
```go
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
```

Notice that the `#Network` specification includes a `directory` property which we didn't specify in the `Network` config. This says that `directory` will always equal  `"bin/networks/\(name)"` where `\(name)` will be interpolated to the value of `Network.name`. Cue will generate `directory` automatically, and we'll be able to reference it via `Network.directory`. 

### 4.3 `cue up`
Now that we have this file, what do we do with it? If we want, we can manually export the whole thing to json with:
```
cue export ./Scenarios/Network1/Scenario1 -e Network
``` 
or only the genesis template with:
```
cue export ./Scenarios/Network1/Scenario1 -e Network.template
```

If we do that, we'll still need some other tool to read in the json and setup the network, or we'll need to do it manually with `goal`. 

Instead, cue allows us to define extensions to the `cue` cli tool which can execute external programs and directly reference values in the cue configuration as arguments to those commands.

Let's look at `cue up` as the first command we'll use. We run this command with:
```bash
$ cue up ./Scenarios/Network1/Scenario1

Created new rootkey: /home/eadlam/Projects/cue-algorand-provision/bin/networks/Network1/Account1.rootkey
Created new rootkey: /home/eadlam/Projects/cue-algorand-provision/bin/networks/Network1/Account3.rootkey
Created new rootkey: /home/eadlam/Projects/cue-algorand-provision/bin/networks/Network1/Account2.rootkey
Created new partkey: /home/eadlam/Projects/cue-algorand-provision/bin/networks/Network1/Account1.0.3000000.partkey
https://github.com/algorandfoundation/specs/tree/bc36005dbd776e6d1eaf0c560619bb183215645c 100000
Created new partkey: /home/eadlam/Projects/cue-algorand-provision/bin/networks/Network1/Account2.0.3000000.partkey
Network Network1 created under /home/eadlam/Projects/cue-algorand-provision/bin/networks/Network1
``` 

You can look at the source code (`./Scenarios/cmd_up.cue`) to see everything defined for this command, but since commands are simply cue configurations, an easy way to see what it's doing is to query `command.up` with cue:

```
$ cue eval ./Scenarios/Network1/Scenario1 -e '{for k, v in command.up {"\(k)": v.$id}}'

mkdirs:               "tool/exec.Run"
materialize:          "tool/file.Create"
network_create:       "tool/exec.Run"
print_network_create: "tool/cli.Print"
read_genesis:         "tool/file.Read"
write_cue_genesis:    "tool/file.Create"
network_start:        "tool/exec.Run"
kmd_start_Primary:    "tool/exec.Run"
kmd_start_Node1:      "tool/exec.Run"
```

Every command is defined as a struct, where each key is an arbitrary name (descriptive of the task) and the value is the configuration of what it should do (e.g. what external command should be executed, what type of output should be expected on stdout, what other step should precede it, etc.) 

The query above simply returns the name of the task, and the type of execution that task does (`tool/exec.Run`, `tool/file.Create`, `tool/cli.Print`).

We can drill down further and look at the actual cli commands being run by `"tool/exec.Run"` tasks. This shows us exactly the commands we would need to run manually to reproduce this setup without cue:

```
$ cue eval ./Scenarios/Network1/Scenario1 -e '{for k, v in command.up if v.$id == "tool/exec.Run" {"\(k)": v.cmd}}'

mkdirs:            "mkdir -p bin/materialized bin/networks bin/apps Scenarios/Network1/Scenario1/instance"
network_create:    "goal network create -n Network1 -t bin/materialized/Network1.json -r bin/networks/Network1"
network_start:     "goal network start -r bin/networks/Network1"
kmd_start_Primary: "goal kmd start -d bin/networks/Network1/Primary"
kmd_start_Node1:   "goal kmd start -d bin/networks/Network1/Node1"
```

Some of those commands reference files. We can see which files we're creating with this query:

```
$ cue eval ./Scenarios/Network1/Scenario1 -e '{for k, v in command.up if v.$id == "tool/file.Create" {"\(k)": v.filename}}'

materialize:       "bin/materialized/Network1.json"
write_cue_genesis: "Scenarios/Network1/Scenario1/instance/genesis.cue"
```

The `materialize` task saves `Network.template` as a json file to `bin/materialized/Network1.json`. Then, the `network_create` task passes that path to `goal network create`.

After the network is created, we read in the `bin/networks/Network1/genesis.json` file created by `goal network create` and save it back to a cue file under `./Scenarios/Network1/Scenario1/instance`. 


### 4.4 Saving Instance Data
This general pattern of capturing instance data and saving it back to cue gives us a powerful method for introspecting the network, and to some extent, simulating a service backend without the need to manage a service or a database.

In this case, we saved the genesis data to `./Scenarios/Network1/Scenario1/instance/genesis.cue`, and used a struct comprehension to create a conveniently formatted account list under `GenesisAccounts`. We can query it with `eval` or `export`. Let's export it to yaml for readability: 

```
$ cue export ./Scenarios/Network1/Scenario1/instance -e GenesisAccounts --out yaml
```
```yaml
RewardsPool:
  addr: 7777777777777777777777777777777777777777777777777774MSJUVU
  comment: RewardsPool
  state:
    algo: 125000000000000
    onl: 2
FeeSink:
  addr: A7NMWS3NT3IUDMLVO26ULGXGIIOUQ3ND2TXSER6EBGRZNOBOUIQXHIBGDE
  comment: FeeSink
  state:
    algo: 100000
    onl: 2
Account1:
  addr: APHNJYF5FEVSAN6J6MBIT2ZDQBJDLXYODPLDJFKXPU3SYUBJBC5I7UJWP4
  comment: Account1
  state:
    algo: 5000000000000000
    onl: 1
    sel: 55/PVSIMqH80d+R2Y03XV2EfEqINtUCLu/ghhM85ROQ=
    vote: 8BVvVhGJob4ElaE4i6Qit/51HS+72IPIvaMOR/RCksA=
    voteKD: 10000
    voteLst: 3000000
Account2:
  addr: UQWTR3TRPJBXBSDOR56YPX3NM2UX2AO7TUFLCPBY3KVIMVX6ZLHNAZCLFM
  comment: Account2
  state:
    algo: 4000000000000000
    onl: 1
    sel: rPeidglpPY9zkfLVwwvav8JmwiykoaHCjbEMPpyR1Q4=
    vote: ofETPyARGZZ1KUXeqSjE5ZWttq3PGPRDYvwmgiAniGc=
    voteKD: 10000
    voteLst: 3000000
Account3:
  addr: JWVSHWK7OXWVQ2UBT2CV6R35H73QBEEHDGEOCYJ3MSAUBXUCME7UVVWPVU
  comment: Account3
  state:
    algo: 1000000000000000
```

This data is static, captured at the time of network creation. Let's look at some commands designed to query live data using `goal` and our `./algo` cli.

### 4.5 cue status
First let's list the `exec.Run` tasks run by `cue status`:
```
$ cue eval ./Scenarios/Network1/Scenario1 -e '{for k, v in command.status if v.$id == "tool/exec.Run" {"\(k)": v.cmd}}'

status: "goal network status -r bin/networks/Network1"
```

There is one `exec.Run` task, which simply runs `goal network status`. Let's look at the output:

```
$ cue status ./Scenarios/Network1/Scenario1

[Node1]
Last committed block: 453
Time since last block: 3.5s
Sync Time: 0.0s
Last consensus protocol: https://github.com/algorandfoundation/specs/tree/bc36005dbd776e6d1eaf0c560619bb183215645c
Next consensus protocol: https://github.com/algorandfoundation/specs/tree/bc36005dbd776e6d1eaf0c560619bb183215645c
Round for next consensus protocol: 454
Next consensus protocol supported: true

[Primary]
Last committed block: 453
Time since last block: 3.5s
Sync Time: 0.0s
Last consensus protocol: https://github.com/algorandfoundation/specs/tree/bc36005dbd776e6d1eaf0c560619bb183215645c
Next consensus protocol: https://github.com/algorandfoundation/specs/tree/bc36005dbd776e6d1eaf0c560619bb183215645c
Round for next consensus protocol: 454
Next consensus protocol supported: true
```
This confirms that the network is running.

### 4.6 `cue wallets`

Again, let's look at the `exec.Run` tasks, this time for `cue wallets`:
```
$ cue eval ./Scenarios/Network1/Scenario1 -e '{for k, v in command.wallets if v.$id == "tool/exec.Run" {"\(k)": v.cmd}}'

wallets_Primary: "goal wallet list -d bin/networks/Network1/Primary"
wallets_Node1:   "goal wallet list -d bin/networks/Network1/Node1"
```

We see that `cue wallets` runs `goal wallet list` once for each node defined in the network topology.

Output:
```
$ cue wallets ./Scenarios/Network1/Scenario1/instance
Node1 wallets:
##################################################
Wallet: unencrypted-default-wallet
ID:     cebe6ac71863430c5ff1c208996f3955
##################################################

Primary wallets:
##################################################
Wallet: unencrypted-default-wallet
ID:     b881a10f9394288805fcc478aa396e8e
##################################################
```

This demonstrates another advantage of custom cue cli commands: not only can we use configration values as arguments to external commands, we can also iterate over configuration items to generate a list of external commands to run. 

In this case, it's a list of `goal wallet list -d` commands.

### 4.6 `cue balances`

Let's look at the tasks executed when we run `cue balances`:
```
$ cue eval ./Scenarios/Network1/Scenario1 -e '{for k, v in command.balances if v.$id == "tool/exec.Run" {"\(k)": v.cmd}}'

balances_Primary: "./algo -d bin/networks/Network1/Primary account balances -w unencrypted-default-wallet"
balances_Node1:   "./algo -d bin/networks/Network1/Node1 account balances -w unencrypted-default-wallet"
```

This time, the tasks will run our `./algo` cli tool instead of `goal`. This is because it's a little easier to query all account balances for a wallet via the python sdk than to do so with existing `goal` commands. The `./algo account balances` command is short and simple:

```python
@account.command()
@click.option("-w", "--wallet", "wallet_name", help="Wallet Name")
@click.option("-p", "--pasword", "wallet_password", help="Wallet Password")
@click.pass_obj
def balances(clients, wallet_name, wallet_password):
    wallet = Wallet(wallet_name, wallet_password, clients.kcl)
    output = "({}) {}:\n".format(clients.node, wallet_name)
    for i in wallet.list_keys():
        output += "  {}: {}\n".format(i, clients.algod.account_info(i).get("amount"))
    print(output)
```

Output for `cue balances ./Scenarios/Network1/Scenario`:

```
$ cue balances ./Scenarios/Network1/Scenario1

(Primary) unencrypted-default-wallet:
  APHNJYF5FEVSAN6J6MBIT2ZDQBJDLXYODPLDJFKXPU3SYUBJBC5I7UJWP4: 5001780000000000


(Node1) unencrypted-default-wallet:
  JWVSHWK7OXWVQ2UBT2CV6R35H73QBEEHDGEOCYJ3MSAUBXUCME7UVVWPVU: 1000356000000000
  UQWTR3TRPJBXBSDOR56YPX3NM2UX2AO7TUFLCPBY3KVIMVX6ZLHNAZCLFM: 4001424000000000
```

### 4.6 `cue down`
Let's review the files and directories created by `cue up`:

```
├── bin                                       
│   ├──materialized      
│   │   └── Network1.json          
│   └── networks                
│       └── Network1
│           ├── Node1 
│           │   └── ...
│           └── Primary
│               └── ...
└── Scenarios
    └── Network1
        ├── network.cue
        └── Scenario1
            └── instance
                └── genesis.cue
```

When we're done with an experiment, we want to tear down the instance data. Let's look at what the `cue down` command does:

```
$ cue eval ./Scenarios/Network1/Scenario1 -e '{for k, v in command.down if v.$id == "tool/exec.Run" {"\(k)": v.cmd}}'

delete_network_data:              "goal network delete -r bin/networks/Network1"
delete_materialized_network_json: "rm bin/materialized/Network1.json"
delete_scenario_instance_data:    "rm -rf Scenarios/Network1/Scenario1/instance"
```
- `goal network delete` deletes the network data in `/bin/networks/Network1`
- `rm` removes the materialized `Network1.json` file and the `Scenario1/instance` directory

And with that, the network is shutdown and all instance data is cleaned up. 

## 5. Demo: Provision a Network, Encrypted Wallets, Accounts, and Applications

Now let's look at a more complex example. 

### 5.1 Scenarios/Network2

`Scenarios/Network2` will only have a single unencrypted default account called `Faucet`, and we're adding a `config` for `Node1` which sets `EnableDeveloperAPI: true`. We'll use this to overwrite `./bin/networks/Network2/Node1/config.json` before starting the network.

`./Scenarios/Network2/network.cue`
```go
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
```

### 5.2 Scenarios/Network2/Scenario1: Users & Apps

This time we will define some users:

`./Scenarios/Network2/Scenario1/users.cue`
```go
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
```

and an app:

`./Scenarios/Network2/Scenario1/apps.cue`
```go
package algo

Apps: AppA: [
    Users.Silvio.wallets.SilviosWallet.accounts.primary
]
```

`Apps` is a struct where each key is the name of an app and the value is a list of accounts. For each account in the list, we will deploy the app as a transaction from that account.

### 5.3 `cue up`

This time when we run cue up, we have some new tasks for creating user accounts:

```
$ cue eval ./Scenarios/Network2/Scenario1 -e '{for k, v in command.up if v.$id == "tool/exec.Run" {"\(k)": v.cmd}}'

mkdirs:                         "mkdir -p bin/materialized bin/networks bin/apps Scenarios/Network2/Scenario1/instance"
network_create:                 "goal network create -n Network2 -t bin/materialized/Network2.json -r bin/networks/Network2"
network_start:                  "goal network start -r bin/networks/Network2"
kmd_start_Primary:              "goal kmd start -d bin/networks/Network2/Primary"
kmd_start_Node1:                "goal kmd start -d bin/networks/Network2/Node1"
mkdir_AppA:                     "mkdir -p bin/apps/AppA"
create_AppA_approval:           "python3 -m apps.AppA.approval"
create_AppA_clear_state:        "python3 -m apps.AppA.clear_state"
create_SilviosWallet:           "./algo -d bin/networks/Network2/Node1 wallet new Silvio SilviosWallet"
create_MariasWallet:            "./algo -d bin/networks/Network2/Node1 wallet new Maria MariasWallet"
create_SilviosWallet_primary:   "./algo -d bin/networks/Network2/Node1 account new -u Silvio -w SilviosWallet -p SilviosWallet_password primary"
create_SilviosWallet_secondary: "./algo -d bin/networks/Network2/Node1 account new -u Silvio -w SilviosWallet -p SilviosWallet_password secondary"
create_MariasWallet_primary:    "./algo -d bin/networks/Network2/Node1 account new -u Maria -w MariasWallet -p MariasWallet_password primary"
create_MariasWallet_secondary:  "./algo -d bin/networks/Network2/Node1 account new -u Maria -w MariasWallet -p MariasWallet_password secondary"
```

We're using a custom command in the `algo` cli tool to create the accounts (`./algo account new`), instead of `goal`,  so that we can avoid interactive prompts, and return json data for the newly created accounts.   

After running `cue up ./Scenarios/Network2/Scenario1`, we can see a set of user files were written to `./Scenarios/Network2/Scenario1/instance`:

```
└── Scenarios
    ├── Network2
    │   ├── Scenario1
    │   │   ├── instance
    │   │   │   ├── genesis.cue
    │   │   │   ├── Maria.MariasWallet.cue
    │   │   │   ├── Maria.MariasWallet.primary.cue
    │   │   │   ├── Maria.MariasWallet.secondary.cue
    │   │   │   ├── Silvio.SilviosWallet.cue
    │   │   │   ├── Silvio.SilviosWallet.primary.cue
    │   │   │   └── Silvio.SilviosWallet.secondary.cue
```

Let's query this data with cue:

```yaml
$ cue export ./Scenarios/Network2/Scenario1/instance --out yaml -e Users
Silvio:
  name: Silvio
  wallets:
    SilviosWallet:
      name: SilviosWallet
      node: Node1
      password: SilviosWallet_password
      accounts:
        primary:
          stake: 49
          key: TJHVEY5CPRIGNQBPM7LTZT3R3TYQONZHJ3QJ6PASRKPODM3A7B42BSZZ3M
          name: primary
          node: Node1
          wallet: SilviosWallet
        secondary:
          stake: 10
          key: AG6HWFUMHQ3SZ6TNPZG6D3JVBDSD6A5VDQVSX6OGA5WGUQJQXPGALOVIIU
          name: secondary
          node: Node1
          wallet: SilviosWallet
      mnemonic: demise elbow local during sentence welcome subway sentence palace
        abuse target moon subway alpha verb fiscal photo valid cat staff sustain increase
        develop abandon desk
Maria:
  name: Maria
  wallets:
    MariasWallet:
      name: MariasWallet
      node: Node1
      password: MariasWallet_password
      accounts:
        primary:
          stake: 5
          key: 4OFYPXE6PKR2IT3CJS6FB2DFMEZGG7WLLTLUWVOXPETTYXTZUJ77ABZEP4
          name: primary
          node: Node1
          wallet: MariasWallet
        secondary:
          stake: 10
          key: ACDCSHW3U2NUACOB7XXMT3Z7I5IVGVKJI2M22FVVMETY567NLR4E4MN6U4
          name: secondary
          node: Node1
          wallet: MariasWallet
      mnemonic: coach oven once sport earn narrow lawsuit permit violin run daughter
        address voice believe initial multiply length among include run next oven
        board about crazy
```

We've captured the json response data from `./algo account new` and written it back to cue. This allows us to manually browse the data, and use it in the `cue run` command.

Notice also that `cue up` has compiled the pyteal app `AppA` to teal:

```
├── bin                                             
│   ├── apps                              
│   │   ├── AppA                  
│   │   │   ├── approval.teal  
│   │   │   └── clear_state.teal  
```

Now when we run `cue run`, we'll be able to deploy that app.

Before we get to cue run, let's ensure that the wallets all exist and the account balances for users are 0 algos:

```
$ cue wallets ./Scenarios/Network2/Scenario1/instance

Primary wallets:
##################################################
Wallet: unencrypted-default-wallet
ID:     22cff2fc35a5472e03eed76667400673
##################################################

Node1 wallets:
##################################################
Wallet: MariasWallet
ID:     1e3ad39778144e1476f93b58d3453594
##################################################
Wallet: SilviosWallet
ID:     85c172cf56e9be6c1c20a69c0efbf832
##################################################
Wallet: unencrypted-default-wallet
ID:     e47f8a7e600b2805e1f40cae7887d741
##################################################
```

```
$ cue balances ./Scenarios/Network2/Scenario1/instance

(Node1) MariasWallet:
  ACDCSHW3U2NUACOB7XXMT3Z7I5IVGVKJI2M22FVVMETY567NLR4E4MN6U4: 0
  4OFYPXE6PKR2IT3CJS6FB2DFMEZGG7WLLTLUWVOXPETTYXTZUJ77ABZEP4: 0


(Node1) SilviosWallet:
  AG6HWFUMHQ3SZ6TNPZG6D3JVBDSD6A5VDQVSX6OGA5WGUQJQXPGALOVIIU: 0
  TJHVEY5CPRIGNQBPM7LTZT3R3TYQONZHJ3QJ6PASRKPODM3A7B42BSZZ3M: 0


(Node1) unencrypted-default-wallet:
  KZYKDS266NCIO7J7RTGCN3MDGGJFADBT3H4VROPHKLKY34X6AWI7JPYW4U: 10000080000000000


(Primary) unencrypted-default-wallet:
```

Here we see that all funds are still in the Faucet account in `(Node1) unencrypted-default-wallet`.

To initiate the fund transfers for the encrypted user wallets initial stakes, we'll run `cue run`

### 5.4 `cue run`

Let's look at what cue run does:

```
$ cue eval ./Scenarios/Network2/Scenario1/instance -e '{for k, v in command.run if v.$id == "tool/exec.Run" {"\(k)": v.cmd}}'

deploy_AppA_SilviosWallet_primary: "./algo -d bin/networks/Network2/Node1 app create -w SilviosWallet -p SilviosWallet_password TJHVEY5CPRIGNQBPM7LTZT3R3TYQONZHJ3QJ6PASRKPODM3A7B42BSZZ3M ./bin/apps/AppA"
fund_SilviosWallet_primary:        "goal -d bin/networks/Network2/Node1 clerk send -w unencrypted-default-wallet -f KZYKDS266NCIO7J7RTGCN3MDGGJFADBT3H4VROPHKLKY34X6AWI7JPYW4U -t TJHVEY5CPRIGNQBPM7LTZT3R3TYQONZHJ3QJ6PASRKPODM3A7B42BSZZ3M -a  4900000000000000"
fund_SilviosWallet_secondary:      "goal -d bin/networks/Network2/Node1 clerk send -w unencrypted-default-wallet -f KZYKDS266NCIO7J7RTGCN3MDGGJFADBT3H4VROPHKLKY34X6AWI7JPYW4U -t AG6HWFUMHQ3SZ6TNPZG6D3JVBDSD6A5VDQVSX6OGA5WGUQJQXPGALOVIIU -a  1000000000000000"
fund_MariasWallet_primary:         "goal -d bin/networks/Network2/Node1 clerk send -w unencrypted-default-wallet -f KZYKDS266NCIO7J7RTGCN3MDGGJFADBT3H4VROPHKLKY34X6AWI7JPYW4U -t 4OFYPXE6PKR2IT3CJS6FB2DFMEZGG7WLLTLUWVOXPETTYXTZUJ77ABZEP4 -a  500000000000000"
fund_MariasWallet_secondary:       "goal -d bin/networks/Network2/Node1 clerk send -w unencrypted-default-wallet -f KZYKDS266NCIO7J7RTGCN3MDGGJFADBT3H4VROPHKLKY34X6AWI7JPYW4U -t ACDCSHW3U2NUACOB7XXMT3Z7I5IVGVKJI2M22FVVMETY567NLR4E4MN6U4 -a  1000000000000000"
```

It will transfer funds from the `unencrypted-default-wallet`, `Faucet` account to four user accounts (two users, each with two accounts). It will also deploy one app from one user account.

```
$ cue run ./Scenarios/Network2/Scenario1/instance

Funding: Maria.MariasWallet.primary (4OFYPXE6PKR2IT3CJS6FB2DFMEZGG7WLLTLUWVOXPETTYXTZUJ77ABZEP4)
Sent 500000000000000 MicroAlgos from account KZYKDS266NCIO7J7RTGCN3MDGGJFADBT3H4VROPHKLKY34X6AWI7JPYW4U to address 4OFYPXE6PKR2IT3CJS6FB2DFMEZGG7WLLTLUWVOXPETTYXTZUJ77ABZEP4, transaction ID: FRHICB2AUUXWJ2IXKYMQW5CFKXWBULWM3O3PDDKUSMZJBP33WMGA. Fee set to 1000
Transaction FRHICB2AUUXWJ2IXKYMQW5CFKXWBULWM3O3PDDKUSMZJBP33WMGA still pending as of round 6491
Transaction FRHICB2AUUXWJ2IXKYMQW5CFKXWBULWM3O3PDDKUSMZJBP33WMGA still pending as of round 6492
Transaction FRHICB2AUUXWJ2IXKYMQW5CFKXWBULWM3O3PDDKUSMZJBP33WMGA committed in round 6493

Funding: Silvio.SilviosWallet.primary (TJHVEY5CPRIGNQBPM7LTZT3R3TYQONZHJ3QJ6PASRKPODM3A7B42BSZZ3M)
Sent 4900000000000000 MicroAlgos from account KZYKDS266NCIO7J7RTGCN3MDGGJFADBT3H4VROPHKLKY34X6AWI7JPYW4U to address TJHVEY5CPRIGNQBPM7LTZT3R3TYQONZHJ3QJ6PASRKPODM3A7B42BSZZ3M, transaction ID: SUVZOL2MRD45GW6KMQ7NTWTEHYCIPELQWNRGHXS6VIMOK7FFERHA. Fee set to 1000
Transaction SUVZOL2MRD45GW6KMQ7NTWTEHYCIPELQWNRGHXS6VIMOK7FFERHA still pending as of round 6491
Transaction SUVZOL2MRD45GW6KMQ7NTWTEHYCIPELQWNRGHXS6VIMOK7FFERHA still pending as of round 6492
Transaction SUVZOL2MRD45GW6KMQ7NTWTEHYCIPELQWNRGHXS6VIMOK7FFERHA committed in round 6493

Funding: Maria.MariasWallet.secondary (ACDCSHW3U2NUACOB7XXMT3Z7I5IVGVKJI2M22FVVMETY567NLR4E4MN6U4)
Sent 1000000000000000 MicroAlgos from account KZYKDS266NCIO7J7RTGCN3MDGGJFADBT3H4VROPHKLKY34X6AWI7JPYW4U to address ACDCSHW3U2NUACOB7XXMT3Z7I5IVGVKJI2M22FVVMETY567NLR4E4MN6U4, transaction ID: P6AVS3ANQWIQT5EKS5ZYYFKL2FWZJ25ZIRFT6V2CRUGV2LGTODKA. Fee set to 1000
Transaction P6AVS3ANQWIQT5EKS5ZYYFKL2FWZJ25ZIRFT6V2CRUGV2LGTODKA still pending as of round 6491
Transaction P6AVS3ANQWIQT5EKS5ZYYFKL2FWZJ25ZIRFT6V2CRUGV2LGTODKA still pending as of round 6492
Transaction P6AVS3ANQWIQT5EKS5ZYYFKL2FWZJ25ZIRFT6V2CRUGV2LGTODKA committed in round 6493

Funding: Silvio.SilviosWallet.secondary (AG6HWFUMHQ3SZ6TNPZG6D3JVBDSD6A5VDQVSX6OGA5WGUQJQXPGALOVIIU)
Sent 1000000000000000 MicroAlgos from account KZYKDS266NCIO7J7RTGCN3MDGGJFADBT3H4VROPHKLKY34X6AWI7JPYW4U to address AG6HWFUMHQ3SZ6TNPZG6D3JVBDSD6A5VDQVSX6OGA5WGUQJQXPGALOVIIU, transaction ID: DTX5BODEEGZ3N2AOF6X5PTIHGFNOXO5KVU5VQUHUEJO53VYHPHYA. Fee set to 1000
Transaction DTX5BODEEGZ3N2AOF6X5PTIHGFNOXO5KVU5VQUHUEJO53VYHPHYA still pending as of round 6491
Transaction DTX5BODEEGZ3N2AOF6X5PTIHGFNOXO5KVU5VQUHUEJO53VYHPHYA still pending as of round 6492
Transaction DTX5BODEEGZ3N2AOF6X5PTIHGFNOXO5KVU5VQUHUEJO53VYHPHYA committed in round 6493

Creating app "AppA" for SilviosWallet.primary:
Created new app-id: 5
```

We can now check that the balances are updated:

```
$ cue balances ./Scenarios/Network2/Scenario1/instance

(Node1) MariasWallet:
  ACDCSHW3U2NUACOB7XXMT3Z7I5IVGVKJI2M22FVVMETY567NLR4E4MN6U4: 1000000000000000
  4OFYPXE6PKR2IT3CJS6FB2DFMEZGG7WLLTLUWVOXPETTYXTZUJ77ABZEP4: 500000000000000


(Node1) unencrypted-default-wallet:
  KZYKDS266NCIO7J7RTGCN3MDGGJFADBT3H4VROPHKLKY34X6AWI7JPYW4U: 2601619999996000


(Node1) SilviosWallet:
  AG6HWFUMHQ3SZ6TNPZG6D3JVBDSD6A5VDQVSX6OGA5WGUQJQXPGALOVIIU: 1000000000000000
  TJHVEY5CPRIGNQBPM7LTZT3R3TYQONZHJ3QJ6PASRKPODM3A7B42BSZZ3M: 4899999999999000


(Primary) unencrypted-default-wallet:

```

And that the application is deployed (some output is ommitted for readability):
```
$ cue accounts ./Scenarios/Network2/Scenario1/instance  

unencrypted-default-wallet:
  KZYKDS266NCIO7J7RTGCN3MDGGJFADBT3H4VROPHKLKY34X6AWI7JPYW4U: {...}

MariasWallet:        
  ACDCSHW3U2NUACOB7XXMT3Z7I5IVGVKJI2M22FVVMETY567NLR4E4MN6U4: {...}                
  4OFYPXE6PKR2IT3CJS6FB2DFMEZGG7WLLTLUWVOXPETTYXTZUJ77ABZEP4: {...}

SilviosWallet:
  AG6HWFUMHQ3SZ6TNPZG6D3JVBDSD6A5VDQVSX6OGA5WGUQJQXPGALOVIIU: {...}
  TJHVEY5CPRIGNQBPM7LTZT3R3TYQONZHJ3QJ6PASRKPODM3A7B42BSZZ3M: {
    ...
    "created-apps": [
        {
            "id": 5,
            "params": {
                "approval-program": "BYEBQw==",
                "clear-state-program": "BYEBQw==",
                "creator": "TJHVEY5CPRIGNQBPM7LTZT3R3TYQONZHJ3QJ6PASRKPODM3A7B42BSZZ3M",
                "global-state-schema": {
                    "num-byte-slice": 0,
                    "num-uint": 1
                },
                "local-state-schema": {
                    "num-byte-slice": 0,
                    "num-uint": 0
                }
            }
        }
    ]
}                        
```



## 6. Additional Scenarios
Now that we have this framework for defining, provisioning, and running scenarios, we can create new scenarios by focusing only on the `Users` and `Apps` configs.

### 6.1 Defining Scenarios/Network2/Scenario2

`./Scenarios/Network2/Scenario2/users.cue`
```go
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
```

`./Scenarios/Network2/Scenario2/apps.cue`
```
package algo

Apps: {
    AppA: [
        Users.Silvio.wallets.SilviosWallet.accounts.primary,
        Users.Maria.wallets.MariasWallet.accounts.secondary
    ]
    AppB: [
        Users.Elena.wallets.ElenasWallet.accounts.primary
    ]
    AppC: [Users.Leonardo.wallets.LeonardosWallet.accounts.primary]
}
```

### 6.2 Running Scenarios/Network2/Scenario2

Our cue cli tools allow us to deploy, run, inspect, and teardown our new scenario with the same simple commands:

```
$ cue up ./Scenarios/Network2/Scenario2
...

$ cue run ./Scenarios/Network2/Scenario2/instance
...

$ cue balances ./Scenarios/Network2/Scenario2/instance
(Primary) unencrypted-default-wallet:


(Node1) MariasWallet:
  HKV43AYNNT2C2CB6Q4HGT5JBI7LKJYLUZ7HFIM76BDKIRR7XBVBJZQX5UM: 500000000000000
  Q3CIWLO2M5W4HGVMTHQCI5YIRV5L2WIBEOGA2WN7IFLPG6GBN56MHERTVQ: 999999999999000


(Node1) SilviosWallet:
  FVJIIJW7OWFVU7F2WKZLLEGZA2RE23KLB4ORLK3HPO3ODPGF6TTME352NM: 1000000000000000
  JWZKCNEY46HJEGY6L5EPFPCJV4RIUF4JU3FIRJT2ATDBJ2AUBEQDV5UJ4I: 4899999999999000


(Node1) unencrypted-default-wallet:
  V2EUZLK7XAJQEI5LB3VBGIMESUOSTCCWWXVGDWUZ4LQFWBJBFRU3RUROD4: 99999999992000


(Node1) LeonardosWallet:
  APRZ3DQQJQUSXJVVAT6R353HO6ZWS357P4QLWQG6OFQIMVHPH57TBQQCWM: 499999999999000
  5E3HJRGCO3YXWPSXWJX643ADUC6S2MWGPGLHRQ7JS7EELW7PJYJS43DLJI: 500000000000000


(Node1) ElenasWallet:
  G62GCNKJDF2XNPB7BVAJATIT7Y623QDIULRIN54XL7HYL7KTZRUBNJS2VQ: 500000000000000
  RCPD5635CABMXD4HVLK4R6ZETEERSDVQJFARLDKR2VOOZB4NGDWKZ2MX44: 999999999999000

$ cue down ./Scenarios/Network2/Scenario2
```

## 6. Resources

- [Cuelang Tutorials](https://cuelang.org/docs/tutorials/)
- [The Logic of Cue](https://cuelang.org/docs/concepts/logic/)
- [Algorand - Create A Private Network](https://developer.algorand.org/tutorials/create-private-network/)
   