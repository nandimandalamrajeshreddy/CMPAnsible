terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.9.0"
    }
  }
}
provider "azurerm" {

  subscription_id = "27d6abf4-ed9d-4ff7-a1cd-713d01326bb8"
  client_id = "47c09f83-f666-4f52-9c4b-8ba3b31dbf52"
  client_secret = "Nsf8Q~uUkSi6S3.WT1Jvc7JSpa9EhuMJ~wf21dzh"
  tenant_id = "415696b8-fb9c-4950-b4fe-4296bca33f39"

  features {}
}




data "azurerm_resource_group" "rg" {
  name                = "wa-demo-system-rg"
}

data "azurerm_virtual_network" "vnet" {
  name                = "wa-demo-vnet"
  resource_group_name = "wa-demo-network-rg"
}

data "azurerm_subnet" "sn" {
  name                = "Application"
  resource_group_name = "wa-demo-network-rg"
  virtual_network_name = data.azurerm_virtual_network.vnet.name

}


data "azurerm_recovery_services_vault" "rv" {
  name                = "wa-demo-0042-backup-storage"
  resource_group_name = "wa-demo-system-rg"
}
/*
data "azurerm_key_vault" "kv" {
  name                = "wa-kv-test"
  resource_group_name = "wa-demo-system-rg"
}


data "azurerm_key_vault_key" "kvk" {
  name      = "keys"
  key_vault_id = data.azurerm_key_vault.kv.id
}
*/

# Prefix and Tags

variable "prefix" {
    description =   "Prefix to append to all resource names"
    type        =   string
    default     =   "wacmpv6"
}

variable "managed" {
    type    =   string
    default =   true
}

variable "platform_fault_domain_count" {
    type    =   string
    default =   2
}

variable "admin_username" {
    description =   "Username to login to the VM"
    type        =   string
    default     =   "cmpadmin"
}

variable "admin_password" {
    description =   "Password to login to the VM"
    type        =   string
    default     =   "Unisys*12345"
}


variable "allocation_methods" {
    description =   "Allocation method for Public IP Address and NIC Private ip address"
    type        =   string
    default     =   "Dynamic"
}

variable encryption_algorithm {
  description = " Algo for encryption"
  default     = "RSA-OAEP"
}

variable "volume_type" {
  default = "All"
}

variable "encrypt_operation" {
  default = "EnableEncryption"
}

variable "type_handler_version" {
  description = "Type handler version of the VM extension to use. Defaults to 2.2 on Windows and 1.1 on Linux"
  default     = "2.2"
}

#
# - Create a Availability Set
#

resource "azurerm_availability_set" "availability_set" {
   name                          = "${var.prefix}-availability_set"
   location                      = data.azurerm_resource_group.rg.location
   resource_group_name           = data.azurerm_resource_group.rg.name
   managed                       = var.managed
   platform_fault_domain_count   = var.platform_fault_domain_count
   tags = {
    ucf-ops-acc-project = "demo"
  }

}


#
# - Create a Network Interface Card for Virtual Machine
#

resource "azurerm_network_interface" "nic" {
    name                              =   "${var.prefix}-linuxvm-nic"
    resource_group_name               =   data.azurerm_resource_group.rg.name
    location                          =   data.azurerm_resource_group.rg.location
    ip_configuration                  {
        name                          =  "${var.prefix}-nic-ipconfig"
        subnet_id                     =   data.azurerm_subnet.sn.id
        private_ip_address_allocation =   var.allocation_methods
    }
	tags = {
    ucf-ops-acc-project = "demo"
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "${var.prefix}-win-vm"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
  size                = "Standard_B2s"
  admin_username      = "cmpadmin"
  admin_password      = "Unisys*12345"
  encryption_at_host_enabled = true
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    write_accelerator_enabled = false
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
  tags = {
    ucf-ops-acc-project = "demo"
  }
}


resource "azurerm_backup_policy_vm" "vm_policy_bkp" {
  name                = "${var.prefix}-recovery-vault-policy"
  resource_group_name = data.azurerm_resource_group.rg.name
  recovery_vault_name = data.azurerm_recovery_services_vault.rv.name

  backup {
    frequency = "Daily"
    time      = "23:00"
  }
   retention_daily {
    count = 10
  }
}

resource "azurerm_backup_protected_vm" "bkp_win_vm" {
  resource_group_name = data.azurerm_resource_group.rg.name
  recovery_vault_name = data.azurerm_recovery_services_vault.rv.name
  source_vm_id        = azurerm_windows_virtual_machine.example.id
  backup_policy_id    = azurerm_backup_policy_vm.vm_policy_bkp.id
}

/*
resource "azurerm_virtual_machine_extension" "vmext" {
  name                 = "vm-ext01"
  virtual_machine_id   = azurerm_windows_virtual_machine.example.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
    {
        "commandToExecute": "net accounts /MINPWLEN:14 && net accounts /uniquepw:24 && net accounts /MAXPWAGE:70 && net accounts /MINPWAGE:1 && wuauclt /detectnow /updatenow"
    }
SETTINGS

}
*/

resource "azurerm_virtual_machine_extension" "vm-ext02" {
  name                 = "install-software"
  virtual_machine_id   = azurerm_windows_virtual_machine.example.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(data.template_file.tf.rendered)}')) | Out-File -filepath pass.ps1\" && powershell -ExecutionPolicy Unrestricted -File pass.ps1"
  }
  SETTINGS
}

data "template_file" "tf" {
    template = "${file("pass.ps1")}"
}