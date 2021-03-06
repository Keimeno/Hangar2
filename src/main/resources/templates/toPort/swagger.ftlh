@import controllers.sugar.Requests.OreRequest
@import views.html.helper.CSPNonce

@()(implicit messages: Messages, request: OreRequest[_], assetsFinder: AssetsFinder)

@*
Mostly copied from swagger-ui's index file
*@

<#import "/spring.ftl" as spring />
<#import "../utils/hangar.ftlh" as hangar />

<!DOCTYPE html>
<html lang="@messages.lang.language">
    <head>
        <title><@spring.message "general.openapi" /></title>

        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">

        <link rel="icon" href="<@spring.url "images/favicon.ico" />">
        <link rel="stylesheet" type="text/css" href="<@spring.url "lib/swagger-ui/swagger-ui.css" />">

        <style>
            html {
                box-sizing: border-box;
                overflow: -moz-scrollbars-vertical;
                overflow-y: scroll;
            }
            *, *:before, *:after {
                box-sizing: inherit;
            }
            body {
                margin:0;
                background: #fafafa;
            }

            .swagger-ui .topbar .download-url-wrapper, .swagger-ui .info hgroup.main a {
                display: none;
            }
            .swagger-ui .info {
                margin: 2rem 0;
            }
            .model-container, .responses-inner {
                overflow-x: auto;
            }
            .swagger-ui .info .description h2 {
                padding-top: 1.5rem;
                margin: 1.5rem 0 0;
                border-top: 3px solid #333333;
            }
            .swagger-ui .scheme-container {
                border-top: 1px solid rgba(0,0,0,.15);
            }
        </style>
    </head>
    <body>
        <div id="swagger-ui"></div>

        <script type="text/javascript" src="<@spring.url "lib/jquery/dist/jquery.min.js" />"></script>
        <script src="<@spring.url "lib/swagger-ui/swagger-ui-bundle.js" />"></script>
        <script src="<@spring.url "lib/swagger-ui/swagger-ui-standalone-preset.js" />"></script>
        <script src="<@spring.url "javascripts/apiRequests.js" />"></script>
        <script @CSPNonce.attr>
                window.onload = () => {
                    window.ui = SwaggerUIBundle({
                        url: "<@spring.url "swagger.json" />",
                        dom_id: '#swagger-ui',
                        deepLinking: true,
                        presets: [
                            SwaggerUIBundle.presets.apis,
                            SwaggerUIStandalonePreset
                        ],
                        plugins: [
                            SwaggerUIBundle.plugins.DownloadUrl
                        ],
                        layout: "StandaloneLayout",
                        requestInterceptor: (req) => {
                            if (!req.loadSpec) {
                                const promise = getApiSession().then((session) => {
                                    req.headers.authorization = 'HangarApi session=' + session;
                                    return req;
                                });
                                // Workaround for fixing the curl URL
                                // https://github.com/swagger-api/swagger-ui/issues/4778#issuecomment-456403631
                                promise.url = req.url;
                                return promise;
                            } else {
                                return req;
                            }
                        }
                    })
                }
            </script>
            @if(request != null) {
                <script @CSPNonce.attr>
                        csrf = '@play.filters.csrf.CSRF.getToken.get.value';
                        isLoggedIn = @request.hasUser;
                </script>
            }
    </body>
</html>
