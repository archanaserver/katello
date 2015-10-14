module BastionKatello
  class Engine < ::Rails::Engine
    isolate_namespace BastionKatello

    initializer 'bastion.assets_dispatcher', :before => :build_middleware_stack do |app|
      app.middleware.use ::ActionDispatch::Static, "#{BastionKatello::Engine.root}/app/assets/javascripts/bastion_katello"
    end

    initializer "bastion.assets.paths", :group => :all do |app|
      app.middleware.use ::ActionDispatch::Static, "#{BastionKatello::Engine.root}/app/assets/javascripts/bastion_katello"

      if defined? Less::Rails
        app.config.less.paths << "#{BastionKatello::Engine.root}/app/assets/stylesheets/bastion_katello"
      end
    end

    config.to_prepare do
      consumer_cert_rpm = 'katello-ca-consumer-latest.noarch.rpm'
      consumer_cert_rpm = SETTINGS[:katello][:consumer_cert_rpm] if SETTINGS.key?(:katello)

      Bastion.register_plugin(
        :name => 'bastion_katello',
        :javascript => 'bastion_katello/bastion_katello',
        :stylesheet => 'bastion_katello/bastion_katello',
        :pages => %w(
          activation_keys
          content_hosts
          content_views
          docker_tags
          errata
          packages
          gpg_keys
          lifecycle_environments
          products
          puppet_modules
          subscriptions
          sync_plans
          host_collections
          katello_tasks
          select_organization
        ),
        :config => {
          'consumerCertRPM' => consumer_cert_rpm
        }
      )
    end
  end
end
