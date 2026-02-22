output "env" {
  value = {
    for e in ["sandbox", "stag", "prod"] : e => {
      project_id           = module.projects[e].project_id
      tf_state_bucket      = module.projects[e].tf_state_bucket
      wif_provider         = module.wif[e].workload_identity_provider
      tf_deployer_sa_email = module.wif[e].tf_deployer_email
    }
  }
}

