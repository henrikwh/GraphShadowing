using Microsoft.Azure.Functions.Worker;
using Microsoft.Azure.Functions.Worker.Http;
using Microsoft.DurableTask.Client;
using Microsoft.DurableTask.Entities;
using Microsoft.Extensions.Logging;
using ShadowFunctions.DurableEntities;
using System.Net;

namespace ShadowFunctions.Triggers
{
    public static class FunctionHttpTriggers
    {
        [Function("ManageTenants")]
        public static async Task<HttpResponseData> HttpStart(
            [DurableClient] DurableTaskClient client,
            [HttpTrigger(AuthorizationLevel.Function, "get", "post", Route = "orchestrators/manage/{tenantId}/{action}")] HttpRequestData req,
            FunctionContext executionContext, Guid tenantId, string action)
        {
            ILogger logger = executionContext.GetLogger("Function_HttpStart");

            switch (action.ToLowerInvariant())
            {
                case "addtenant":
                    var entityid = new EntityInstanceId(nameof(TenantListEntity), Helpers.TenantRepository);
                    await client.Entities.SignalEntityAsync(entityid, "Add", new Tenant(tenantId));
                    break;
                case "removetenant":
                    entityid = new EntityInstanceId(nameof(TenantListEntity), Helpers.TenantRepository);
                    await client.Entities.SignalEntityAsync(entityid, "Remove", new Tenant(tenantId));
                    break;
                case "update":
                    entityid = new EntityInstanceId(nameof(TenantListEntity), Helpers.ProcessingList);
                    await client.Entities.SignalEntityAsync(entityid, "Add", new Tenant(tenantId));
                    break;
                case "remove":
                    entityid = new EntityInstanceId(nameof(TenantListEntity), Helpers.ProcessingList);
                    await client.Entities.SignalEntityAsync(entityid, "Remove", new Tenant(tenantId));
                    break;

                default:
                    break;
            }
            var response = HttpResponseData.CreateResponse(req);
            response.StatusCode = HttpStatusCode.OK;
            return response;
        }
    }
}
