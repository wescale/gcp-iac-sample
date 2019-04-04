output "user1_password" {
  value = "${google_sql_user.lb-sql-user1.password}"
}

output "user2_password" {
  value = "${google_sql_user.lb-sql-user2.password}"
}
