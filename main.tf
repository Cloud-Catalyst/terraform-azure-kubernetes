resource "azurerm_kubernetes_cluster" "main" {
  name                   = var.aks_name
  location               = var.location
  resource_group_name    = var.resource_group_name
  kubernetes_version     = var.kubernetes_version
  sku_tier               = var.sku_tier
  dns_prefix             = var.node_dns_prefix
  node_resource_group    = var.node_resource_group
  local_account_disabled = var.local_account_disabled
  azure_policy_enabled   = var.azure_policy_enabled

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

    node_taints          = var.node_taints
    orchestrator_version = var.orchestrator_version
    upgrade_settings {
      max_surge = var.node_pool_max_surge
    }
  }


  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      microsoft_defender

    ]
  }

  automatic_channel_upgrade = var.automatic_channel_upgrade


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

    service_cidr      = var.service_cidr
    # IP address within the Kubernetes service address range that will be used by cluster service discovery (kube-dns).
    # Don't use the first IP address in your address range, such as .1. The first address in your subnet range is used for the kubernetes.default.svc.cluster.local address.
    dns_service_ip    = cidrhost(var.service_cidr, -2)
    network_policy    = var.network_policy
    load_balancer_sku = var.enable_node_pools ? "standard" : var.load_balancer_sku
  }

  api_server_access_profile {
    authorized_ip_ranges = var.authorized_ip_ranges
  }

  tags = var.tags
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_kubernetes_cluster_node_pool" "main" {
  for_each              = var.enable_node_pools ? var.node_pools : {}
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vnet_subnet_id        = azurerm_subnet.main.id

  name                = each.value.name
  vm_size             = each.value.vm_size
  zones               = each.value.zones
  enable_auto_scaling = each.value.enable_auto_scaling
  max_count           = each.value.enable_auto_scaling == true ? each.value.node_pool_min_count : null
  min_count           = each.value.enable_auto_scaling == true ? each.value.node_pool_min_count : null
  node_count          = each.value.node_count
  node_labels         = each.value.node_labels
  node_taints         = each.value.node_taints
  os_disk_size_gb     = each.value.os_disk_size_gb

  upgrade_settings {
    max_surge = each.value.node_pool_max_surge
  }

  lifecycle {
    ignore_changes = [
      node_count, tags
    ]
  }


  tags = var.tags
}
