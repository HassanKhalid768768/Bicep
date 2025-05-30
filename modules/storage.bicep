// Creates a storage account restricted to a specific subnet (via network ACLs)

param storageAccountName string
param location string = resourceGroup().location
param storageAccountKind string = 'StorageV2'
param storageAccountSku string = 'Standard_ZRS'
param storageSubnetId string

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-08-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageAccountSku
  }
  kind: storageAccountKind
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: [
        {
          id: storageSubnetId
          action: 'Allow'
        }
      ]
      defaultAction: 'Deny'  // Blocks access from outside the subnet
    }
  }
}

output storageAccountId string = storageAccount.id
