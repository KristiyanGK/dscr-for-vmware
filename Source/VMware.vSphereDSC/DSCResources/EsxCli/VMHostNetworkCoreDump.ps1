<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostNetworkCoreDump : EsxCliBaseDSC {
    VMHostNetworkCoreDump() {
        $this.EsxCliCommand = 'system.coredump.network'
    }

    <#
    .DESCRIPTION

    Specifies whether to enable network coredump.
    #>
    [DscProperty()]
    [nullable[bool]] $Enable

    <#
    .DESCRIPTION

    Specifies the active interface to be used for the network coredump.
    #>
    [DscProperty()]
    [string] $InterfaceName

    <#
    .DESCRIPTION

    Specifies the IP address of the coredump server (IPv4 or IPv6).
    #>
    [DscProperty()]
    [string] $ServerIp

    <#
    .DESCRIPTION

    Specifies the port on which the coredump server is listening.
    #>
    [DscProperty()]
    [nullable[long]] $ServerPort

    [void] Set() {
        try {
            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, ($this.DscResourceName))

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            <#
            The 'Enable' argument of the 'set' method of the command should be passed separately from the other method arguments.
            So if any of the other method arguments is passed, the method of the command should be invoked twice - the first time
            without 'Enable' and the second time only with 'Enable' argument.
            #>
            if ($null -ne $this.Enable) {
                if (![string]::IsNullOrEmpty($this.InterfaceName) -or ![string]::IsNullOrEmpty($this.ServerIp) -or $null -ne $this.ServerPort) {
                    <#
                    The desired 'Enable' value must be set to $null, so that the base class can ignore it when constructing the arguments of the method of the command.
                    The value is stored in a separate variable, so that it can be used when the second invocation of the command method occurs.
                    #>
                    $enableArgumentDesiredValue = $this.Enable
                    $this.Enable = $null

                    $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)

                    # The property value is restored to its initial value.
                    $this.Enable = $enableArgumentDesiredValue

                    # All property values except the desired 'Enable' value should be set to $null, because the command method was invoked with them already and their values are not needed.
                    $this.InterfaceName = $null
                    $this.ServerIp = $null
                    $this.ServerPort = $null

                    $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)
                }
                else {
                    $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)
                }
            }
            else {
                $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName)
            }
        }
        finally {
            $this.DisconnectVIServer()

            $this.WriteLogUtil('Verbose', $this.SetMethodEndMessage, ($this.DscResourceName))
        }
    }

    [bool] Test() {
        try {
            $this.WriteLogUtil('Verbose', $this.TestMethodStartMessage, ($this.DscResourceName))

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

            $result = !$this.ShouldModifyVMHostNetworkCoreDumpConfiguration($esxCliGetMethodResult)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()

            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, ($this.DscResourceName))
        }
    }

    [VMHostNetworkCoreDump] Get() {
        try {
            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, ($this.DscResourceName))

            $this.ConnectVIServer()

            $result = [VMHostNetworkCoreDump]::new()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()

            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, ($this.DscResourceName))
        }
    }

    <#
    .DESCRIPTION

    Checks if the VMHost network coredump configuration should be modified.
    #>
    [bool] ShouldModifyVMHostNetworkCoreDumpConfiguration($esxCliGetMethodResult) {
        $shouldModifyVMHostNetworkCoreDumpConfiguration = @(
            $this.ShouldUpdateDscResourceSetting('Enable', [System.Convert]::ToBoolean($esxCliGetMethodResult.Enabled), $this.Enable),
            $this.ShouldUpdateDscResourceSetting('InterfaceName', [string] $esxCliGetMethodResult.HostVNic, $this.InterfaceName),
            $this.ShouldUpdateDscResourceSetting('ServerIp', [string] $esxCliGetMethodResult.NetworkServerIP, $this.ServerIp),
            $this.ShouldUpdateDscResourceSetting('ServerPort', [long] $esxCliGetMethodResult.NetworkServerPort, $this.ServerPort)
        )

        return ($shouldModifyVMHostNetworkCoreDumpConfiguration -Contains $true)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name

        $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

        $result.Enable = [System.Convert]::ToBoolean($esxCliGetMethodResult.Enabled)
        $result.InterfaceName = $esxCliGetMethodResult.HostVNic
        $result.ServerIp = $esxCliGetMethodResult.NetworkServerIP
        $result.ServerPort = [long] $esxCliGetMethodResult.NetworkServerPort
    }
}
