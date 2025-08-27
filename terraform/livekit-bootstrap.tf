data "template_file" "script" {
  template                                  = file("./cloud-init/cloud_init.ubuntu.yaml")
}

data "template_cloudinit_config" "config" {
  gzip                                      = true
  base64_encode                             = true

  part {
    filename                                = "init.cfg"
    content_type                            = "text/cloud-config"
    content                                 = "${data.template_file.script.rendered}"
  }
}