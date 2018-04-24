﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http.Headers;
using System.Web.Http;

namespace TestDemo
{
    public static class WebApiConfig
    {
        public static void Register(HttpConfiguration config)
        {

            // New code
            config.EnableCors();
            // Web API configuration and services
            config.Formatters.JsonFormatter.SupportedMediaTypes
           .Add(new MediaTypeHeaderValue("text/html"));   

            // Web API routes
            config.MapHttpAttributeRoutes();

            config.Routes.MapHttpRoute(
                name: "DefaultApi",
                routeTemplate: "api/{controller}/{id}",
                defaults: new { id = RouteParameter.Optional }
            );
        }
    }
}
