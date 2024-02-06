# Resource Definition for the VM Template
source "proxmox-iso" "nomad" {

  # Proxmox connection settings
  proxmox_url              = "${var.proxmox_api_url}"
  username                 = "${var.proxmox_token_id}"
  token                    = "${var.proxmox_token_secret}"
  insecure_skip_tls_verify = true

  #VM General Settings
  node                 = "pve"
  vm_id                = "399"
  vm_name              = "ubuntu-server-jammy-nomad"
  template_description = "Ubuntu Server 22.04 Test Image with Docker and Nomad pre-installed"

  # VM OS Settings
  iso_file = "local:iso/Ubuntu_22.04.3_Server.iso"
  # iso_checksum     = "sha256:a4acfda10b18da50e2ec50ccaf860d7f20b389df8765611142305c0e911d16fd"
  iso_storage_pool = "local"
  unmount_iso      = true

  # VM System Settings
  qemu_agent = true
  onboot     = true

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-single"

  disks {
    disk_size    = "64G"
    format       = "raw"
    storage_pool = "local-lvm"
    #storage_pool_type = "lvm"
    type = "scsi"
  }

  # VM CPU Settings
  cores = "2"

  # VM Memory settings
  memory = "4096"

  # VM Network Settings
  network_adapters {
    model  = "virtio"
    bridge = "vmbr0"
    #vlan_tag = "2"
    firewall = "false" # default
  }

  # VM Cloud Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  # Packer Boot Commands
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]

  boot      = "c"
  boot_wait = "10s"

  # PACKER Autoinstall Settings
  http_directory = "http"

  ssh_username         = "alex"
  ssh_private_key_file = "~/.ssh/github_ed25519"
  ssh_timeout          = "30m"
}

# Build Definition to create the VM Template.
build {

  name    = "nomad"
  sources = ["source.proxmox-iso.nomad"]

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/proxmox/397-pve.cfg"
    destination = "/tmp/397-pve.cfg"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = ["sudo cp /tmp/397-pve.cfg /etc/cloud/cloud.cfg.d/397-pve.cfg"]
  }

  provisioner "shell" {
    inline = [
      "echo set debconf to Noninteractive",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections" ]
  }

  # Provisioning the VM Template with Docker Installation #4
  provisioner "shell" {
    inline = [
      #"sudo apt-get install -y ca-certificates curl gnupg lsb-release",
      #"curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg",
      #"echo \"deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      #"sudo apt-get -y update",
      #"sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin",
      #"sudo apt install -y docker-ce",
      "echo '=============================================='",
      "echo 'INSTALL DOCKER'",
      "echo '=============================================='",
      "sudo apt-get -y update",
      "sudo apt-get install -y ca-certificates curl gnupg",
      "sudo install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "sudo chmod a+r /etc/apt/keyrings/docker.gpg",

      # Add the repository to Apt sources:
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "sudo apt-get -y update",
      "sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "sudo usermod -aG docker alex",
    ]
  }

  # https://discuss.hashicorp.com/t/how-to-fix-debconf-unable-to-initialize-frontend-dialog-error/39201/2
  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "echo '=============================================='",
      "echo 'APT INSTALL PACKAGES & UPDATES'",
      "echo '=============================================='",
      "sudo apt-get update",
      "sudo apt-get -y install --no-install-recommends apt-utils git unzip wget",
      "sudo apt-get -y upgrade",
      #"echo 'DIST UPGRADE'",
      #"sudo apt-get -y dist-upgrade",
      "sudo apt-get -y autoremove",

      #"echo 'Rebooting...'",
      #"sudo reboot"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'CREATE CONSUL USER & GROUP'",
      "echo '=============================================='",
      "sudo addgroup --system consul",
      "sudo adduser --system --ingroup consul consul",
      "sudo usermod -aG docker consul",
      "sudo mkdir -p /etc/consul.d/ssl",
      "sudo mkdir -p /opt/consul",
      "sudo mkdir -p /var/log/consul",
      "sudo chown -R consul:consul /etc/consul.d",
      "sudo chown -R consul:consul /opt/consul",
      "sudo chown -R consul:consul /var/log/consul",
      "sudo chmod 750 /etc/consul.d/ssl",
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'DOWNLOAD CONSUL'",
      "echo '=============================================='",
      "wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | sudo tee /etc/apt/sources.list.d/hashicorp.list",
      "sudo apt -y update && sudo apt -y install consul",



      #"wget https://releases.hashicorp.com/consul/${var.consul_version}/consul_${var.consul_version}_linux_${var.arch}.zip",
      #"unzip consul_${var.consul_version}_linux_${var.arch}.zip",
      #"sudo mv consul /usr/local/bin/",
      #"rm consul_${var.consul_version}_linux_${var.arch}.zip"
    ]
    max_retries = 3
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'CREATE NOMAD USER & GROUP'",
      "echo '=============================================='",
      "sudo addgroup --system nomad",
      "sudo adduser --system --ingroup nomad nomad",
      "sudo usermod -aG docker nomad",
      "sudo mkdir -p /etc/nomad.d/ssl",
      "sudo mkdir -p /opt/nomad",
      "sudo chown -R nomad:nomad /etc/nomad.d",
      "sudo chown -R nomad:nomad /opt/nomad",
      "sudo chmod 750 /etc/nomad.d/ssl",
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'DOWNLOAD NOMAD'",
      "echo '=============================================='",
      "sudo apt update && sudo apt install nomad",



      #"wget https://releases.hashicorp.com/nomad/${var.nomad_version}/nomad_${var.nomad_version}_linux_${var.arch}.zip",
      #"unzip nomad_${var.nomad_version}_linux_${var.arch}.zip",
      #"sudo mv nomad /usr/local/bin/",
      #"rm nomad_${var.nomad_version}_linux_${var.arch}.zip"
    ]
    max_retries = 3
  }

  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "which consul",
      "which nomad",
      "echo '=============================================='",
      "echo 'BUILD COMPLETE'",
      "echo '=============================================='"
    ]
  }

  provisioner "shell" {
    inline = [
      "sudo rm /etc/ssh/ssh_host_*",
      "sudo truncate -s 0 /etc/machine-id",
      "sudo apt -y autoremove --purge",
      "sudo apt -y clean",
      "sudo apt -y autoclean",
      "sudo cloud-init clean",
      "sudo sync"
    ]
  }
}

