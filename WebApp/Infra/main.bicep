param appName string 
param location string


resource cosmosDbAccount 'Microsoft.DocumentDB/databaseAccounts@2021-06-15' = {
  name: '${appName}-cosmosdb'
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
      }
    ]
  }
}

resource cosmosDbConnectionString 'Microsoft.Web/sites/config@2021-02-01' = {
  name: '/connectionstrings'
  properties: {
    value: cosmosDbAccount.listKeys()
  }  
}

resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig: {
      appSettings: [
        {
          name: 'COSMOSDB_CONNECTION_STRING'
          value: cosmosDbConnectionString.properties.value.primaryMasterKey
        }
      ]
    }
  }
}

resource appServicePlan 'Microsoft.Web/serverfarms@2021-02-01' = {
  name: '${appName}-plan'
  location: location
  sku: {
    name: 's1'
    tier: 'Standard'
  }
  kind: 'linux'
}

