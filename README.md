
# 🚀 Azure Bicep Deployment with GitHub Actions

This project uses **Bicep** and **GitHub Actions** to deploy a full Azure infrastructure including VNets, VMs, storage accounts, and monitoring—all through a single pipeline.

---

## 📌 Prerequisites

Before you begin, ensure you have the following:

### 1. ✅ Resource Group  
Create a resource group in your subscription:
```bash
az group create --name myResourceGroup --location eastus
```

### 2. 📁 GitHub Repository  
Fork or create a GitHub repo containing:

```
├── main.bicep
├── .github/workflows/deploy.yml
└── modules/
    ├── vnet.bicep
    ├── peerVnets.bicep
    ├── vm.bicep
    ├── storage.bicep
    └── monitor.bicep
```
> Ensure `main` is your default branch.

### 3. 🔐 GitHub Secrets  
In **Repository Settings → Secrets and variables → Actions**, add the following:

- **`AZURE_CREDENTIALS`**  
  JSON output from:
  ```bash
  az ad sp create-for-rbac --sdk-auth --role="Contributor"
  ```

- **`ADMIN_PASSWORD`**  
  A strong admin password (≥12 characters) for the VM login.

---

## 🚀 Deploy via GitHub Actions

The workflow located at `.github/workflows/deploy.yml` automates the full deployment:

### ✅ Steps:

1. **Push to `main`**  
   Any push to `main` triggers the workflow.

2. **Checkout & Authenticate**  
   GitHub runner checks out the repo and authenticates using the `AZURE_CREDENTIALS` secret.

3. **Deploy to Azure**  
   The workflow uses the [`azure/arm-deploy@v1`](https://github.com/marketplace/actions/arm-deploy) action to deploy `main.bicep` to:
   - **Resource Group:** `myResourceGroup`  
   - **Region:** `eastus`

4. **Monitor Deployment**  
   Check the **Actions** tab in GitHub to monitor deployment progress.

> 💡 **To change the target resource group or location**, edit the `resourceGroupName` and `region` fields in `deploy.yml`.

---

## 🧱 Modules Overview

Each module under `modules/` has a specific responsibility:

| Module            | Description                                              |
|-------------------|----------------------------------------------------------|
| `vnet.bicep`      | Creates a VNet with two subnets: `infra` and `storage`. |
| `peerVnets.bicep` | Sets up VNet peering between two VNets.                 |
| `vm.bicep`        | Deploys a Windows VM inside the `infra` subnet.         |
| `storage.bicep`   | Creates a ZRS Storage Account locked to the `storage` subnet. |
| `monitor.bicep`   | Enables diagnostic settings on Azure resources.         |

---

Happy deploying! ✨  
Feel free to fork and customize based on your needs.
