require File.expand_path('../boot', __FILE__)

require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"
require "sprockets/railtie"
require "active_support/railtie"
require "active_support/dependencies"

if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require(*Rails.groups(:assets => %w(development test)))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default)
Bundler.require(Rails.env) unless Rails.env.test?

$LOAD_PATH << "lib"
$LOAD_PATH << "../echo-common-ruby/lib"

# if there is a yml file locally, load all keyword value pairs in the environment
ENV.update YAML.load_file('config/application.yml')[Rails.env] rescue {}

module EchoOpensearch
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    # config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # A workaround for https://issues.jboss.org/browse/TORQUE-955
    #config.middleware.use(TorqueboxBackslashFixMiddleware)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]
    config.autoload_paths += Dir["#{Rails.root}/app/services/**/"]
    config.logger = Logger.new(File.dirname(__FILE__) + "/../log/#{Rails.env}.log")
    config.logger.formatter = Logger::Formatter.new

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # Disable Rails's static asset server (Apache or nginx will already do this)
    config.serve_static_assets = false

    # Compress JavaScripts and CSS
    config.assets.compress = true
    config.assets.precompile = ['*.js', '*.css', '*.css.erb', '*.png', '*.jpg', '*.jpeg', '*.gif']
    config.assets.prefix = '/assets'
    config.relative_url_root = '/opensearch'
    config.assets.initialize_on_precompile = false

    def self.load_version
      version_file = "#{config.root}/version.txt"
      if File.exist?(version_file)
        return IO.read(version_file)
      elsif File.exist?('.git/config') && `which git`.size > 0
        version = `git rev-parse --abbrev-ref HEAD`
        return version
      end
      '(unknown)'
    end

    config.version = load_version

    # the endpoint used to generate CWIC granule OSDD links for the desired dataset
    # ALL environments will contain the endpoint value below unless overwritten in the environment specific .rb file
    # or the application.yml file
    config.cwic_granules_osdd_endpoint = 'http://cwic.wgiss.ceos.org/'

    config.cwic_tag = 'org.ceos.wgiss.cwic.*'
    config.cwic_descriptive_keyword = 'CWIC > CEOS WGISS Integrated Catalog'

    config.granule_osdd_tag = 'opensearch.granule.osdd'
    config.granule_osdd_descriptive_keyword = 'The association of this tag with a collection means that clients will use the collection provider granule search OpenSearch API rather than CMR'

    config.geoss_data_core_tag = 'org.geoss.geoss_data-core'
    config.geoss_data_core_descriptive_keyword = 'This is a GEOSS Data-CORE collection with full and open unrestricted access at no more than the cost of reproduction and distribution'

    config.eosdis_tag = 'gov.nasa.eosdis'
    config.eosdis_descriptive_keyword = 'NASA Earth Science Data and Information System'

    config.eosdis_providers = %w[
        NSIDCV0
        ORNL_DAAC
        LARC_ASDC
        LARC
        LAADS
        USGS_LTA
        USGS
        GES_DISC
        USGS_EROS
        GHRC
        SEDAC
        ASF
        LPDAAC_ECS
        LANCEMODIS
        NSIDC_ECS
        OB_DAAC
        CDDIS
        LM_FIRMS
        LANCEAMSR2
        OMINRT
        PODAAC
        OBPG
  ]

    ## additional default configuration parameters use to run tests or a basic local run with no scheduled tagging
    ## capabilities
    def self.update_env(name, value)
      if (ENV[name] == nil)
        ENV.update({name => value})
      end
    end
    update_env('opensearch_url', 'http://localhost:3000')
    update_env('catalog_rest_endpoint', 'https://cmr.earthdata.nasa.gov/search/')
    update_env('echo_rest_endpoint','https://api.echo.nasa.gov/echo-rest/')
    update_env('contact','echodev@echo.nasa.gov')
    update_env('public_catalog_rest_endpoint','https://cmr.earthdata.nasa.gov/search/')
    update_env('release_page', 'https://wiki.earthdata.nasa.gov/display/echo/Open+Search+API+release+information')
    update_env('documentation_page','https://wiki.earthdata.nasa.gov/display/CMR/Common+Metadata+Repository+Home')
    update_env('organization_contact_name','Stephen Berrick')

  end
end