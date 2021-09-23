using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Azure.Storage.Blobs;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace Chestist.Imaging.Api
{
    public static class GetPatientImage
    {
        static string _connectionString = Environment.GetEnvironmentVariable("ImageStoreConnectionString");
        static string _containerName = Environment.GetEnvironmentVariable("ContainerName");

        [FunctionName("GetPatientImage")]
        public static async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", Route = "image/{name}")] HttpRequest req,
            string name,
            ILogger log)
        {
            var client = new BlobClient(_connectionString, _containerName, name);
            var stream = await client.DownloadContentAsync();
            Byte[] b = stream.Value.Content.ToArray();

            var result = new FileContentResult(b, "image/png");
            return result;
        }

    }
}
