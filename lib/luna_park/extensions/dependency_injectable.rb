# frozen_string_literal: true

module LunaPark
  module Extensions
    module DependencyInjectable
      ##
      # allows to release Dependency Injection
      #   works as .attr_accessor, but with default value and private getter
      #   By the way: you don't needed DI ewerywhere cause this is Ruby, and you have RSpec with his #allow etc.
      #
      # @example
      #   class Services::CreateTransaction
      #     extend Extensions::DependencyInjectable
      #
      #     dependency :repo, Repositories::Transaction
      #     dependency :generate_token, callable: -> { SecureRandom.hex(32) }
      #
      #     def initialize(params)
      #       @params = params
      #     end
      #
      #     def call
      #       attrs = params.merge(token: rand.token)
      #       repo.create(attrs)
      #       attrs
      #     end
      #   end
      #
      #   service = Services::CreateTransaction.new(attrs)
      #   service.repo        # => raise "private method called"
      #   service.send(:repo) # => Repositories::Transaction
      #
      #   service.repo = fake_repo
      #   service.generate_token = '42'
      #
      #   expect(fake_repo).to receive(:create)
      #   expect(service.call).to include(token: '42')
      def dependency(name, value = nil, callable: nil)
        ivar = :"@#{name}"
        attr_writer(name)

        if value
          define_method(name) { instance_variable_defined?(ivar) ? instance_variable_get(ivar) : value }
        elsif callable
          define_method(name) { instance_variable_defined?(ivar) ? instance_variable_get(ivar) : callable.call }
        end

        private(name)
      end
    end
  end
end
