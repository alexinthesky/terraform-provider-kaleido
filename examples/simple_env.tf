/*
This creates suite of environments using all available
environment types and consensus methods.
*/

provider "kaleido" {
  "api" = "https://console.kaleido.io/api/v1"
  "api_key" = "u0vphsjtqd-GMmgpj+ZxVL29x7Wm0P+Cvy6rsVojjJt4SExhXLUQlQ="
}

variable "env_types" {
  type = "list"
  default = ["quorum", "geth"]
  description = "List of environment types you want to deploy. Options are 'quorum' and 'geth'."
}

variable "quorum_consensus" {
  type = "list"
  default = ["raft", "ibft"]
  description = "Consensus methods supported by quorum."
}

variable "nodes_per_environment" {
  type = "string"
  default = 3
  description = "The number of nodes to deploy per environment."
}

/*
This represents a Consortia. Give it a name and a description.
"mode" can be set to "single-org" or ...
*/
resource "kaleido_consortium" "mine" {
  name = "My Kaleido Consortium"
  description = "Deployed with Terraform"
  mode = "single-org"
}

/*
This creates a membership, you can give it any "org_name" you like, but it has
to be linked to a Consortium via the Consortium resource "id".
*/
resource "kaleido_membership" "kaleido" {
  consortium_id = "${kaleido_consortium.mine.id}"
  org_name = "Me"
}

/*
Creates environments in Consortia.
*/
resource "kaleido_environment" "myEnv" {
  consortium_id = "${kaleido_consortium.mine.id}"
  name = "My Environment"
  description = "Deployed with Terraform"
  env_type = "${element(var.env_types, 0)}"
  consensus_type = "${element(var.quorum_consensus, 0)}"
}

/*
Creates a node in each environment, must be linked to a consortium, environment, and membership.
*/
resource "kaleido_node" "myNode" {
  consortium_id = "${kaleido_consortium.mine.id}"
  environment_id = "${kaleido_environment.myEnv.id}"
  membership_id = "${kaleido_membership.kaleido.id}"
  name = "terraform-node"
}

/*
Creates an appkey for the "kaleido_membership" resource in
every environment.
*/
resource "kaleido_app_key" "appkey" {
  consortium_id = "${kaleido_consortium.mine.id}"
  environment_id = "${kaleido_environment.myEnv.id}"
  membership_id = "${kaleido_membership.kaleido.id}"
}