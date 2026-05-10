ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require "turbo/broadcastable/test_helper"

module ActiveSupport
  class TestCase
    include Turbo::Broadcastable::TestHelper

    parallelize(workers: :number_of_processors)

    fixtures :all
  end
end

class ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers
end
