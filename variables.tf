variable "location" {
  type        = string
  description = "The location where the Managed Kubernetes Cluster should be created. Changing this forces a new resource to be created."
}

variable "resource_group_name" {
  type        = string
  description = "Specifies the Resource Group where the Managed Kubernetes Cluster should exist. Changing this forces a new resource to be created."
}

variable "aks_name" {
  type        = string
  default     = "aks-default"
  description = "The name of the Managed Kubernetes Cluster"
}

variable "local_account_disabled" {
  type        = bool
  default     = false
  description = <<-EOT

  If true local accounts will be disabled. Defaults to false.
  When deploying an AKS Cluster, local accounts are enabled by default.
  Even when enabling RBAC or Azure Active Directory integration, --admin access still exists, essentially as a non-auditable backdoor option.
  With this in mind, AKS offers users the ability to disable local accounts via a flag, disable-local-accounts.
  A field, properties.disableLocalAccounts, has also been added to the managed cluster API to indicate whether the feature has been enabled on the cluster.

  See the documentation for more information:  https://docs.microsoft.com/azure/aks/managed-aad#disable-local-accounts"
  EOT
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2ms"
  description = "The size of the Virtual Machine, such as Standard_DS2_v2. Changing this forces a new resource to be created."
}

variable "sku_tier" {
  type        = string
  default     = "Standard"
  description = "The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.28.3"
  description = "Version of Kubernetes specified when creating the AKS managed cluster. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)."
}

variable "node_pool_profile_name" {
  type        = string
  default     = "node"
  description = "The name which should be used for the default Kubernetes Node Pool. Changing this forces a new resource to be created."
}

variable "node_pool_type" {
  type        = string
  default     = "VirtualMachineScaleSets"
  description = "This requires that the type is set to VirtualMachineScaleSets"
}

variable "os_disk_size_gb" {
  type        = string
  default     = "32"
  description = "The size of the OS Disk which should be used for each agent in the Node Pool. Changing this forces a new resource to be created."
}

variable "zones" {
  type        = list(string)
  default     = null
  description = <<-EOT

    The following limitations apply when you create an AKS cluster using availability zones:

    - You can only enable availability zones when the cluster is created.
    - Availability zone settings can't be updated after the cluster is created.
    - You also can't update an existing, non-availability zone cluster to use availability zones.
    - You can't disable availability zones for an AKS cluster once it has been created.
    - The node size (VM SKU) selected must be available across all availability zones.
    - Clusters with availability zones enabled require use of Azure Standard Load Balancers for distribution across zones.
    - You must use Kubernetes version 1.13.5 or greater in order to deploy Standard Load Balancers.

    Disk limitations

    Volumes that use Azure managed disks are currently not zonal resources.
    Pods rescheduled in a different zone from their original zone can't reattach their previous disk(s).
    It's recommended to run stateless workloads that don't require persistent storage that may come across zonal issues.
    If you must run stateful workloads, use taints and toleration's in your pod specs to tell the Kubernetes scheduler to create pods in the same zone as your disks.
    Alternatively, use network-based storage such as Azure Files that can attach to pods as they're scheduled between zones.

    For further details see: https://docs.microsoft.com/en-us/azure/aks/availability-zones
    EOT
}

variable "authorized_ip_ranges" {

  type        = list(string)
  default     = ["0.0.0.0/0"]
  description = <<-EOT
    Set of authorized IP ranges to allow access to API server, e.g. ["198.51.100.0/24"].
    EOT
}

variable "enable_node_public_ip" {
  type        = bool
  default     = false
  description = "Should nodes in this Node Pool have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
}

variable "enable_auto_scaling" {
  type        = bool
  default     = false
  description = "Should the Kubernetes Auto Scaler be enabled for this Node Pool? Defaults to false."
}

variable "node_pool_count" {
  type        = number
  default     = 3
  description = <<-EOT
    If enable_auto_scaling is set to true, this variable:
        - is optional.
        - specifies the initial number of nodes which should exist in the Node Pool.

    If enable_auto_scaling is set to false, this variable:
        - is required.
        - specifies the fixed number of nodes which should exist in the Node Pool.
    EOT
}

variable "node_pool_min_count" {
  type        = number
  default     = 4
  description = <<-EOT
    If enable_auto_scaling is set to true, this variable:
        - is required.
        - specifies the minimum number of nodes which should exist in the Node Pool.

    If enable_auto_scaling is set to false, this variable should not be set.
    EOT
}

variable "node_pool_max_count" {
  type        = number
  default     = 10
  description = <<-EOT
    If enable_auto_scaling is set to true, this variable:
        - is required.
        - specifies the maximum number of nodes which should exist in the Node Pool.

    If enable_auto_scaling is set to false, this variable should not be set.
    EOT
}

variable "node_pool_max_surge" {
  type        = string
  default     = "25%"
  description = "(Required) The maximum number or percentage of nodes which will be added to the Node Pool size during an upgrade."

}

variable "node_dns_prefix" {
  type        = string
  default     = "node"
  description = "DNS prefix specified when creating the managed cluster. Changing this forces a new resource to be created."
}

variable "max_pods_per_node" {
  type        = number
  default     = 30
  description = "The maximum number of pods that can run on each agent. Changing this forces a new resource to be created. The default is set to 30, because the default network-policy is set to azure"
}

variable "node_admin_username" {
  type        = string
  default     = "azureuser"
  description = "The Admin Username for the Cluster. Changing this forces a new resource to be created."
}

variable "node_taints" {
  type    = list(string)
  default = null

  description = <<-EOT
    A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule)
    EOT
}

variable "node_resource_group" {
  type        = string
  default     = null
  description = "By setting this variable you can set the node resource group name for the Kubernetes nodes. This variable was only built in for backwards compatibility with older projects. Use node_resource_group_suffix for new projects."
}


variable "orchestrator_version" {
  type        = string
  description = "Version of Kubernetes used for the Agents. If not specified, the latest recommended version will be used at provisioning time (but won't auto-upgrade)"
  default     = "1.28.3"
}

variable "kubernetes_subnet_name" {
  type        = string
  default     = "kubernetes"
  description = "The subnet name for the virtual nodes to run."
}

variable "virtual_network_name" {
  type        = string
  description = "The name of the virtual network. Changing this forces a new resource to be created."
}

variable "virtual_network_id" {
  type        = string
  description = "The virtual NetworkConfiguration ID."
}

variable "node_cidr" {
  description = "This is the set of virtual IPs that are assigned the worker nodes and pods in your cluster"
  type        = string
  default     = "10.255.0.0/20"
}

variable "network_plugin" {

  type        = string
  default     = "azure"
  description = "Network plugin to use for networking. Currently supported values are azure, kubenet and none. Changing this forces a new resource to be created."

}

variable "service_cidr" {
  type        = string
  default     = "10.128.0.0/22"
  description = "The Network Range used by the Kubernetes service. Changing this forces a new resource to be created"
}


variable "network_policy" {
  type        = string
  default     = "azure"
  description = "Sets up network policy to be used with Azure CNI."
}

variable "load_balancer_sku" {
  type        = string
  default     = "standard"
  description = "Specifies the SKU of the Load Balancer used for this Kubernetes Cluster. Possible values are basic and standard. Defaults to standard"
}

variable "disable_bgp_route_propagation" {
  type        = bool
  description = "If set to true, the route propogation for the kubernetes route table will be disabled."
  default     = false
}

variable "identity" {
  type        = string
  default     = "SystemAssigned"
  description = " Specifies the type of Managed Service Identity that should be configured on this Kubernetes Cluster. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned (to enable both)."
}


variable "enable_aad_rbac" {
  type        = bool
  default     = true
  description = "Is Role Based Access Control based on Azure AD enabled?"

}


variable "admin_list" {
  type        = list(string)
  default     = []
  description = "If rbac is enabled, the default admin will be set over aad groups"

}

variable "enable_node_pools" {

  type        = bool
  default     = false
  description = "Allow you to enable node pools"

}

variable "node_pools" {
  type = map(object({
    name                   = string
    vm_size                = string
    zones                  = list(string)
    enable_auto_scaling    = bool
    enable_host_encryption = bool
    enable_node_public_ip  = bool
    max_pods               = number
    node_labels            = map(string)
    node_taints            = list(string)
    os_disk_size_gb        = string
    max_count              = number
    min_count              = number
    node_count             = number
    max_surge              = string
  }))

  description = <<-EOT
    If the default node pool is a Virtual Machine Scale Set, you can define additional node pools by defining this variable.
    As of Terraform 1.0 it is not possible to mark particular attributes as optional. If you don't want to set one of the attributes, set it to null.
  EOT

  default = {}
}

variable "azure_policy_enabled" {
  type        = bool
  default     = false
  description = "Enable Azure Policy on the Kubernetes Cluster"

}

variable "tags" {
  type = map(string)
  default = {
    TF-Managed  = "true"
    TF-Worfklow = ""
    Maintainer  = ""

  }
  description = "A mapping of tags to assign to the resource."
}
variable "automatic_channel_upgrade" {
  default = "none"
  description = "The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable"
}

variable "acr_tier" {
  default = "Premium"
}