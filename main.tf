terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      #latest version as of Nov 30 2022
      version = "2.9.11"
    }
  }
}

provider "proxmox" {
  # References our vars.tf file to plug in the api_url 
  pm_api_url = var.api_url
  # References our secrets.tfvars file to plug in our token_id
  pm_api_token_id = var.token_id
  # References our secrets.tfvars to plug in our token_secret 
  pm_api_token_secret = var.token_secret
  # Default to `true` unless you have TLS working within your pve setup 
  pm_tls_insecure = true
}

# Creates a proxmox_vm_qemu entity named blog_demo_test
resource "proxmox_vm_qemu" "blog_demo_test" {
  name = "test-vm-${count.index + 1}" # count.index starts at 0
  count = 5 # Establishes how many instances will be created 
  target_node = var.proxmox_host

  # References our vars.tf file to plug in our template name
  clone = var.template_name
  # Creates a full clone, rather than linked clone 
  # https://pve.proxmox.com/wiki/VM_Templates_and_Clones
  full_clone  = "true"

  # VM Settings. `agent = 1` enables qemu-guest-agent
  agent = 1
  os_type = "cloud-init"
  cores = 2
  sockets = 1
  cpu = "host"
  memory = 2048
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot = 0
    size = "50G"
    type = "scsi"
    storage = "local" # Name of storage local to the host you are spinning the VM up on
    # Enables SSD emulation
    ssd = 1
    # Enables thin-provisioning
    discard = "on"
    #iothread = 1
  }

  network {
    model = "virtio"
    bridge = var.nic_name
    tag = var.vlan_num # This tag can be left off if you are not taking advantage of VLANs
  }


  lifecycle {
    ignore_changes = [
      network,
    ]
  }
  #provisioner "local-exec" {
    # Provisioner commands can be run here.
    # We will use provisioner functionality to kick off ansible
    # playbooks in the future
    #command = "touch /home/tcude/test.txt"
  #}
}