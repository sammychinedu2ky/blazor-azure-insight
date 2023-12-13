using Azure.Data.Tables;
using Microsoft.Extensions.Options;
using WebApp.Components;
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();

builder.Services.Configure<ConnectionStrings>(builder.Configuration.GetSection(ConnectionStrings.key));
builder.Services.AddApplicationInsightsTelemetry(option =>
{
    var connectionStringObject = new ConnectionStrings();
    builder.Configuration.GetSection(ConnectionStrings.key).Bind(connectionStringObject);
    option.ConnectionString = connectionStringObject.APPLICATION_INSIGHTS;
});
builder.Services.AddSingleton<TableClient>(sp =>
{
    var options = sp.GetRequiredService<IOptions<ConnectionStrings>>();
    var connectionString = options.Value.COSMOSDB;
    var tableName = "Raffle";
    TableServiceClient tableServiceClient = new TableServiceClient(connectionString);
    TableClient tableClient = tableServiceClient.GetTableClient(tableName);
    tableClient.CreateIfNotExists();
    return tableClient;
});
var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();

app.UseStaticFiles();
app.UseAntiforgery();

app.MapRazorComponents<App>()
    .AddInteractiveServerRenderMode();

app.Run();

public class ConnectionStrings
{
    public const string key = "ConnectionStrings";
    public string COSMOSDB { get; set; } = String.Empty;
    public string APPLICATION_INSIGHTS { get; set; } = String.Empty;
}
