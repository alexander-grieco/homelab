# Resource Definition for the VM Template
source "proxmox-iso" "nomad" {

  # Proxmox connection settings
  proxmox_url              = "${var.proxmox_api_url}"
  username                 = "${var.proxmox_token_id}"
  token                    = "${var.proxmox_token_secret}"
  insecure_skip_tls_verify = true

  #VM General Settings
  node                 = "pve"
  vm_id                = "899"
  vm_name              = "ubuntu-server-jammy-nomad"
  template_description = "Ubuntu Server 22.04 Image with Docker and Nomad pre-installed"

  # VM OS Settings
  iso_file         = "local:iso/Ubuntu_22.04.3_Server.iso"
  iso_storage_pool = "local"
  unmount_iso      = true

  # VM System Settings
  qemu_agent = true

  # VM Hard Disk Settings
  scsi_controller = "virtio-scsi-pci"

  disks {
    disk_size    = "64G"
    format       = "qcow2"
    storage_pool = "nomad-storage"
    type         = "virtio"
  }

  # VM CPU Settings
  cores = "2"

  # VM Memory settings
  memory = "4096"

  # VM Network Settings
  network_adapters {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = "false" # default
  }

  # VM Cloud Init Settings
  cloud_init              = true
  cloud_init_storage_pool = "nomad-storage"

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

  ssh_username         = "root"
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
      "rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
    ]
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #2
  provisioner "file" {
    source      = "files/proxmox/397-pve.cfg"
    destination = "/tmp/397-pve.cfg"
  }

  # Client CNI networking configuration
  # FIX ME
  provisioner "file" {
    source      = "files/nomad/bridge.conf"
    destination = "/etc/sysctl.d/bridge.conf"
  }

  # Provisioning the VM Template for Cloud-Init Integration in Proxmox #3
  provisioner "shell" {
    inline = ["cp /tmp/397-pve.cfg /etc/cloud/cloud.cfg.d/397-pve.cfg"]
  }

  provisioner "shell" {
    inline = [
      "echo set debconf to Noninteractive",
    "echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections"]
  }

  # Provisioning the VM Template with Docker Installation #4
  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'INSTALL DOCKER'",
      "echo '=============================================='",
      "apt-get -y update",
      "apt-get install -y ca-certificates curl gnupg",
      "install -m 0755 -d /etc/apt/keyrings",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
      "chmod a+r /etc/apt/keyrings/docker.gpg",

      # Add the repository to Apt sources:
      "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable\" | tee /etc/apt/sources.list.d/docker.list > /dev/null",
      "apt-get -y update",
      "apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
      "usermod -aG docker alex",
    ]
  }

  # https://discuss.hashicorp.com/t/how-to-fix-debconf-unable-to-initialize-frontend-dialog-error/39201/2
  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "echo '=============================================='",
      "echo 'APT INSTALL PACKAGES & UPDATES'",
      "echo '=============================================='",
      "apt-get update",
      "apt-get -y install --no-install-recommends apt-utils git unzip wget",
      "apt-get -y upgrade",
      #"echo 'DIST UPGRADE'",
      #"apt-get -y dist-upgrade",
      "apt-get -y autoremove",

      #"echo 'Rebooting...'",
      #"reboot"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'CREATE CONSUL USER & GROUP'",
      "echo '=============================================='",
      "addgroup --system consul",
      "adduser --system --ingroup consul consul",
      "usermod -aG docker consul",
      "mkdir -p /etc/consul.d/ssl",
      "mkdir -p /opt/consul",
      "mkdir -p /var/log/consul",
      "chown -R consul:consul /etc/consul.d",
      "chown -R consul:consul /opt/consul",
      "chown -R consul:consul /var/log/consul",
      "chmod 750 /etc/consul.d/ssl",
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'DOWNLOAD CONSUL'",
      "echo '=============================================='",
      "wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg",
      "echo \"deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main\" | tee /etc/apt/sources.list.d/hashicorp.list",
      "apt -y update && apt -y install consul",
      "rm /etc/consul.d/consul.hcl",
    ]
    max_retries = 3
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'CREATE NOMAD USER & GROUP'",
      "echo '=============================================='",
      "addgroup --system nomad",
      "adduser --system --ingroup nomad nomad",
      "usermod -aG docker nomad",
      "mkdir -p /etc/nomad.d/ssl",
      "mkdir -p /opt/nomad",
      "chown -R nomad:nomad /etc/nomad.d",
      "chown -R nomad:nomad /opt/nomad",
      "chmod 750 /etc/nomad.d/ssl",
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'DOWNLOAD NOMAD'",
      "echo '=============================================='",
      "apt update && apt install nomad",
      "rm /etc/nomad.d/nomad.hcl",
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
      "echo '=============================================='",
      "echo 'INSTALLING NOMAD CNI PACKAGES'",
      "echo '=============================================='",
      "curl -L -o cni-plugins.tgz \"https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)\"-v1.0.0.tgz",
      "mkdir -p /opt/cni/bin",
      "tar -C /opt/cni/bin -xzf cni-plugins.tgz",
    ]
  }

  provisioner "shell" {
    inline = [
      "rm /etc/ssh/ssh_host_*",
      "truncate -s 0 /etc/machine-id",
      "apt -y autoremove --purge",
      "apt -y clean",
      "apt -y autoclean",
      "cloud-init clean",
      "sync"
    ]
  }
}

