#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Linux VM - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

# Prefix and Tags

variable "prefix" {
    description =   "Prefix to append to all resource names"
    type        =   string
#    default     =   "tis-client-demo"
}

/*

variable "lb_sku" {
    description = "Load balancer of the SKU"
    type        =   string
#    default     = "Standard"
}

# Public IP and NIC Allocation Method

variable "allocation_method" {
    description =   "Allocation method for Public IP Address and NIC Private ip address"
    type        =   string
#    default     =   "Static"
}
*/
# Availability Set

variable "managed" {
    type    =   string
#    default =   true
}

variable "platform_fault_domain_count" {
    type    =   string
#    default =   2
}


variable "allocation_methods" {
    description =   "Allocation method for Public IP Address and NIC Private ip address"
    type        =   string
#    default     =   "Dynamic"
}


# VM 

variable "virtual_machine_size" {
    description =   "Size of the VM"
    type        =   string
#    default     =   "Standard_D4s_v3"
}

variable "computer_name" {
    description =   "Computer name"
    type        =   string
#    default     =   "tis-win16"
}

variable "admin_username" {
    description =   "Username to login to the VM"
    type        =   string
#    default     =   "tisadmin"
}

variable "admin_password" {
    description =   "Password to login to the VM"
    type        =   string
#    default     =   "Unisys*12345"
}

variable "os_disk_caching" {
#    default     =       "ReadWrite"
}

variable "os_disk_storage_account_type" {
#    default     =       "StandardSSD_LRS"
}

variable "os_disk_size_gb" {
#    default     =       64
}

variable "publisher" {
#    default     =       "MicrosoftWindowsServer"
}

variable "offer" {
#    default     =       "WindowsServer"
}

variable "sku" {
#    default     =       "2016-Datacenter"
}

variable "vm_image_version" {
#    default     =       "latest"
}

variable "subscription_id"  {
    description  =  "Variables for Storage accounts"
    type         =  string
}

variable "client_id"  {
    description  =  "Variables for Storage accounts"
    type         =  string
}

variable "client_secret"  {
    description  =  "Variables for Storage accounts"
    type         =  string
}
variable "tenant_id"  {
    description  =  "Variables for Storage accounts"
    type         =  string
}
/*
variable "tags" {
    description =   "Resouce tags"
    type        =   map(string)
    default     =   {
        "TIS"        =   "ENV"
    }
}
*/