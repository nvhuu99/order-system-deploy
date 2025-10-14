### Commands:

    terraform fmt
    terraform init
    terraform validate
    terraform apply
    terraform destroy

    terraform state [list/pull]

    terraform taint             The terraform taint command marks a resource as "tainted," which tells Terraform to destroy and recreate it on the next terraform apply

### Files:

- **terraform.tfstate:** When you use Terraform to plan and apply changes to your workspace's infrastructure, Terraform compares the last known state in your state file, your current configuration, and data returned by your providers to create its execution plan.