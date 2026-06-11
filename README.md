# AWS Network IaC

Modular, layered Terraform for a secure private-workload network on AWS.

A single VPC across two Availability Zones with three subnet tiers (public,
private, data), a NAT Gateway for outbound access, a private EC2 instance reached
**only** via AWS SSM Session Manager (no SSH, no bastion, no public IP), and an
S3 bucket the instance accesses through a least-privilege IAM role.

## Architecture

```
                              Internet
                                 │
                          ┌──────┴──────┐
                          │ Internet GW │
                          └──────┬──────┘
        VPC 10.0.0.0/16          │
 ┌───────────────────────────────────────────────────────────┐
 │  Public tier            AZ a                AZ b            │
 │  10.0.1.0/24 ┌────────┐   10.0.2.0/24 ┌────────┐           │
 │              │ NAT GW │◄──── EIP      │        │           │
 │              └───┬────┘               └────────┘           │
 │                  │ (0.0.0.0/0)                              │
 │  Private tier    ▼                                          │
 │  10.0.11.0/24 ┌────────┐  10.0.12.0/24 ┌────────┐          │
 │               │  EC2   │                │        │          │
 │               │t2.micro│  (SSM only)    └────────┘          │
 │               └───┬────┘                                    │
 │                   │ IAM role (SSM + S3)                     │
 │  Data tier        │  (isolated: no internet route)          │
 │  10.0.21.0/24 ┌───▼────┐  10.0.22.0/24 ┌────────┐          │
 │               │  (rsv) │                │  (rsv) │          │
 │               └────────┘                └────────┘          │
 └───────────────────────────────────────────────────────────┘
                   │
                   ▼  (via NAT → public internet → AWS S3 API)
            ┌──────────────┐
            │  S3 bucket   │  public access blocked, encrypted, versioned
            └──────────────┘
```

| Component        | Detail                                                        |
| ---------------- | ------------------------------------------------------------- |
| VPC              | `10.0.0.0/16`                                                 |
| Availability Zones | 2 (auto-selected from the target region)                    |
| Public subnets   | `10.0.1.0/24`, `10.0.2.0/24` — route to IGW                   |
| Private subnets  | `10.0.11.0/24`, `10.0.12.0/24` — route to NAT GW             |
| Data subnets     | `10.0.21.0/24`, `10.0.22.0/24` — isolated, local-only        |
| Internet Gateway | 1, attached to the VPC                                         |
| NAT Gateway      | 1, in the first public subnet, with an Elastic IP            |
| EC2              | `t2.micro`, private subnet, no public IP, IMDSv2, encrypted   |
| Access           | AWS SSM Session Manager only (no port 22, no bastion)         |
| S3               | private bucket, accessed by EC2 via IAM role                  |

There are **no VPC endpoints** — the EC2 instance reaches the SSM and S3 APIs
outbound through the NAT Gateway.

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
│   └── s3-bucket/            # Hardened private S3 bucket
└── layers/                   # Deployment layers (separate state each)
    ├── 00-network/           # VPC, subnets, IGW, NAT, route tables
    ├── 01-backend/           # EC2, IAM role/profile, security group
    └── 02-data/              # S3 bucket + least-privilege S3 IAM policy
```

Each layer contains the same six files: `backend.tf`, `main.tf`, `outputs.tf`,
`terraform.tfvars`, `variables.tf`, `versions.tf`.

### How the layers connect

Layers are applied in order. Each writes its own state file and later layers
read earlier outputs via `terraform_remote_state`:

```
00-network ──(vpc_id, private_subnet_ids)──► 01-backend ──(iam_role_name)──► 02-data
```

This ordering also resolves the role/bucket dependency cleanly: `01-backend`
creates the IAM role (with SSM permissions), and `02-data` creates the bucket
and attaches a least-privilege S3 policy to that existing role.

## Prerequisites

1. Terraform `>= 1.5.0` and AWS credentials configured (`aws configure` or
   environment variables / SSO).
2. An **existing** S3 bucket for remote state. State locking via DynamoDB is
   intentionally **not** used.

Create the state bucket once (example):

```bash
aws s3api create-bucket \
  --bucket aws-network-iac-tfstate-changeme \
  --region us-east-1
aws s3api put-bucket-versioning \
  --bucket aws-network-iac-tfstate-changeme \
  --versioning-configuration Status=Enabled
```

## Configuration

Backend blocks cannot use variables, so update the literal `bucket`/`region`
in each layer's `backend.tf` to match your state bucket. Then align the
`state_bucket` and `region` values in `01-backend` and `02-data`
`terraform.tfvars` so remote-state reads point at the same place.

Defaults (region `us-east-1`, the CIDRs above, `t2.micro`) live in each layer's
`variables.tf` / `terraform.tfvars` and can be overridden as needed.

## Usage

Apply the layers in order:

```bash
# 1) Network foundation
cd layers/00-network
terraform init
terraform plan
terraform apply

# 2) Backend compute (EC2 + IAM + SG)
cd ../01-backend
terraform init
terraform apply

# 3) Data (S3 bucket + S3 IAM policy on the EC2 role)
cd ../02-data
terraform init
terraform apply
```

Destroy in reverse order (`02-data` → `01-backend` → `00-network`).

## Connecting to the instance

There is no SSH key, no open port 22, and no public IP. Connect via Session
Manager (requires the AWS CLI + Session Manager plugin):

```bash
# Instance ID is an output of the 01-backend layer
aws ssm start-session --target <instance-id>
```

From inside the session you can verify S3 access, e.g.:

```bash
aws s3 ls s3://<bucket-id-from-02-data-output>/
```

## Security highlights

- **No public EC2** — `associate_public_ip_address = false`, private subnet only.
- **No SSH / no port 22** — the security group has zero inbound rules; access is
  exclusively through SSM Session Manager.
- **Least-privilege IAM** — the role gets `AmazonSSMManagedInstanceCore` plus a
  scoped policy limited to the single data bucket (list + object CRUD).
- **IMDSv2 enforced** on the instance; the root EBS volume is encrypted.
- **Subnet isolation** — the data tier has no route to the internet; private
  egress is via NAT only.
- **Hardened S3** — all public access blocked, SSE enabled, versioning on,
  ACLs disabled, and a bucket policy that denies non-TLS requests.
- **Encrypted remote state** (`encrypt = true`), separated per layer.
```
