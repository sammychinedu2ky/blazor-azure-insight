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



resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: appName
  location: location
  properties: {
    serverFarmId: appServicePlan.id
    siteConfig:{
      connectionStrings: [
          {
            name: 'COSMOSDB'
            connectionString: cosmosDbAccount.listConnectionStrings().connectionStrings[0].connectionString
            type: 'Custom'
          }
          {
            name: 'SWACKY'
            connectionString: 'HELLO MY BRO'
            type: 'Custom'
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

