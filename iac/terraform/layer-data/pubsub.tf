resource "google_pubsub_topic" "lb-topic" {
  name = "lb-topic-${terraform.workspace}"
}

resource "google_pubsub_subscription" "lb-topic-subscription" {
  name  = "lb-topic-subscription-${terraform.workspace}"
  topic = "${google_pubsub_topic.lb-topic.name}"

  ack_deadline_seconds = 20
}
