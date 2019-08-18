using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;

namespace WebGateway.Controllers
{
    [Route("hello")]
    public class HealthCheckController : Controller
    {
        // GET api/values
        [HttpGet]
        public string Get()
        {
            return "OK";
        }
    }
}
