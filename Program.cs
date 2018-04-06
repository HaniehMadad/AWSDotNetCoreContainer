using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace corehelloworld
{
    public class Program
    {
        public static void Main(string[] args)
        {
            ILoggerFactory loggerFactory = new LoggerFactory()
                .AddFile("Logs/mylog-{Date}.txt");
            ILogger logger = loggerFactory.CreateLogger<Program>();
            logger.LogInformation("This is a test of DotnetCoreHelloWorld app.");
            logger.LogWarning("This is to test warning");
            BuildWebHost(args).Run();
                        
        }

        public static IWebHost BuildWebHost(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                    .UseStartup<Startup>()
                    .Build();
    }
}
