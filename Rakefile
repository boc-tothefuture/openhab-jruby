# frozen_string_literal: true

require "rake/packagetask"

require "bundler/gem_tasks"

require "English"
require "time"

PACKAGE_DIR = "pkg"

TMP_DIR = File.expand_path("tmp")
OPENHAB_DIR = File.join(TMP_DIR, "openhab")
CUCUMBER_LOGS = File.join(TMP_DIR, "cucumber_logs")

CLEAN << PACKAGE_DIR
CLEAN << CUCUMBER_LOGS
