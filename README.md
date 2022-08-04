# libgdiplus packaging for Linux

This repository contains scripts which distribute libgdiplus and its dependencies for Linux as a NuGet package. This may simplify
the deployment of .NET code which uses System.Drawing.Common for Linux environments.

To use this NuGet package, add a reference to the [ereno.linux-x64.eugeneereno.System.Drawing](https://www.nuget.org/packages/ereno.linux-x64.eugeneereno.System.Drawing):

```
dotnet add package ereno.linux-x64.eugeneereno.System.Drawing
```s
