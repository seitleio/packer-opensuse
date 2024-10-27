packer {
    required_plugins {
      virtualbox = {
        version = "~> 1"
        source  = "github.com/hashicorp/virtualbox"
      }
      vagrant = {
        version = "~> 1"
        source = "github.com/hashicorp/vagrant"
      }
    }
}

variable user_username {
  default = "vagrant"
}
variable user_password {
  default = "vagrant"
}
variable os_name {
  default = "openSUSE"
}
variable os_additional_name {
  default = "leap"
}
variable os_version {}
variable iso_url {}
variable iso_checksum {}

source "virtualbox-iso" "opensuse" {
  vm_name = "${ var.os_name }-${ var.os_additional_name }-${ var.os_version }"

  guest_os_type = "OpenSuse_64"
  iso_url = var.iso_url
  iso_checksum = var.iso_checksum
  cd_content = {
    "autoinst.xml" = templatefile("sources/${ var.os_version }/autoinst.xml.tmpl", {
      username = var.user_username
      password = var.user_password
    })
  }
  cd_label = "OEMDRV"
  boot_command = [
    "<esc><enter><wait>",
    "linux ",
    "biosdevname=0 ",
    "net.ifnames=0 ",
    "netdevice=eth0 ",
    "netsetup=dhcp ",
    "lang=en_US ",
    "textmode=0 ",
    "autoyast=label://OEMDRV/autoinst.xml<wait> ",
    "<enter><wait>"
  ]

  ssh_username = var.user_username
  ssh_password = var.user_password
  ssh_timeout = "30m"
  shutdown_command = "echo '${ var.user_password }' | sudo -S shutdown -P now"

  cpus = 2
  memory = 4096
}

build {
  sources = ["source.virtualbox-iso.opensuse"]
  post-processors {
    post-processor "vagrant" {
      keep_input_artifact = true
      provider_override   = "virtualbox"
    }
  }
}