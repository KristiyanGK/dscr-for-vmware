<#
Desired State Configuration Resources for VMware

Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

<#
.DESCRIPTION
Compiles a dsc configuration 
Compiles a dsc configuration into an object with the name of the configuration and an array of dsc resources

.EXAMPLE
Compiling a basic configuration

Configuration Test
{
    Import-DscResource -ModuleName MyDscResource

    CustomResource myResource
    {
        Field = "Test field"
        Ensure = "Present"
    }
}

New-VmwDscConfiguration Test will output
[VmwDscConfiguration]@{
    InstanceName = 'Test'
    Nodes = @(
        [VmwDscNode]@{
            InstanceName = 'localhost'
            Resources = @(
                InstanceName = 'myResource'
                ResourceType = 'CustomResource'
                ModuleName = @{
                    ModuleName = 'MyDscResource'
                    RequiredVersion = '1.0.0.0'
                }
                Property = @{
                    Field = "Test field"
                    Ensure = "Present"
                }
            )
        }
    )
}

.PARAMETER ConfigName
Name of the dsc configuration to compile.

.PARAMETER CustomParams
The parameters for the dsc configuration.

.PARAMETER ConfigurationData
Configuration Data for the configuration.
#>
function New-VmwDscConfiguration {
    [CmdletBinding()]
    [OutputType([VmwDscConfiguration])]
    Param (
        [string]
        [Parameter(
        Mandatory   = $true,
        Position    = 0)]
        $ConfigName,            # Name of the Configuration
        
        [Parameter(
        Mandatory   = $false,
        Position    = 1)]
        [Hashtable]
        $CustomParams,          # User defined parameters of the configuration
        
        [Parameter(
        Mandatory   = $false,
        Position    = 2)]
        [HashTable]
        $ConfigurationData      # ConfigurationData for use in the configuration
    )

    $dscCompiler = [DscConfigurationCompiler]::new($ConfigName, $CustomParams, $ConfigurationData)

    $vmwDscConfiguration = $dscCompiler.CompileDscConfiguration()

    $vmwDscConfiguration
}
