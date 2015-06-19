# Terraform Blue/Green Auto-Scaling Groups Demo

Create a file called `private.tf` that looks like

<pre>
provider "aws" {
access_key = "{INSERT_HERE}"
secret_key = "{INSERT_HERE}"
region = "us-west-2"
}
</pre>

Hint: If you use the AWS cmd line tools you can look at `~/.aws/credentials`.

Next you need to fetch the modules this depends on `terraform get`

Finally you can run this with `terraform apply`
