package algo

import "tool/exec"


command: down: {
    delete_network_data: {
        exec.Run
        cmd: "goal network delete -r bin/networks/\(Network.name)"
        stdout: string
    }

    delete_materialized_network_json: {
        exec.Run
        cmd: "rm bin/materialized/\(Network.name).json"
        stdout: string
    }

    delete_scenario_instance_data: {
        exec.Run
        cmd: "rm -rf Scenarios/\(Network.name)/\(Scenario)/instance"
        stdout: string
    }
}