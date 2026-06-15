# AWS Network IaC

Modular, layered Terraform for a secure private-workload network on AWS.

A single VPC with one public subnet and one private subnet, a NAT Gateway for
outbound access, and a private EC2 instance reachable **only** via AWS SSM
Session Manager (no SSH, no bastion, no public IP).

## Architecture

```
                              Internet
                                 │
                          ┌──────┴──────┐
                          │ Internet GW │
                          └──────┬──────┘
        VPC 10.10.0.0/26         │
 ┌──────────────────────────────────────────────┐
 │  Public tier                                  │
 │  10.10.0.0/27   ┌────────┐                   │
 │                 │ NAT GW │◄──── EIP           │
 │                 └───┬────┘                   │
 │                     │ (0.0.0.0/0)             │
 │  Private tier       ▼                         │
 │  10.10.0.32/27  ┌────────┐                   │
 │                 │  EC2   │  (SSM only)        │
 │                 │t3.micro│                    │
 │                 └────────┘                    │
 └──────────────────────────────────────────────┘
```

| Component        | Detail                                                        |
| ---------------- | ------------------------------------------------------------- |
| VPC              | `10.10.0.0/26`                                                |
| Region           | `ap-southeast-3` (Jakarta)                                    |
| Availability Zones | 2 configured (`az_count`), subnets span 1 AZ per tier       |
| Public subnet    | `10.10.0.0/27` — routes to IGW                                |
| Private subnet   | `10.10.0.32/27` — routes to NAT GW                           |
| Internet Gateway | 1, attached to the VPC                                        |
| NAT Gateway      | 1, in the public subnet, with an Elastic IP                  |
| EC2              | `t3.micro`, private subnet, no public IP, IMDSv2, encrypted  |
| Access           | AWS SSM Session Manager only (no port 22, no bastion)        |

There are **no VPC endpoints** — the EC2 instance reaches the SSM API outbound
through the NAT Gateway.

## Repository layout

```
.
├── README.md
├── modules/                  # Reusable, single-purpose modules
│   ├── vpc/                  # VPC + Internet Gateway
│   ├── subnet/               # One subnet tier + route table + associations
│   ├── nat-gateway/          # Elastic IP + NAT Gateway
│   ├── security-group/       # Egress-only security group
│   ├── ec2/                  # Private EC2 instance (IMDSv2, encrypted)
│   ├── iam-role/             # IAM role + instance profile (SSM)
│   └── s3-bucket/            # Hardened private S3 bucket (module only)
└── env/                      # Deployment layers (separate state each)
    ├── 00-network/           # VPC, subnets, IGW, NAT, route tables
    └── 01-statefull/         # EC2, IAM role/profile, security group
```

Each layer contains: `backend.tf`, `main.tf`, `outputs.tf`, `variables.tf`,
`versions.tf`, plus per-project var files (`acn.tfvars`, `dim.tfvars`).

### How the layers connect

Layers are applied in order. Each writes its own state file and `01-statefull`
reads network outputs from `00-network` via `terraform_remote_state`:

```
00-network ──(vpc_id, private_subnet_ids)──► 01-statefull
```

The `01-statefull` layer reads the `00-network` state from the key
`bootstrap/00-network/terraform.tfstate` in the shared state bucket.

## Prerequisites

1. Terraform `>= 1.5.0` and AWS credentials configured (`aws configure` or
   environment variables / SSO).
2. An **existing** S3 bucket for remote state (`bts-iac-tfstate` by default).
   State locking via DynamoDB is intentionally **not** used.

Create the state bucket once (example):

```bash
aws s3api create-bucket \
  --bucket bts-iac-tfstate \
  --region ap-southeast-3 \
  --create-bucket-configuration LocationConstraint=ap-southeast-3
aws s3api put-bucket-versioning \
  --bucket bts-iac-tfstate \
  --versioning-configuration Status=Enabled
```

## Configuration

Backend blocks cannot use variables, so the `bucket` and `region` values in
each layer's `backend.tf` are hardcoded to `bts-iac-tfstate` /
`ap-southeast-3`. Update these literals if deploying to a different bucket or
region.

Per-project var files (`acn.tfvars`, `dim.tfvars`) set `project`, `environment`,
`region`, VPC/subnet CIDRs, and instance sizing. Pass the appropriate file with
`-var-file` at plan/apply time.

## Usage

Apply the layers in order, selecting the target project var file:

```bash
# 1) Network foundation
cd env/00-network
terraform init
terraform plan -var-file=acn.tfvars
terraform apply -var-file=acn.tfvars

# 2) Compute (EC2 + IAM role + security group)
cd ../01-statefull
terraform init
terraform apply -var-file=acn.tfvars
```

Replace `acn.tfvars` with `dim.tfvars` for the DIM project deployment.

Destroy in reverse order (`01-statefull` → `00-network`):

```bash
cd env/01-statefull && terraform destroy -var-file=acn.tfvars
cd ../00-network    && terraform destroy -var-file=acn.tfvars
```

## Connecting to the instance

There is no SSH key, no open port 22, and no public IP. Connect via Session
Manager (requires the AWS CLI + Session Manager plugin):

```bash
# Instance ID is an output of the 01-statefull layer
aws ssm start-session --target <instance-id>
```

## Outputs

### 00-network

| Output                  | Description                              |
| ----------------------- | ---------------------------------------- |
| `vpc_id`                | VPC ID                                   |
| `vpc_name`              | VPC Name tag                             |
| `vpc_cidr_block`        | VPC CIDR block                           |
| `internet_gateway_id`   | Internet Gateway ID                      |
| `internet_gateway_name` | Internet Gateway Name tag                |
| `public_subnet_ids`     | List of public subnet IDs                |
| `public_subnet_names`   | List of public subnet Name tags          |
| `private_subnet_ids`    | List of private subnet IDs               |
| `private_subnet_names`  | List of private subnet Name tags         |
| `public_route_table_id` | Public route table ID                    |
| `public_route_table_name` | Public route table Name tag            |
| `private_route_table_id` | Private route table ID                  |
| `private_route_table_name` | Private route table Name tag          |
| `nat_gateway_id`        | NAT Gateway ID                           |
| `nat_gateway_name`      | NAT Gateway Name tag                     |
| `nat_eip_public_ip`     | Public Elastic IP of the NAT Gateway     |
| `nat_eip_name`          | NAT EIP Name tag                         |

### 01-statefull

| Output                  | Description                              |
| ----------------------- | ---------------------------------------- |
| `instance_id`           | EC2 instance ID                          |
| `instance_name`         | EC2 instance Name tag                    |
| `instance_private_ip`   | Private IP of the EC2 instance           |
| `iam_role_name`         | EC2 IAM role name                        |
| `iam_role_arn`          | EC2 IAM role ARN                         |
| `instance_profile_name` | EC2 instance profile name                |
| `security_group_id`     | Security group ID                        |
| `security_group_name`   | Security group Name tag                  |

## Security highlights

- **No public EC2** — `associate_public_ip_address = false`, private subnet only.
- **No SSH / no port 22** — the security group has zero inbound rules; access is
  exclusively through SSM Session Manager.
- **Least-privilege IAM** — the role gets `AmazonSSMManagedInstanceCore`; additional
  managed policies can be attached via `managed_policy_arns` in the `iam-role` module.
- **IMDSv2 enforced** on the instance; the root EBS volume is encrypted (gp3).
- **Encrypted remote state** (`encrypt = true`), separated per layer.
- **Hardened S3 module** available (`modules/s3-bucket/`) with public access blocked,
  SSE-S3 enabled, versioning on, ACLs disabled, and a TLS-only bucket policy.
