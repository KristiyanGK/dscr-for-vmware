<#
Copyright (c) 2018-2020 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

$script:moduleRoot = (Get-Item -Path $PSScriptRoot).Parent.Parent.FullName
. "$script:moduleRoot/VMware.vSphereDSC.CompositeResourcesHelper.ps1"

Configuration StandardSwitch {
    Param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $VMHostName,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Name,

        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Present', 'Absent')]
        [string]
        $Ensure,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Server,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $false)]
        [nullable[int]]
        $Mtu,

        [Parameter(Mandatory = $false)]
        [string[]]
        $NicDevice,

        [Parameter(Mandatory = $false)]
        [nullable[int]]
        $BeaconInterval,

        [Parameter(Mandatory = $false)]
        [ValidateSet('CDP', 'Unset')]
        [string]
        $LinkDiscoveryProtocolType = 'Unset',

        [Parameter(Mandatory = $false)]
        [ValidateSet('Advertise', 'Both', 'Listen', 'None', 'Unset')]
        [string]
        $LinkDiscoveryProtocolOperation = 'Unset',

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $AllowPromiscuous,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $ForgedTransmits,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $MacChanges,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $Enabled,

        [Parameter(Mandatory = $false)]
        [nullable[long]]
        $AverageBandwidth,

        [Parameter(Mandatory = $false)]
        [nullable[long]]
        $PeakBandwidth,

        [Parameter(Mandatory = $false)]
        [nullable[long]]
        $BurstSize,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $CheckBeacon,

        [Parameter(Mandatory = $false)]
        [string[]]
        $ActiveNic,

        [Parameter(Mandatory = $false)]
        [string[]]
        $StandbyNic,

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $NotifySwitches,

        [Parameter(Mandatory = $false)]
        [ValidateSet('Loadbalance_ip', 'Loadbalance_srcmac', 'Loadbalance_srcid', 'Failover_explicit', 'Unset')]
        [string]
        $Policy = 'Unset',

        [Parameter(Mandatory = $false)]
        [nullable[bool]]
        $RollingOrder
    )

    Import-DscResource -ModuleName VMware.vSphereDSC

    # Constructs VMHostVss Resource Block.
    $nullableVMHostVssProperties = @{
        Server = $Server
        Credential = $Credential
        Mtu = $Mtu
    }
    $vmHostVssProperties = @{
        Name = $VMHostName
        VssName = $Name
        Ensure = $Ensure
    }

    Push-NullablePropertiesToDscResourceBlock -ResourceBlockProperties $vmHostVssProperties -NullableProperties $nullableVMHostVssProperties
    $dscResourceBlock = New-DscResourceBlock -ResourceName 'VMHostVss' -Properties $vmHostVssProperties
    $dscResourceBlock.Invoke($vmHostVssProperties)

    # Constructs VMHostVssBridge Resource Block.
    $nullableVMHostVssBridgeProperties = @{
        Server = $Server
        Credential = $Credential
        BeaconInterval = $BeaconInterval
    }
    $vmHostVssBridgeProperties = @{
        Name = $VMHostName
        VssName = $Name
        Ensure = $Ensure
        NicDevice = $NicDevice
        LinkDiscoveryProtocolProtocol = $LinkDiscoveryProtocolType
        LinkDiscoveryProtocolOperation = $LinkDiscoveryProtocolOperation
        DependsOn = "[VMHostVss]VMHostVss"
    }

    Push-NullablePropertiesToDscResourceBlock -ResourceBlockProperties $vmHostVssBridgeProperties -NullableProperties $nullableVMHostVssBridgeProperties
    $dscResourceBlock = New-DscResourceBlock -ResourceName 'VMHostVssBridge' -Properties $vmHostVssBridgeProperties
    $dscResourceBlock.Invoke($vmHostVssBridgeProperties)

    # Constructs VMHostVssShaping Resource Block.
    $nullableVMHostVssShapingProperties = @{
        Server = $Server
        Credential = $Credential
        Enabled = $Enabled
        AverageBandwidth = $AverageBandwidth
        PeakBandwidth = $PeakBandwidth
        BurstSize = $BurstSize
    }
    $vmHostVssShapingProperties = @{
        Name = $VMHostName
        VssName = $Name
        Ensure = $Ensure
        DependsOn = "[VMHostVss]VMHostVss"
    }

    Push-NullablePropertiesToDscResourceBlock -ResourceBlockProperties $vmHostVssShapingProperties -NullableProperties $nullableVMHostVssShapingProperties
    $dscResourceBlock = New-DscResourceBlock -ResourceName 'VMHostVssShaping' -Properties $vmHostVssShapingProperties
    $dscResourceBlock.Invoke($vmHostVssShapingProperties)

    # Constructs VMHostVssSecurity Resource Block.
    $nullableVMHostVssSecurityProperties = @{
        Server = $Server
        Credential = $Credential
        AllowPromiscuous = $AllowPromiscuous
        ForgedTransmits = $ForgedTransmits
        MacChanges = $MacChanges
    }
    $vmHostVssSecurityProperties = @{
        Name = $VMHostName
        VssName = $Name
        Ensure = $Ensure
        DependsOn = "[VMHostVss]VMHostVss"
    }

    Push-NullablePropertiesToDscResourceBlock -ResourceBlockProperties $vmHostVssSecurityProperties -NullableProperties $nullableVMHostVssSecurityProperties
    $dscResourceBlock = New-DscResourceBlock -ResourceName 'VMHostVssSecurity' -Properties $vmHostVssSecurityProperties
    $dscResourceBlock.Invoke($vmHostVssSecurityProperties)

    # Constructs VMHostVssTeaming Resource Block.
    $nullableVMHostVssTeamingProperties = @{
        Server = $Server
        Credential = $Credential
        CheckBeacon = $CheckBeacon
        NotifySwitches = $NotifySwitches
        RollingOrder = $RollingOrder
    }
    $vmHostVssTeamingProperties = @{
        Name = $VMHostName
        VssName = $Name
        Ensure = $Ensure
        ActiveNic = $ActiveNic
        StandbyNic = $StandbyNic
        Policy = $Policy
        DependsOn = "[VMHostVss]VMHostVss"
    }

    Push-NullablePropertiesToDscResourceBlock -ResourceBlockProperties $vmHostVssTeamingProperties -NullableProperties $nullableVMHostVssTeamingProperties
    $dscResourceBlock = New-DscResourceBlock -ResourceName 'VMHostVssTeaming' -Properties $vmHostVssTeamingProperties
    $dscResourceBlock.Invoke($vmHostVssTeamingProperties)
}
