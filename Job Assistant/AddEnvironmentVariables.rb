#!/usr/bin/ruby

file_content = <<-CREDS_FILE_STRING
struct EnvironmentVariables {
    static let openAISecretKey = "#{ENV['OPENAI_SECRET_KEY']}"
}
CREDS_FILE_STRING

file = File.new("Job\ Assistant/EnvironmentVariables.swift", "w")
file.puts(file_content)
file.close
