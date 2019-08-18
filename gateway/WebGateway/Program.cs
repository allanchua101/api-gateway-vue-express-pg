using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Ocelot.Middleware;
using Ocelot.DependencyInjection;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Http;
using System.Diagnostics;

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
                app.UseOcelot(new OcelotPipelineConfiguration()
                {
                    PreErrorResponderMiddleware = async (ctx, next) =>
                    {
                        if (ctx.HttpContext.Request.Path.Equals(new PathString("/healthcheck")))
                        {
                            await ctx.HttpContext.Response.WriteAsync("API Gateway is OK");
                        }
                        else
                        {
                            await next.Invoke();
                        }
                    }
                }).Wait();
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
