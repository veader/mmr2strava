module MMRToStrava
  module AppEnv
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def is_development?
        ENV["RACK_ENV"] == "development"
      end

      def is_production?
        ENV["RACK_ENV"] == "production"
      end

      def env_name
        ENV["RACK_ENV"]
      end
    end

  end
end
