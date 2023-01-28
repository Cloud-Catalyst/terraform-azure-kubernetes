resource "azurerm_kubernetes_cluster" "main" {
  name                   = var.aks_name
  location               = var.location
  resource_group_name    = var.resource_group_name
  kubernetes_version     = var.kubernetes_version
  sku_tier               = var.sku_tier
  dns_prefix             = var.node_dns_prefix
  node_resource_group    = var.node_resource_group
  local_account_disabled = var.local_account_disabled

  default_node_pool {
    name                  = var.node_pool_profile_name
    type                  = var.node_pool_type
    vm_size               = var.vm_size
    os_disk_size_gb       = var.os_disk_size_gb
    zones                 = var.node_pool_type == "VirtualMachineScaleSets" ? var.zones : null
    vnet_subnet_id        = azurerm_subnet.main.id
    enable_node_public_ip = var.enable_node_public_ip
    enable_auto_scaling   = var.node_pool_type == "VirtualMachineScaleSets" ? var.enable_auto_scaling : null
    node_count            = var.node_pool_count
    min_count             = var.enable_auto_scaling == true ? var.node_pool_min_count : null
    max_count             = var.enable_auto_scaling == true ? var.node_pool_max_count : null
    max_pods              = var.max_pods_per_node
    node_taints           = var.node_taints
    orchestrator_version  = var.orchestrator_version
  }

  azure_active_directory_role_based_access_control {
    managed                = var.enable_aad_rbac
    admin_group_object_ids = var.enable_aad_rbac == true ? var.admin_list : []
    azure_rbac_enabled     = var.enable_aad_rbac
  }


  identity {
    type = var.identity
  }


  linux_profile {
    admin_username = var.node_admin_username

    ssh_key {
      key_data = tls_private_key.main.public_key_openssh
    }
  }

  network_profile {
    network_plugin = var.network_policy == "azure" ? "azure" : var.network_plugin

    service_cidr = var.service_cidr
    # IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns).
    # Don't use the first IP address in your address range, such as .1. The first address in your subnet range is used for the kubernetes.default.svc.cluster.local address.
    dns_service_ip     = cidrhost(var.service_cidr, -2)
    docker_bridge_cidr = var.docker_bridge_cidr
    network_policy     = var.network_policy
    load_balancer_sku  = var.load_balancer_sku
  }

  tags = var.tags
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

