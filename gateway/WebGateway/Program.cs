using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Ocelot.Middleware;
using Ocelot.DependencyInjection;
using Microsoft.AspNetCore.Builder;

namespace WebGateway
{
  public class Program
  {
    public static void Main(string[] args)
    {
      BuildWebHost(args).Run();
    }

    public static IWebHost BuildWebHost(string[] args)
    {
      return WebHost.CreateDefaultBuilder(args)
              .UseKestrel(options =>
              {
                // Set properties and call methods on options
              })
              .UseUrls("http://0.0.0.0:80")
              .UseStartup<Startup>()
              .ConfigureAppConfiguration((hostingContext, config) =>
              {
                config.AddJsonFile("ocelot.json")
                            .AddEnvironmentVariables();
              })
              .ConfigureServices(s =>
              {
                s.AddOcelot();
              })
              .Configure(app =>
              {
                app.UseStaticFiles();
                app.UseOcelot().Wait();
              })
              .ConfigureLogging((hostingContext, logging) =>
              {
                logging.AddConsole();
                logging.AddDebug();
                logging.AddEventSourceLogger();
              })
              .UseIISIntegration()
              .Build();
    }
  }
}
