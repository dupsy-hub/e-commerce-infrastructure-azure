# Teleios E-commerce – Azure Terraform Infrastructure

## 1. Overview

This project provisions the complete cloud infrastructure for the **Teleios E-commerce Platform** on **Microsoft Azure**, using **Terraform** as Infrastructure as Code (IaC).

The infrastructure follows a **modular design** with two repositories:

- **Modules Repository** → Reusable Terraform code for specific Azure resources.
- **Implementation Repository** → Environment-specific composition that calls the modules with actual inputs.

This separation ensures **reusability**, **maintainability**, and **team collaboration** without breaking core modules when making environment changes.

---

## 2. Architecture Summary

### Network Foundation

- **Azure Virtual Network (VNet)** — central private network for all components.
- **Subnets**:
  - `web-subnet`: Application Gateway + frontend components.
  - `api-subnet`: VM Scale Sets and/or Container Apps.
  - `data-subnet`: Databases, Storage, Redis (via private endpoints).
  - `gateway-subnet`: NAT Gateway for outbound traffic.
- **Network Security Groups (NSGs)**: Apply tier-specific inbound/outbound rules.
- **NAT Gateway**: Secure outbound internet for private subnets.

### Ingress & Load Balancing

- **Azure Application Gateway (WAF_v2)**:
  - Routes `/` to App Service (frontend).
  - Routes `/api/*` to VMSS backend (API).
  - SSL termination + health probes.

### Application Layer

- **App Service**:
  - Hosts the main web application.
  - Autoscaling based on CPU.
  - Application Insights enabled.
- **Azure Container Apps**:
  - Runs microservices (e.g., payment, inventory).
  - Defined CPU/memory per container.
- **Azure Virtual Machine Scale Sets (VMSS)**:
  - Scalable backend API servers.
  - Integrated with Application Gateway backend pool.

### Data Layer

- **Azure SQL Database**: Relational DB for core application data.
- **Azure Cosmos DB (SQL API)**: NoSQL for product catalog, carts, sessions.
- **Azure Storage Account**: Blobs for product images, uploads, static assets.
- **Azure Redis Cache**: Caching for performance and sessions.

### Security

- **Managed Identities + RBAC** for secure service-to-service auth (no secrets).
- **Private Endpoints** for data services.
- **NSG rules** restricting cross-tier traffic (web → api → data).

### Observability

- **Application Insights** for App Service.
- **Platform logs/metrics** for all resources.

---

## 3. How It All Comes Together

1. **Networking** is deployed first (VNet, subnets, NSGs, NAT Gateway).
2. **Ingress** layer (Application Gateway) is configured and connected to the network.
3. **Application Layer** (App Service, Container Apps, VMSS) is deployed and linked to Application Gateway backend pools.
4. **Data Layer** (SQL, Cosmos DB, Storage, Redis) is provisioned with private connectivity and secure access.
5. **Security & Monitoring** are configured to ensure only allowed flows and to enable observability.

**Final flow:**  
`Internet → Application Gateway → (App Service | VMSS) → Databases / Storage / Redis`

---

## 4. Architecture Routing

**Routing summary:** Internet → Application Gateway → ( `/` → App Service, `/api/*` → VMSS ). Backend services consume data services via private endpoints inside the VNet. NAT Gateway provides controlled outbound internet for private subnets.

---

## 5. Repository Structure

### A) Modules Repository

Reusable Terraform modules for each Azure resource.

```
modules-repo/
├─ vnet/
│  ├─ main.tf
│  ├─ variables.tf
│  ├─ outputs.tf
│  └─ versions.tf
├─ app-gateway/
├─ vmss-windows/
├─ container-apps/
├─ sql/
├─ cosmos-db/
├─ storage/
└─ redis/
```

**Guidelines:**

- No hardcoded environment values — use variables.
- Outputs expose IDs/names needed by other modules.
- Keep modules small, cohesive, and versioned (e.g., via tags).

### B) Implementation Repository

Environment-specific composition that calls modules and provides inputs.

```
implementation-repo/
├─ envs/
│  ├─ dev/
│  │  ├─ main.tf           # Calls modules with dev-specific vars
│  │  ├─ variables.tf
│  │  ├─ outputs.tf
│  │  └─ dev.auto.tfvars   # Inputs for dev (no secrets)
│  └─ prod/
│     ├─ main.tf
│     ├─ variables.tf
│     ├─ outputs.tf
│     └─ prod.auto.tfvars
├─ global/
│  ├─ versions.tf          # Providers and required versions
│  └─ backend.tf           # Terraform Cloud/remote backend (recommended)
└─ .github/workflows/      # Optional CI/CD pipelines
   └─ terraform.yml
```

**Guidelines:**

- Sensitive values (passwords, keys) should never be committed to source control.
  If running plans/applies from your CLI → store secrets in a local .env file (ignored by Git) and load them with source .env.
  If Terraform Cloud runs your plans → store them there as sensitive variables.

- Each environment folder composes multiple modules to create the full stack.

- OIDC authentication is only needed if your Terraform execution happens in CI/CD (e.g., GitHub Actions) and needs
  to access Azure or Terraform Cloud without long-lived credentials.
  - For local CLI runs, simply use az login with the Azure CLI and set the correct subscription.

---

## 6. Naming & Tagging Standards

**Resource Group:** `teleios-ecommerce-{environment}`  
**Region:** `West Europe` (or as set in variables)  
**Resource Naming:** `teleios-{resource-type}-{environment}`

**Mandatory tags (on all resources):**

```hcl
tags = {
  Project     = "Teleios-Ecommerce"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "TeleiosTeam"
}
```

> Adjust `Environment` per workspace (e.g., `dev`, `prod`).

---

## 7. Example: Environment Composition (dev)

> Minimal example showing how the implementation repo composes modules.

```hcl
module "vnet" {
  source              = "../modules-repo/vnet"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

module "app_gateway" {
  source              = "../modules-repo/app-gateway"
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = module.vnet.subnet_ids["web-subnet"]
  backend_pool_name   = var.backend_pool_name
  tags                = var.tags
}

locals {
  # Example of injecting dynamic values into a VMSS config
  merged_vmss_config = {
    for k, cfg in var.vmss_config :
    k => merge(cfg, {
      subnet_id       = module.vnet.subnet_ids["api-subnet"]
      backend_pool_id = module.app_gateway.vmss_backend_pool_id
      # admin_password injected from Terraform Cloud sensitive var map
      admin_password  = var.admin_passwords[k]
    })
  }
}

module "vmss" {
  source              = "../modules-repo/vmss-windows"
  resource_group_name = var.resource_group_name
  location            = var.location
  vmss_config         = local.merged_vmss_config
  tags                = var.tags
}

module "cosmos" {
  source              = "../modules-repo/cosmos-db"
  resource_group_name = var.resource_group_name
  location            = var.location
  account_configs     = var.account_configs
  tags                = var.tags
}
```

**`dev.auto.tfvars` (example):**

```hcl
location            = "westeurope"
resource_group_name = "teleios-ecommerce-dev-rg"

environment = "dev"
tags = {
  Project     = "Teleios-Ecommerce"
  Environment = "dev"
  ManagedBy   = "Terraform"
  Owner       = "TeleiosTeam"
}

backend_pool_name = "backend-pool"

vmss_config = {
  api = {
    vmss_name                    = "teleios-vmss-dev"
    vm_size                      = "Standard_B2s"
    instance_count               = 2
    admin_username               = "teleios"
    image_publisher              = "MicrosoftWindowsServer"
    image_offer                  = "WindowsServer"
    image_sku                    = "2019-Datacenter"
    image_version                = "latest"
    os_disk_caching              = "ReadWrite"
    os_disk_storage_account_type = "Standard_LRS"
    upgrade_mode                 = "Manual"
    nic_name                     = "nic"
    ip_config_name               = "ipconfig"
  }
}

# DO NOT commit real secrets; store these in Terraform Cloud as sensitive vars
# admin_passwords = { api = "*****" }
```

---

## 8. Deployment Steps

### Authenticate

- **Local:** `az login` (Azure CLI) or use a Service Principal.
- **Terraform Cloud:** Configure AzureRM via OIDC or a Service Principal.

### Init & Apply

```bash
cd envs/dev
terraform init
terraform plan -var-file="dev.auto.tfvars"
terraform apply -var-file="dev.auto.tfvars"
```

### Validate

- Confirm Application Gateway health probes are **Healthy**.
- Confirm NSG rules and Private Endpoints permit expected flows.
- Access the web app via the App Gateway public IP / DNS.

---

## 9. Success Criteria

- All resources deployed in the correct resource group, region, and subnets.
- End-to-end connectivity: Internet → Application Gateway → App Service/VMSS → Databases.
- NSG and firewall rules enforced; least-privilege access via RBAC.
- Monitoring and logging enabled.
- Application runs successfully in a production-like environment.

---

## 10. Notes & Best Practices

- Keep **global variables** (`resource_group_name`, `location`, `environment`, `tags`) in the implementation repo; modules consume them.
- Use **maps** for multi-instance resources (e.g., `vmss_config`, `account_configs`).
- Prefer **Managed Identity** over connection strings for service auth.
- Use **Private Endpoints** + Private DNS Zones for data plane access.
