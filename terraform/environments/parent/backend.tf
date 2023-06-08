terraform {
  backend "gcs" {
    bucket = "YOUR_BACKEND_BUCKET"
    prefix = "parent"
  }
}
