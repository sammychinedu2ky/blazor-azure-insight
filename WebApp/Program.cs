using Azure.Data.Tables;
using Microsoft.Extensions.Options;
using WebApp.Components;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveServerComponents();
builder.Services.Configure<DataBaseOptions>(builder.Configuration.GetSection(DataBaseOptions.ConnectionString));
builder.Services.AddSingleton<TableClient>(sp =>
{
    var options = sp.GetRequiredService<IOptions<DataBaseOptions>>();
    var connectionString = options.Value.COSMOSDB;
    var tableName = "Raffle";
    var client = new TableClient(connectionString, tableName);
    return client;
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

public class DataBaseOptions
{
    public const string ConnectionString  = "ConnectionStrings";
    public string COSMOSDB { get; set; } = String.Empty;
}
