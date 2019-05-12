provider "google" {
  version = "1.20.0"
  project = "${var.project}"
  region  = "${var.region}"
}

resource "google_container_cluster" "primary" {
  name               = "crawler-cluster"
  zone               = "${var.zone}"
  initial_node_count = "${var.cluster_node_count}"
  enable_legacy_abac = "true"

  # отключим сервисы мониторинга и логирования
  monitoring_service = "none"
  logging_service    = "none"

  # При пустых значениях базавая утентификация отлючается
  master_auth {
    username = ""
    password = ""
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }

    # отключим автомаштобирование подов
    horizontal_pod_autoscaling {
      disabled = true
    }
  }

  node_config {
    machine_type = "n1-standard-1"
    image_type   = "COS"
    disk_type    = "pd-standard"
    disk_size_gb = "100"

    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/servicecontrol",
      "https://www.googleapis.com/auth/service.management.readonly",
      "https://www.googleapis.com/auth/trace.append",
    ]
  }

  provisioner "local-exec" {
    command = "gcloud container clusters get-credentials crawler-cluster --zone ${var.zone} --project ${var.project}"
  }
}

resource "google_compute_instance" "gitlab_ci" {
  name         = "gitlab-ci"
  machine_type = "n1-standard-2"
  zone         = "${var.zone}"

  boot_disk {
    initialize_params {
      image = "ubuntu-1804-lts"
    }
  }

  metadata {
    ssh-keys = "appuser:${file(var.public_key_path)}"
  }

  network_interface {
    network = "default"

    access_config {}
  }
}

# Отрываем доступ для необходимых портов
resource "google_compute_firewall" "crawler_firewall" {
  name    = "crawler-firewall"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "2222", "3000"]
  }

  source_ranges = ["0.0.0.0/0"]
}
