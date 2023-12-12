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
    siteConfig: {
      connectionStrings: [
        {
          name: 'COSMOSDB'
          connectionString: cosmosDbAccount.listConnectionStrings().connectionStrings[0].connectionString
          type: 'Custom'
        }
      ]
      appSettings: [

        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsights.properties.ConnectionString
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~2'
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

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2022-10-01'={
  location: location
  name: '${appName}-loganalytics'

}
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: '${appName}-insights'
  location: location

  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

resource appInsightAlert 'Microsoft.Insights/scheduledQueryRules@2022-08-01-preview' = {
  name: '${appName}-insights-alert'
  location: location
  properties: {
    description: 'Alert for ${appName}'
    enabled: true
    windowSize: 'PT1M'
    severity: 2
    scopes: [ appInsights.id ]
    evaluationFrequency: 'PT1M'
    criteria: {
      allOf: [
        {
          query: 'traces\r\n| extend customCount = toint(customDimensions["Count"])\r\n| where customCount > 70\r\n| project customCount, message\r\n\r\n'
          timeAggregation: 'Count'
          threshold: 1
          operator: 'GreaterThan'
        }
      ]
    }
    actions: {
      actionGroups: [ actionGroup.id ]
    }
  }
}

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: '${appName}-insight-action-group'
  location: 'eastus2'
  properties: {
    groupShortName: 'action-group'
    enabled: true
    emailReceivers: [
      {
        name: 'email'
        emailAddress: 'sammychinedu2ky@gmail.com'
      }
    ]
  }
}
